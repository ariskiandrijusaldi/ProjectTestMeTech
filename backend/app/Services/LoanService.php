<?php

namespace App\Services;

use App\Models\Book;
use App\Models\Loan;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class LoanService
{
    public function requestLoan(User $user, int $bookId): array
    {
        return DB::transaction(function () use ($user, $bookId) {
            $book = Book::lockForUpdate()->findOrFail($bookId);

            if ((int) $book->stock_available < 1) {
                return ['ok' => false, 'message' => 'Stok buku tidak tersedia.', 'code' => 422];
            }

            $hasUnpaidFine = Loan::where('user_id', $user->id)
                ->where('fine_amount', '>', 0)
                ->where('fine_paid', false)
                ->exists();
            if ($hasUnpaidFine) {
                return ['ok' => false, 'message' => 'Anda memiliki denda yang belum lunas. Silakan lunasi sebelum meminjam lagi.', 'code' => 422];
            }

            $activeLoans = Loan::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'approved'])
                ->count();
            if ($activeLoans >= config('library.max_active_loans', 3)) {
                return ['ok' => false, 'message' => 'Anda sudah mencapai batas pinjaman aktif (' . config('library.max_active_loans', 3) . ').', 'code' => 422];
            }

            $existing = Loan::where('user_id', $user->id)
                ->where('book_id', $bookId)
                ->whereIn('status', ['pending', 'approved'])
                ->exists();
            if ($existing) {
                return ['ok' => false, 'message' => 'Anda sudah memiliki pengajuan atau peminjaman aktif untuk buku ini.', 'code' => 422];
            }

            $code = $this->generateLoanCode();

            $loan = Loan::create([
                'user_id' => $user->id,
                'book_id' => $book->id,
                'code' => $code,
                'loan_code' => $code,
                'quantity' => 1,
                'status' => 'pending',
                'loan_date' => Carbon::today(),
                'due_date' => null,
                'returned_at' => null,
                'fine_amount' => 0,
                'fine_paid' => true,
                'rejected_reason' => null,
            ]);

            return ['ok' => true, 'loan' => $loan->load('book.category'), 'message' => 'Pengajuan peminjaman berhasil diajukan.', 'code' => 201];
        });
    }

    public function approveLoan(int $loanId, User $admin): array
    {
        return DB::transaction(function () use ($loanId, $admin) {
            $loan = Loan::lockForUpdate()->findOrFail($loanId);

            if ($loan->status !== 'pending') {
                return ['ok' => false, 'message' => 'Pengajuan sudah diproses.', 'code' => 422];
            }

            $book = Book::lockForUpdate()->findOrFail($loan->book_id);

            if ((int) $book->stock_available < 1) {
                return ['ok' => false, 'message' => 'Stok buku habis.', 'code' => 422];
            }

            $book->decrement('stock_available');

            $loan->update([
                'status' => 'approved',
                'approved_by' => $admin->id,
                'approved_at' => Carbon::now(),
                'due_date' => Carbon::today()->addDays((int) config('library.loan_days', 7)),
            ]);

            return ['ok' => true, 'loan' => $loan->fresh(['user', 'book', 'approver']), 'message' => 'Peminjaman disetujui.', 'code' => 200];
        });
    }

    public function rejectLoan(int $loanId, User $admin, string $reason): array
    {
        return DB::transaction(function () use ($loanId, $admin, $reason) {
            $loan = Loan::lockForUpdate()->findOrFail($loanId);

            if ($loan->status !== 'pending') {
                return ['ok' => false, 'message' => 'Pengajuan sudah diproses.', 'code' => 422];
            }

            $loan->update([
                'status' => 'rejected',
                'approved_by' => $admin->id,
                'approved_at' => Carbon::now(),
                'rejected_reason' => $reason,
            ]);

            return ['ok' => true, 'loan' => $loan->fresh(['user', 'book']), 'message' => 'Peminjaman ditolak.', 'code' => 200];
        });
    }

    public function returnLoan(int $loanId, User $admin): array
    {
        return DB::transaction(function () use ($loanId, $admin) {
            $loan = Loan::lockForUpdate()->findOrFail($loanId);

            if ($loan->status !== 'approved') {
                return ['ok' => false, 'message' => 'Buku tidak sedang dipinjam.', 'code' => 422];
            }

            $fine = (float) $loan->lateDays * (float) config('library.fine_per_day', 1000);

            $loan->update([
                'status' => 'returned',
                'returned_at' => Carbon::now(),
                'fine_amount' => $fine,
                'fine_paid' => $fine == 0,
            ]);

            Book::whereKey($loan->book_id)->lockForUpdate()->first()?->increment('stock_available');

            return ['ok' => true, 'loan' => $loan->fresh(['user', 'book']), 'message' => 'Pengembalian berhasil dikonfirmasi.', 'code' => 200];
        });
    }

    public function payFine(int $loanId, User $admin): array
    {
        $loan = Loan::findOrFail($loanId);

        if ($loan->status !== 'returned' || (float) $loan->fine_amount <= 0) {
            return ['ok' => false, 'message' => 'Tidak ada denda yang perlu dilunasi.', 'code' => 422];
        }

        $loan->update(['fine_paid' => true]);

        return ['ok' => true, 'loan' => $loan->fresh(['user', 'book']), 'message' => 'Denda ditandai lunas.', 'code' => 200];
    }

    public function cancelOwnLoan(int $loanId, User $user): array
    {
        return DB::transaction(function () use ($loanId, $user) {
            $loan = Loan::lockForUpdate()->findOrFail($loanId);

            if ($loan->user_id !== $user->id) {
                return ['ok' => false, 'message' => 'Bukan peminjaman Anda.', 'code' => 403];
            }

            if ($loan->status !== 'pending') {
                return ['ok' => false, 'message' => 'Hanya pengajuan yang masih menunggu yang dapat dibatalkan.', 'code' => 422];
            }

            $loan->delete();

            return ['ok' => true, 'message' => 'Pengajuan peminjaman dibatalkan.', 'code' => 200];
        });
    }

    protected function generateLoanCode(): string
    {
        $prefix = 'PJ' . Carbon::now()->format('ymd');
        $last = Loan::where('code', 'like', $prefix . '%')
            ->orderByDesc('code')
            ->first();
        $next = 1;
        if ($last && preg_match('/' . $prefix . '(\\d+)$/', $last->code, $m)) {
            $next = (int) $m[1] + 1;
        }
        return $prefix . str_pad((string) $next, 2, '0', STR_PAD_LEFT);
    }
}