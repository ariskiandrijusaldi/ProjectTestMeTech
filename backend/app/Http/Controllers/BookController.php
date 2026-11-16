<?php

namespace App\Http\Controllers;

use App\Http\Resources\BookResource;
use App\Models\Book;
use App\Models\Category;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BookController extends Controller
{
    /**
     * 1. Halaman Beranda: Dashboard summary
     */
    public function dashboard(Request $request): JsonResponse
    {
        $user = $request->user();
        $totalItems = Book::sum('stock_available');

        $popularItems = Book::with('category')
            ->withCount('loans')
            ->orderBy('loans_count', 'desc')
            ->take(6)
            ->get();

        $categories = Category::all();

        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => [
                    'name' => $user?->name ?? 'Mahasiswa',
                    'greeting' => 'Semangat beraktivitas di kampus!',
                ],
                'total_barang' => (int) $totalItems,
                'popular_items' => BookResource::collection($popularItems),
                'categories' => $categories,
            ],
        ], 200);
    }

    /**
     * 2. Halaman Beranda: Daftar Barang/Buku Populer
     */
    public function popular()
    {
        $books = Book::with('category')
            ->withCount('loans')
            ->orderBy('loans_count', 'desc')
            ->take(6)
            ->get();

        return BookResource::collection($books);
    }

    /**
     * 3. Halaman Daftar Buku: Pencarian (judul/penulis/isbn) & Filter Kategori (dengan pagination)
     */
    public function index(Request $request)
    {
        $books = Book::with('category')
            ->search($request->query('search'))
            ->when($request->filled('category_id') && ! in_array($request->category_id, ['all', '0', 'Semua'], true),
                fn ($q) => $q->where('category_id', $request->category_id))
            ->when($request->filled('category') && strtolower($request->category) !== 'semua', function ($q) use ($request) {
                $categoryName = $request->category;
                $q->whereHas('category', function ($sub) use ($categoryName) {
                    $sub->where('name', 'like', "%{$categoryName}%")
                        ->orWhere('slug', 'like', "%{$categoryName}%");
                });
            })
            ->latest()
            ->paginate($request->integer('per_page', 10));

        return BookResource::collection($books);
    }

    /**
     * 4. Halaman Pengajuan Peminjaman: Detail Buku Berdasarkan ID
     */
    public function show($id)
    {
        $book = Book::with('category')->find($id);

        if (! $book) {
            return response()->json([
                'status' => 'error',
                'message' => 'Buku tidak ditemukan.',
            ], 404);
        }

        return new BookResource($book);
    }
}
