<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\LoanResource;
use App\Models\Book;
use App\Models\Loan;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function __invoke(): JsonResponse
    {
        $latest = Loan::with(['user', 'book'])
            ->latest('requested_at')
            ->limit(5)
            ->get();

        return response()->json([
            'message' => 'Ringkasan dashboard berhasil diambil.',
            'data' => [
                'total_books' => Book::count(),                         // jumlah judul
                'total_stock' => (int) Book::sum('stock_total'),        // jumlah eksemplar
                'available_stock' => (int) Book::sum('stock_available'),
                'total_loans' => Loan::count(),
                'pending_loans' => Loan::where('status', 'pending')->count(),
                'active_loans' => Loan::where('status', 'approved')->count(),
                'overdue_loans' => Loan::overdue()->count(),
                'latest_loans' => LoanResource::collection($latest)->resolve(),
            ],
        ]);
    }
}
