<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

/** Dipakai untuk store & update buku. */
class BookRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true; // akses sudah dijaga middleware role:admin
    }

    public function rules(): array
    {
        $book = $this->route('book'); // null saat store, model Book saat update

        return [
            'category_id' => ['required', 'exists:categories,id'],
            'isbn' => ['nullable', 'string', 'max:20', Rule::unique('books', 'isbn')->ignore($book?->id)],
            'title' => ['required', 'string', 'max:255'],
            'author' => ['required', 'string', 'max:150'],
            'publisher' => ['nullable', 'string', 'max:150'],
            'year' => ['nullable', 'integer', 'between:1900,'.date('Y')],
            'synopsis' => ['nullable', 'string'],
            'rack_location' => ['nullable', 'string', 'max:50'],
            'stock_total' => ['required', 'integer', 'min:0'],
            'cover' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ];
    }

    public function messages(): array
    {
        return [
            'category_id.required' => 'Kategori wajib dipilih.',
            'category_id.exists' => 'Kategori tidak ditemukan.',
            'isbn.string' => 'ISBN harus berupa teks.',
            'isbn.max' => 'ISBN maksimal 20 karakter.',
            'isbn.unique' => 'ISBN sudah digunakan buku lain.',
            'title.required' => 'Judul buku wajib diisi.',
            'title.max' => 'Judul buku maksimal 255 karakter.',
            'author.required' => 'Penulis wajib diisi.',
            'author.max' => 'Nama penulis maksimal 150 karakter.',
            'publisher.max' => 'Nama penerbit maksimal 150 karakter.',
            'year.integer' => 'Tahun harus berupa angka.',
            'year.between' => 'Tahun harus antara 1900 dan tahun sekarang.',
            'synopsis.string' => 'Sinopsis harus berupa teks.',
            'rack_location.max' => 'Lokasi rak maksimal 50 karakter.',
            'stock_total.required' => 'Stok total wajib diisi.',
            'stock_total.integer' => 'Stok total harus berupa angka.',
            'stock_total.min' => 'Stok total tidak boleh negatif.',
            'cover.image' => 'Cover harus berupa gambar.',
            'cover.mimes' => 'Cover harus berformat JPG, JPEG, PNG, atau WEBP.',
            'cover.max' => 'Ukuran cover maksimal 2 MB.',
        ];
    }
}
