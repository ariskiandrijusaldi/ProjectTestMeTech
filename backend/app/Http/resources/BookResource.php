<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BookResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'category'        => $this->whenLoaded('category', fn () => [
                'id' => $this->category->id, 'name' => $this->category->name,
            ]),
            'category_id'     => $this->category_id,
            'isbn'            => $this->isbn,
            'title'           => $this->title,
            'author'          => $this->author,
            'publisher'       => $this->publisher,
            'year'            => $this->year,
            'synopsis'        => $this->synopsis,
            'cover_url'       => $this->cover ? asset('storage/' . $this->cover) : null,
            'rack_location'   => $this->rack_location,
            'stock_total'     => $this->stock_total,
            'stock_available' => $this->stock_available,
        ];
    }
}
