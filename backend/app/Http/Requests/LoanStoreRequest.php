<?php

namespace App\Http\Requests;

use App\Models\Book;
use App\Models\Loan;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;

class LoanStoreRequest extends FormRequest
{
    public function authorize(): bool
    {
        return (bool) $this->user();
    }

    public function rules(): array
    {
        return [
            'book_id' => ['required', 'exists:books,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'book_id.required' => 'Buku wajib dipilih.',
            'book_id.exists'   => 'Buku tidak ditemukan.',
        ];
    }

    protected function prepareForValidation(): void
    {
        //
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $user = $this->user();
            $bookId = $this->input('book_id');

            $book = Book::find($bookId);
            if (! $book) {
                return;
            }

            // Stok harus > 0
            if ((int) $book->stock_available < 1) {
                $validator->errors()->add('book_id', 'Stok buku tidak tersedia.');
                return;
            }

            // Tidak ada denda belum lunas
            $hasUnpaidFine = Loan::where('user_id', $user->id)
                ->where('fine_amount', '>', 0)
                ->where('fine_paid', false)
                ->exists();
            if ($hasUnpaidFine) {
                $validator->errors()->add('fine', 'Anda memiliki denda yang belum lunas. Silakan lunasi sebelum meminjam lagi.');
            }

            // Jumlah pinjaman aktif (pending + approved) < max_active_loans
            $activeLoans = Loan::where('user_id', $user->id)
                ->whereIn('status', ['pending', 'approved'])
                ->count();
            if ($activeLoans >= config('library.max_active_loans', 3)) {
                $validator->errors()->add('book_id', 'Anda sudah mencapai batas pinjaman aktif (' . config('library.max_active_loans', 3) . ').');
            }

            // Tidak ada pending/approved untuk buku yang sama
            $existing = Loan::where('user_id', $user->id)
                ->where('book_id', $bookId)
                ->whereIn('status', ['pending', 'approved'])
                ->exists();
            if ($existing) {
                $validator->errors()->add('book_id', 'Anda sudah memiliki pengajuan atau peminjaman aktif untuk buku ini.');
            }
        });
    }
}