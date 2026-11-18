<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(): JsonResponse
    {
        return response()->json(['data' => Category::orderBy('name')->get(['id', 'name'])]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate(['name' => ['required', 'string', 'max:100', 'unique:categories,name']]);

        return response()->json(['message' => 'Kategori ditambahkan.', 'data' => Category::create($data)], 201);
    }

    public function destroy(Request $request, Category $category): JsonResponse
    {
        if ($category->books()->exists()) {
            return response()->json([
                'message' => 'Kategori masih dipakai oleh buku. Tidak bisa dihapus.',
            ], 422);
        }

        $category->delete();

        return response()->json(['message' => 'Kategori berhasil dihapus.']);
    }

    public function users(): JsonResponse
    {
        $users = User::where('role', 'mahasiswa')
            ->orderBy('name')
            ->get(['id', 'name', 'email', 'nim']);

        return response()->json(['data' => $users]);
    }
}