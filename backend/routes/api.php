<?php

use App\Http\Controllers\Api\Admin\BookController as AdminBookController;
use App\Http\Controllers\Api\Admin\CategoryController as AdminCategoryController;
use App\Http\Controllers\Api\Admin\DashboardController as AdminDashboardController;
use App\Http\Controllers\Api\Admin\LoanController as AdminLoanController;
use App\Http\Controllers\Api\Admin\UserController as AdminUserController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\LoanController;
use App\Http\Controllers\BookController;
use Illuminate\Support\Facades\Route;

// --- AUTH ---
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
});

// --- MAHASISWA / PUBLIK ---
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/books/popular', [BookController::class, 'popular']);
Route::get('/books', [BookController::class, 'index']);
Route::get('/books/{id}', [BookController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/loans', [LoanController::class, 'store']);
    Route::get('/my-loans', [LoanController::class, 'myLoans']);
    Route::get('/my-loans/{id}', [LoanController::class, 'show']);
    Route::delete('/my-loans/{id}', [LoanController::class, 'destroy']);
});

// --- ADMIN (role: admin) ---
Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, '__invoke']);

    Route::get('/loans', [AdminLoanController::class, 'index']);
    Route::get('/loans/overdue', [AdminLoanController::class, 'overdue']);
    Route::get('/loans/code/{code}', [AdminLoanController::class, 'loanByCode']);
    Route::get('/loans/{loan}', [AdminLoanController::class, 'show']);
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
    Route::put('/categories/{category}', [AdminCategoryController::class, 'update']);
    Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy']);

    Route::get('/users', [AdminUserController::class, 'index']);
});
