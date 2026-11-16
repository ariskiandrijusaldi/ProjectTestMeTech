<?php

namespace App\Http\Resources;

use App\Models\Loan;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class LoanResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'code'            => $this->code,
            'status'          => $this->status,
            'status_label'    => Loan::STATUS_LABELS[$this->status] ?? $this->status,
            'requested_at'    => $this->requested_at?->toIso8601String(),
            'approved_at'     => $this->approved_at?->toIso8601String(),
            'due_date'        => $this->due_date?->toDateString(),
            'returned_at'     => $this->returned_at?->toIso8601String(),
            'is_overdue'      => $this->isOverdue(),
            'late_days'       => $this->lateDays(),
            'fine_amount'     => $this->current_fine,
            'fine_paid'       => $this->fine_paid,
            'rejected_reason' => $this->rejected_reason,
            'user'            => new UserResource($this->whenLoaded('user')),
            'book'            => new BookResource($this->whenLoaded('book')),
            'approved_by'     => new UserResource($this->whenLoaded('approver')),
        ];
    }
}
