<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Loan extends Model
{
    protected $fillable = [
        'user_id',
        'book_id',
        'loan_code',
        'quantity',
        'status',
        'loan_date',
        'return_date',
    ];

    protected $casts = [
        'loan_date' => 'date',
        'return_date' => 'date',
        'quantity' => 'integer',
    ];

    protected $appends = [
        'loan_date_formatted',
        'return_date_formatted',
    ];

    // Format tanggal ramah tampilan UI (Contoh: "1 Jul 2025")
    public function getLoanDateFormattedAttribute()
    {
        return $this->loan_date ? $this->loan_date->translatedFormat('j M Y') : null;
    }

    public function getReturnDateFormattedAttribute()
    {
        return $this->return_date ? $this->return_date->translatedFormat('j M Y') : null;
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function book()
    {
        return $this->belongsTo(Book::class);
    }
}
