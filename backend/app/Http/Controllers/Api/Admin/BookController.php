<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\BookRequest;
use App\Http\Resources\BookResource;
use App\Models\Book;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class BookController extends Controller
{
    // GET /api/admin/books?search=&category_id=&per_page=
    public function index(Request $request)
    {
        $books = Book::with('category')
            ->search($request->query('search'))
            ->when($request->query('category_id'), fn ($q, $id) => $q->where('category_id', $id))
            ->orderBy('title')
            ->paginate($request->integer('per_page', 10));

        return BookResource::collection($books);
    }

    // GET /api/admin/books/{book}
    public function show(Book $book): BookResource
    {
        return new BookResource($book->load('category'));
    }

    // POST /api/admin/books  (multipart/form-data kalau ada cover)
    public function store(BookRequest $request): JsonResponse
    {
        $data = $request->validated();
        unset($data['cover']);

        if ($request->hasFile('cover')) {
            $data['cover'] = $request->file('cover')->store('covers', 'public');
        }

        $data['stock_available'] = $data['stock_total'];

        $book = Book::create($data);

        return (new BookResource($book->load('category')))
            ->additional(['message' => 'Buku berhasil ditambahkan.'])
            ->response()
            ->setStatusCode(201);
    }

    // PUT /api/admin/books/{book}
    // Catatan multipart: kirim POST dengan field _method=PUT (batasan PHP untuk form-data).
    public function update(BookRequest $request, Book $book)
    {
        return DB::transaction(function () use ($request, $book) {
            $book = Book::lockForUpdate()->findOrFail($book->id);

            $data = $request->validated();
            unset($data['cover']);

            // eksemplar yang sedang keluar = total - tersedia
            $borrowed = $book->stock_total - $book->stock_available;

            if ($data['stock_total'] < $borrowed) {
                return response()->json([
                    'message' => "Stok total tidak boleh kurang dari jumlah buku yang sedang dipinjam ({$borrowed}).",
                ], 422);
            }

            $data['stock_available'] = $data['stock_total'] - $borrowed;

            if ($request->hasFile('cover')) {
                if ($book->cover) {
                    Storage::disk('public')->delete($book->cover);
                }
                $data['cover'] = $request->file('cover')->store('covers', 'public');
            }

            $book->update($data);

            return (new BookResource($book->fresh('category')))
                ->additional(['message' => 'Buku berhasil diperbarui.']);
        });
    }

    // DELETE /api/admin/books/{book}
    public function destroy(Book $book): JsonResponse
    {
        if ($book->loans()->exists()) {
            return response()->json([
                'message' => 'Buku memiliki riwayat peminjaman dan tidak bisa dihapus.',
            ], 422);
        }

        if ($book->cover) {
            Storage::disk('public')->delete($book->cover);
        }

        $book->delete();

        return response()->json(['message' => 'Buku berhasil dihapus.']);
    }
}
