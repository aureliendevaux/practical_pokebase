<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Library extends Model
{
    protected $fillable = [
        'uuid',
        'name',
        'slug',
        'public'
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
