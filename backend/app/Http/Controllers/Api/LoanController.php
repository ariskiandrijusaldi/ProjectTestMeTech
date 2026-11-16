<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Loan;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class LoanController extends Controller
{
    /**
     * Halaman Pengajuan Peminjaman: Submit Pengajuan
     */
    public function store(Request $request)
    {
        // Support book_id atau item_id dari request body
        $itemId = $request->input('item_id') ?? $request->input('book_id');
        $request->merge(['book_id' => $itemId]);

        $request->validate([
            'book_id' => 'required|exists:books,id',
            'quantity' => 'nullable|integer|min:1',
            'loan_date' => 'nullable|date',
            'return_date' => 'nullable|date|after_or_equal:loan_date',
        ]);

        $quantity = (int) ($request->input('quantity') ?? 1);
        $loanDate = $request->input('loan_date') ?? now()->toDateString();

        $book = Book::findOrFail($itemId);

        if ($book->stok < $quantity) {
            return response()->json([
                'status' => 'error',
                'message' => 'Stok barang tidak mencukupi. Sisa stok: ' . $book->stok . ' unit.'
            ], 400);
        }

        // Kurangi stok barang
        $book->decrement('stok', $quantity);

        // Generate kode peminjaman unik (contoh di UI: #PJ250701)
        $loanCode = '#PJ' . date('ym') . str_pad((string) rand(1, 9999), 2, '0', STR_PAD_LEFT);

        $userId = auth('sanctum')->id() ?? 1;

        $loan = Loan::create([
            'user_id' => $userId,
            'book_id' => $book->id,
            'loan_code' => $loanCode,
            'quantity' => $quantity,
            'status' => 'Menunggu Persetujuan',
            'loan_date' => $loanDate,
            'return_date' => $request->input('return_date'),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Pengajuan peminjaman berhasil diajukan',
            'data' => $loan->load('book.category')
        ], 201);
    }

    /**
     * Halaman Status Peminjaman: Daftar Peminjaman Saya (Aktif vs Riwayat)
     */
    public function myLoans(Request $request)
    {
        $userId = auth('sanctum')->id() ?? 1;
        $tab = strtolower($request->query('tab') ?? $request->query('status') ?? 'all');

        $query = Loan::with('book.category')
                    ->where('user_id', $userId)
                    ->latest();

        // Filter tab sesuai tampilan Screen 5 (Aktif vs Riwayat)
        if (in_array($tab, ['active', 'aktif'])) {
            $query->whereIn('status', ['Menunggu Persetujuan', 'Disetujui']);
        } elseif (in_array($tab, ['history', 'riwayat'])) {
            $query->whereIn('status', ['Selesai', 'Ditolak']);
        } elseif ($request->filled('status') && !in_array($request->status, ['all', 'Semua'])) {
            $query->where('status', $request->status);
        }

        $loans = $query->get();

        return response()->json([
            'status' => 'success',
            'tab' => $tab,
            'total' => $loans->count(),
            'data' => $loans
        ], 200);
    }

    /**
     * Endpoint Tambahan: Update Status Peminjaman (Disetujui, Selesai, Ditolak)
     */
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:Menunggu Persetujuan,Disetujui,Ditolak,Selesai',
        ]);

        $loan = Loan::with('book')->findOrFail($id);
        $oldStatus = $loan->status;
        $newStatus = $request->status;

        // Jika dibatalkan / ditolak / selesai dikembalikan, kembalikan stok barang
        if (in_array($newStatus, ['Ditolak', 'Selesai']) && !in_array($oldStatus, ['Ditolak', 'Selesai'])) {
            $loan->book->increment('stok', $loan->quantity);
            if ($newStatus === 'Selesai' && !$loan->return_date) {
                $loan->return_date = now()->toDateString();
            }
        }

        $loan->status = $newStatus;
        $loan->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Status peminjaman berhasil diperbarui menjadi ' . $newStatus,
            'data' => $loan->load('book')
        ], 200);
    }
}
