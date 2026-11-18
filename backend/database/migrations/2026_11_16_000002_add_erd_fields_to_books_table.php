<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('books', function (Blueprint $table) {
            $table->string('publisher')->nullable()->after('author');
            $table->integer('year')->nullable()->after('publisher');
            $table->text('synopsis')->nullable()->after('year');
            $table->string('cover')->nullable()->after('synopsis');
            $table->string('rack_location')->nullable()->after('cover');
            $table->integer('stock_total')->default(0)->after('stok');
            $table->integer('stock_available')->default(0)->after('stock_total');
        });
    }

    public function down(): void
    {
        Schema::table('books', function (Blueprint $table) {
            $table->dropColumn(['publisher', 'year', 'synopsis', 'cover', 'rack_location', 'stock_total', 'stock_available']);
        });
    }
};