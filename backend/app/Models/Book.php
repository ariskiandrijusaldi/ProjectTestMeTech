<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Book extends Model
{
    protected $fillable = [
        'category_id',
        'title',
        'author',
        'isbn',
        'stok',
        'description',
        'image',
    ];

    protected $appends = [
        'name',
        'stock',
        'image_url',
        'is_available',
    ];

    // Alias 'title' sebagai 'name' agar ramah untuk frontend
    public function getNameAttribute()
    {
        return $this->title;
    }

    // Alias 'stok' sebagai 'stock'
    public function getStockAttribute()
    {
        return (int) $this->stok;
    }

    // URL gambar lengkap atau placeholder
    public function getImageUrlAttribute()
    {
        if (!empty($this->image)) {
            if (str_starts_with($this->image, 'http://') || str_starts_with($this->image, 'https://')) {
                return $this->image;
            }
            return url('storage/' . $this->image);
        }

        return 'https://placehold.co/400x300?text=' . urlencode($this->title ?? 'Barang');
    }

    // Status ketersediaan
    public function getIsAvailableAttribute()
    {
        return $this->stok > 0;
    }

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function loans()
    {
        return $this->hasMany(Loan::class);
    }
}
