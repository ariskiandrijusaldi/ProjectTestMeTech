<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoanStoreRequest;
use App\Http\Resources\LoanResource;
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

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return (new LoanResource($result['loan']))
            ->additional(['message' => $result['message']])
            ->response()
            ->setStatusCode($result['code']);
    }

    public function myLoans(Request $request)
    {
        $user = $request->user();
        $tab = strtolower($request->query('tab') ?? 'all');

        $query = Loan::with(['book.category', 'approver'])
            ->where('user_id', $user->id)
            ->latest('requested_at');

        if (in_array($tab, ['active', 'aktif'], true)) {
            $query->whereIn('status', ['pending', 'approved']);
        } elseif (in_array($tab, ['history', 'riwayat'], true)) {
            $query->whereIn('status', ['rejected', 'returned']);
        } elseif ($request->filled('status') && ! in_array($request->status, ['all', 'Semua'], true)) {
            $query->where('status', $request->status);
        }

        $loans = $query->paginate(min(100, max(1, $request->integer('per_page', 10))));

        return LoanResource::collection($loans)->additional([
            'message' => 'Daftar peminjaman berhasil diambil.',
            'tab' => $tab,
        ]);
    }

    public function show(Request $request, int $id)
    {
        $loan = Loan::with(['book.category', 'approver', 'user'])->find($id);

        if (! $loan) {
            return response()->json(['message' => 'Peminjaman tidak ditemukan.'], 404);
        }

        if ($loan->user_id !== $request->user()->id && ! $request->user()->isAdmin()) {
            return response()->json(['message' => 'Peminjaman tidak ditemukan.'], 404);
        }

        return (new LoanResource($loan))
            ->additional(['message' => 'Detail peminjaman berhasil diambil.']);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $result = $this->loanService->cancelOwnLoan($id, $request->user());

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return response()->json(['message' => $result['message']]);
    }
}
