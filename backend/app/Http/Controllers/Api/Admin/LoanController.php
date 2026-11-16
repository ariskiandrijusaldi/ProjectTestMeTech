<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\RejectLoanRequest;
use App\Http\Resources\LoanResource;
use App\Models\Book;
use App\Models\Loan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class LoanController extends Controller
{
    /**
     * GET /api/admin/loans?status=pending|history|approved|rejected|returned|overdue&search=
     *  - pending : tab "Menunggu"
     *  - history : tab "Riwayat" (semua selain pending)
     *  - approved: buku yang sedang dipinjam (untuk halaman pengembalian)
     */
    public function index(Request $request)
    {
        $status = $request->query('status', 'pending');

        $loans = Loan::with(['user', 'book'])
            ->when($status === 'history', fn ($q) => $q->where('status', '!=', 'pending'))
            ->when($status === 'overdue', fn ($q) => $q->overdue())
            ->when(in_array($status, ['pending', 'approved', 'rejected', 'returned'], true),
                fn ($q) => $q->where('status', $status))
            ->when($request->query('search'), function ($q, $term) {
                $q->where(function ($w) use ($term) {
                    $w->where('code', 'like', "%{$term}%")
                      ->orWhereHas('user', fn ($u) => $u->where('name', 'like', "%{$term}%")
                                                        ->orWhere('nim', 'like', "%{$term}%"))
                      ->orWhereHas('book', fn ($b) => $b->where('title', 'like', "%{$term}%"));
                });
            })
            ->latest('requested_at')
            ->paginate($request->integer('per_page', 10));

        return LoanResource::collection($loans)->additional([
            'meta_counts' => [
                'pending' => Loan::where('status', 'pending')->count(), // angka "Menunggu (2)"
            ],
        ]);
    }

    // GET /api/admin/loans/{loan}
    public function show(Loan $loan): LoanResource
    {
        return new LoanResource($loan->load(['user', 'book', 'approver']));
    }

    // PATCH /api/admin/loans/{loan}/approve
    public function approve(Loan $loan)
    {
        return DB::transaction(function () use ($loan) {
            $loan = Loan::lockForUpdate()->findOrFail($loan->id);

            if ($loan->status !== 'pending') {
                return response()->json(['message' => 'Pengajuan sudah diproses.'], 422);
            }

            $book = Book::lockForUpdate()->findOrFail($loan->book_id);

            if ($book->stock_available < 1) {
                return response()->json(['message' => 'Stok buku habis.'], 422);
            }

            $book->decrement('stock_available');

            $loan->update([
                'status'      => 'approved',
                'approved_by' => auth()->id(),
                'approved_at' => now(),
                'due_date'    => today()->addDays((int) config('library.loan_days', 7)),
            ]);

            return (new LoanResource($loan->fresh(['user', 'book'])))
                ->additional(['message' => 'Peminjaman disetujui.']);
        });
    }

    // PATCH /api/admin/loans/{loan}/reject   body: {reason?}
    public function reject(RejectLoanRequest $request, Loan $loan)
    {
        return DB::transaction(function () use ($request, $loan) {
            $loan = Loan::lockForUpdate()->findOrFail($loan->id);

            if ($loan->status !== 'pending') {
                return response()->json(['message' => 'Pengajuan sudah diproses.'], 422);
            }

            $loan->update([
                'status'          => 'rejected',
                'approved_by'     => auth()->id(),
                'approved_at'     => now(),
                'rejected_reason' => $request->input('reason'),
            ]);

            return (new LoanResource($loan->fresh(['user', 'book'])))
                ->additional(['message' => 'Peminjaman ditolak.']);
        });
    }

    // PATCH /api/admin/loans/{loan}/return   (Konfirmasi Pengembalian)
    public function returnBook(Loan $loan)
    {
        return DB::transaction(function () use ($loan) {
            $loan = Loan::lockForUpdate()->findOrFail($loan->id);

            if ($loan->status !== 'approved') {
                return response()->json(['message' => 'Buku tidak sedang dipinjam.'], 422);
            }

            $fine = $loan->lateDays() * (float) config('library.fine_per_day', 1000);

            $loan->update([
                'status'      => 'returned',
                'returned_at' => now(),
                'fine_amount' => $fine,
                'fine_paid'   => $fine == 0,
            ]);

            Book::whereKey($loan->book_id)->lockForUpdate()->first()?->increment('stock_available');

            return (new LoanResource($loan->fresh(['user', 'book'])))
                ->additional(['message' => 'Pengembalian berhasil dikonfirmasi.']);
        });
    }

    // PATCH /api/admin/loans/{loan}/pay-fine   (tandai denda lunas)
    public function payFine(Loan $loan)
    {
        if ($loan->status !== 'returned' || (float) $loan->fine_amount <= 0) {
            return response()->json(['message' => 'Tidak ada denda yang perlu dilunasi.'], 422);
        }

        $loan->update(['fine_paid' => true]);

        return (new LoanResource($loan->fresh(['user', 'book'])))
            ->additional(['message' => 'Denda ditandai lunas.']);
    }
}
