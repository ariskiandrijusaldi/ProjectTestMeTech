<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;

class Loan extends Model
{
    protected $fillable = [
        'user_id',
        'approved_by',
        'book_id',
        'code',
        'loan_code',
        'quantity',
        'status',
        'requested_at',
        'approved_at',
        'loan_date',
        'due_date',
        'returned_at',
        'fine_amount',
        'fine_paid',
        'rejected_reason',
    ];

    protected $casts = [
        'quantity' => 'integer',
        'requested_at' => 'datetime',
        'loan_date' => 'date',
        'due_date' => 'date',
        'returned_at' => 'datetime',
        'approved_at' => 'datetime',
        'fine_amount' => 'decimal:2',
        'fine_paid' => 'boolean',
    ];

    protected $appends = [
        'status_label',
        'is_overdue',
        'late_days',
        'current_fine',
    ];

    public const STATUS_LABELS = [
        'pending' => 'Menunggu',
        'approved' => 'Disetujui',
        'rejected' => 'Ditolak',
        'returned' => 'Dikembalikan',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }

    public function approver(): BelongsTo
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function getStatusLabelAttribute(): string
    {
        return self::STATUS_LABELS[$this->status] ?? $this->status;
    }

    public function getIsOverdueAttribute(): bool
    {
        if (! in_array($this->status, ['approved', 'returned'], true)) {
            return false;
        }
        if ($this->status === 'returned') {
            return $this->lateDays > 0;
        }
        return $this->due_date ? $this->due_date->isBefore(Carbon::today()) : false;
    }

    public function getLateDaysAttribute(): int
    {
        if (! $this->due_date) {
            return 0;
        }
        $end = $this->returned_at ? Carbon::parse($this->returned_at) : Carbon::today();
        $due = Carbon::parse($this->due_date);
        $diff = $due->diffInDays($end);
        return $diff > 0 ? (int) $diff : 0;
    }

    public function getCurrentFineAttribute(): float
    {
        return (float) $this->lateDays * (float) config('library.fine_per_day', 1000);
    }

    public function scopeOverdue($query)
    {
        return $query->where('status', 'approved')
            ->where('due_date', '<', Carbon::today());
    }
}