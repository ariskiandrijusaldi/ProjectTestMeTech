<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\LoanController;

// --- USER & AUTH ---
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// --- 1. HALAMAN BERANDA ---
Route::get('/dashboard', [BookController::class, 'dashboard']);

// --- 2. HALAMAN DAFTAR BARANG & KATEGORI ---
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/books', [BookController::class, 'index']);
Route::get('/books/popular', [BookController::class, 'popular']);
Route::get('/books/{id}', [BookController::class, 'show']);

// Alias route menggunakan kata "items" agar fleksibel untuk Flutter
Route::get('/items', [BookController::class, 'index']);
Route::get('/items/popular', [BookController::class, 'popular']);
Route::get('/items/{id}', [BookController::class, 'show']);

// --- 3. HALAMAN PENGAJUAN & STATUS PEMINJAMAN ---
Route::post('/loans', [LoanController::class, 'store']);
Route::get('/loans/me', [LoanController::class, 'myLoans']);
Route::patch('/loans/{id}/status', [LoanController::class, 'updateStatus']);
