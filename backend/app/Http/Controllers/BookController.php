<?php

namespace App\Http\Controllers;

use App\Models\Book;
use App\Models\Category;
use Illuminate\Http\Request;

class BookController extends Controller
{
    /**
     * 1. Halaman Beranda: Dashboard summary (User, Total Barang, Barang Populer)
     */
    public function dashboard(Request $request)
    {
        $totalItems = Book::sum('stok');
        
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
                    'name' => 'Aurelia',
                    'greeting' => 'Semangat beraktivitas di kampus!'
                ],
                'total_barang' => $totalItems > 0 ? (int) $totalItems : 120,
                'popular_items' => $popularItems,
                'categories' => $categories
            ]
        ], 200);
    }

    /**
     * 2. Halaman Beranda: Daftar Barang Populer
     */
    public function popular()
    {
        $books = Book::with('category')
            ->withCount('loans')
            ->orderBy('loans_count', 'desc')
            ->take(6)
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $books
        ], 200);
    }

    /**
     * 3. Halaman Daftar Barang: Pencarian & Filter Kategori
     */
    public function index(Request $request)
    {
        $query = Book::with('category');

        // Filter berdasarkan kata kunci pencarian (judul / nama barang, deskripsi)
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('author', 'like', "%{$search}%");
            });
        }

        // Filter berdasarkan ID kategori
        if ($request->filled('category_id') && !in_array($request->category_id, ['all', '0', 'Semua'])) {
            $query->where('category_id', $request->category_id);
        }

        // Filter berdasarkan nama kategori (contoh: "Elektronik", "Peralatan")
        if ($request->filled('category') && strtolower($request->category) !== 'semua') {
            $categoryName = $request->category;
            $query->whereHas('category', function($q) use ($categoryName) {
                $q->where('name', 'like', "%{$categoryName}%")
                  ->orWhere('slug', 'like', "%{$categoryName}%");
            });
        }

        $books = $query->latest()->get();

        return response()->json([
            'status' => 'success',
            'total' => $books->count(),
            'data' => $books
        ], 200);
    }

    /**
     * 4. Halaman Pengajuan Peminjaman: Detail Barang Berdasarkan ID
     */
    public function show($id)
    {
        $book = Book::with('category')->find($id);

        if (!$book) {
            return response()->json([
                'status' => 'error',
                'message' => 'Barang tidak ditemukan'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data' => $book
        ], 200);
    }
}
