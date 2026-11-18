<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\LoanController;
use App\Http\Controllers\Api\Admin\LoanController as AdminLoanController;
use App\Http\Controllers\Api\Admin\BookController as AdminBookController;
use App\Http\Controllers\Api\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Api\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\BookController;

// --- AUTH ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
Route::get('/me', [AuthController::class, 'me'])->middleware('auth:sanctum');

// --- USER (mahasiswa) ---
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/books', [BookController::class, 'index']);
Route::get('/books/popular', [BookController::class, 'popular']);
Route::get('/books/{id}', [BookController::class, 'show']);
Route::get('/items', [BookController::class, 'index']);
Route::get('/items/popular', [BookController::class, 'popular']);
Route::get('/items/{id}', [BookController::class, 'show']);

Route::post('/loans', [LoanController::class, 'store'])->middleware('auth:sanctum');
Route::get('/loans/me', [LoanController::class, 'myLoans'])->middleware('auth:sanctum');
Route::patch('/loans/{id}/status', [LoanController::class, 'updateStatus'])->middleware('auth:sanctum');
Route::delete('/my-loans/{id}', [LoanController::class, 'destroy'])->middleware('auth:sanctum');

// --- ADMIN (role: admin) ---
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, '__invoke']);
    Route::get('/loans', [AdminLoanController::class, 'index']);
    Route::get('/loans/{loan}', [AdminLoanController::class, 'show']);
    Route::get('/loans/code/{code}', [AdminLoanController::class, 'loanByCode']);
    Route::get('/loans/overdue', [AdminLoanController::class, 'overdue']);
    Route::patch('/loans/{loan}/approve', [AdminLoanController::class, 'approve']);
    Route::patch('/loans/{loan}/reject', [AdminLoanController::class, 'reject']);
    Route::patch('/loans/{loan}/return', [AdminLoanController::class, 'returnBook']);
    Route::patch('/loans/{loan}/pay-fine', [AdminLoanController::class, 'payFine']);

    Route::get('/books', [AdminBookController::class, 'index']);
    Route::get('/books/{book}', [AdminBookController::class, 'show']);
    Route::post('/books', [AdminBookController::class, 'store']);
    Route::put('/books/{book}', [AdminBookController::class, 'update']);
    Route::delete('/books/{book}', [AdminBookController::class, 'destroy']);

    Route::get('/categories', [AdminCategoryController::class, 'index']);
    Route::post('/categories', [AdminCategoryController::class, 'store']);
    Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy']);

    Route::get('/users', [AdminCategoryController::class, 'users']);
});