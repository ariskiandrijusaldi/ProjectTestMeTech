<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\RejectLoanRequest;
use App\Http\Resources\LoanResource;
use App\Models\Loan;
use App\Services\LoanService;
use Illuminate\Http\Request;

class LoanController extends Controller
{
    protected LoanService $loanService;

    public function __construct(LoanService $loanService)
    {
        $this->loanService = $loanService;
    }

    public function index(Request $request)
    {
        $status = $request->query('status', 'pending');

        $loans = Loan::with(['user', 'book'])
            ->when($status === 'history', fn ($q) => $q->where('status', '!=', 'pending'))
            ->when($status === 'overdue', fn ($q) => $q->overdue())
            ->when(in_array($status, ['pending', 'approved', 'rejected', 'returned'], true),
                fn ($q) => $q->where('status', $status))
            ->when($request->query('search'), function ($q, $term) {
                $q->where(function ($w) use ($term) {
                    $w->where('code', 'like', "%{$term}%")
                      ->orWhere('loan_code', 'like', "%{$term}%")
                      ->orWhereHas('user', fn ($u) => $u->where('name', 'like', "%{$term}%")
                                                            ->orWhere('nim', 'like', "%{$term}%")
                                                            ->orWhere('email', 'like', "%{$term}%"))
                      ->orWhereHas('book', fn ($b) => $b->where('title', 'like', "%{$term}%"));
                });
            })
            ->latest('requested_at')
            ->paginate($request->integer('per_page', 10));

        return LoanResource::collection($loans)->additional([
            'meta_counts' => [
                'pending' => Loan::where('status', 'pending')->count(),
            ],
        ]);
    }

    public function show(Loan $loan): LoanResource
    {
        return new LoanResource($loan->load(['user', 'book', 'approver']));
    }

    public function loanByCode(string $code)
    {
        $loan = Loan::with(['user', 'book'])->where('code', $code)->first();

        if (! $loan) {
            return response()->json(['message' => 'Kode peminjaman tidak ditemukan.'], 404);
        }

        return new LoanResource($loan->load(['approver']));
    }

    public function overdue(Request $request)
    {
        $loans = Loan::with(['user', 'book'])->overdue()->latest('due_date')->paginate($request->integer('per_page', 10));

        return LoanResource::collection($loans);
    }

    public function approve(Request $request, Loan $loan)
    {
        $result = $this->loanService->approveLoan((int) $loan->id, $request->user());

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return (new LoanResource($result['loan']))
            ->additional(['message' => $result['message']]);
    }

    public function reject(RejectLoanRequest $request, Loan $loan)
    {
        $result = $this->loanService->rejectLoan((int) $loan->id, $request->user(), $request->input('reason'));

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return (new LoanResource($result['loan']))
            ->additional(['message' => $result['message']]);
    }

    public function returnBook(Request $request, Loan $loan)
    {
        $result = $this->loanService->returnLoan((int) $loan->id, $request->user());

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return (new LoanResource($result['loan']))
            ->additional(['message' => $result['message']]);
    }

    public function payFine(Request $request, Loan $loan)
    {
        $result = $this->loanService->payFine((int) $loan->id, $request->user());

        if (! $result['ok']) {
            return response()->json(['message' => $result['message']], $result['code']);
        }

        return (new LoanResource($result['loan']))
            ->additional(['message' => $result['message']]);
    }
}