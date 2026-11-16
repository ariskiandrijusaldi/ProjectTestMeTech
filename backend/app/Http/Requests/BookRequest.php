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
            'category_id'   => ['required', 'exists:categories,id'],
            'isbn'          => ['nullable', 'string', 'max:20', Rule::unique('books', 'isbn')->ignore($book?->id)],
            'title'         => ['required', 'string', 'max:255'],
            'author'        => ['required', 'string', 'max:150'],
            'publisher'     => ['nullable', 'string', 'max:150'],
            'year'          => ['nullable', 'integer', 'between:1900,' . date('Y')],
            'synopsis'      => ['nullable', 'string'],
            'rack_location' => ['nullable', 'string', 'max:50'],
            'stock_total'   => ['required', 'integer', 'min:0'],
            'cover'         => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048'],
        ];
    }
}
