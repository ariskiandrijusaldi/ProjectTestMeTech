<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Book extends Model
{
    protected $fillable = [
        'category_id',
        'isbn',
        'title',
        'author',
        'publisher',
        'year',
        'synopsis',
        'cover',
        'rack_location',
        'stock_total',
        'stock_available',
    ];

    protected $casts = [
        'stock_total' => 'integer',
        'stock_available' => 'integer',
        'year' => 'integer',
    ];

    protected $appends = [
        'image_url',
        'is_available',
    ];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }

    public function loans(): HasMany
    {
        return $this->hasMany(Loan::class);
    }

    public function getImageUrlAttribute(): ?string
    {
        if (! empty($this->cover)) {
            if (str_starts_with($this->cover, 'http://') || str_starts_with($this->cover, 'https://')) {
                return $this->cover;
            }
            return url('storage/' . $this->cover);
        }
        return 'https://placehold.co/400x300?text=' . urlencode($this->title ?? 'Buku');
    }

    public function getIsAvailableAttribute(): bool
    {
        return (int) $this->stock_available > 0;
    }

    public function scopeSearch($query, ?string $term)
    {
        return $query->when($term, function ($q, $t) {
            $q->where(function ($sq) use ($t) {
                $sq->where('title', 'like', "%{$t}%")
                    ->orWhere('author', 'like', "%{$t}%")
                    ->orWhere('isbn', 'like', "%{$t}%")
                    ->orWhere('publisher', 'like', "%{$t}%");
            });
        });
    }
}