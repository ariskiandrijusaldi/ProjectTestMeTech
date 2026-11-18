<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;

class CategoryController extends Controller
{
    public function index()
    {
        return response()->json([
            'message' => 'Daftar kategori berhasil diambil.',
            'data' => Category::orderBy('name')->get(['id', 'name']),
        ]);
    }
}
