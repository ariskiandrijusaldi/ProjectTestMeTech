<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoanStoreRequest;
use App\Models\Loan;
use App\Services\LoanService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class LoanController extends Controller
{
    protected LoanService $loanService;

    public function __construct(LoanService $loanService)
    {
        $this->loanService = $loanService;
    }

    public function store(LoanStoreRequest $request): JsonResponse
    {
        $result = $this->loanService->requestLoan($request->user(), (int) $request->input('book_id'));

        return response()->json([
            'status' => $result['ok'] ? 'success' : 'error',
            'message' => $result['message'],
            'data' => $result['loan'] ?? null,
        ], $result['code']);
    }

    public function myLoans(Request $request)
    {
        $user = $request->user();
        $tab = strtolower($request->query('tab') ?? $request->query('status') ?? 'all');

        $query = Loan::with('book.category')
            ->where('user_id', $user->id)
            ->latest();

        if (in_array($tab, ['active', 'aktif'])) {
            $query->whereIn('status', ['pending', 'approved']);
        } elseif (in_array($tab, ['history', 'riwayat'])) {
            $query->whereIn('status', ['rejected', 'returned']);
        } elseif ($request->filled('status') && ! in_array($request->status, ['all', 'Semua'])) {
            $query->where('status', $request->status);
        }

        $loans = $query->paginate($request->integer('per_page', 10));

        return response()->json([
            'status' => 'success',
            'tab' => $tab,
            'data' => $loans,
        ], 200);
    }

    public function updateStatus(Request $request, $id)
    {
        $loan = Loan::findOrFail($id);

        if ($loan->user_id !== $request->user()->id) {
            return response()->json([
                'status' => 'error',
                'message' => 'Bukan peminjaman Anda.',
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Endpoint ini hanya untuk admin.',
        ], 403);
    }

    public function destroy(Request $request, $id)
    {
        $result = $this->loanService->cancelOwnLoan((int) $id, $request->user());

        return response()->json([
            'status' => $result['ok'] ? 'success' : 'error',
            'message' => $result['message'],
        ], $result['code']);
    }
}