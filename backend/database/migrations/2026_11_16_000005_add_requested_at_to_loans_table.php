<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->timestamp('requested_at')->nullable()->after('status');
        });

        // Set existing records requested_at to created_at or loan_date
        DB::table('loans')->whereNull('requested_at')->update([
            'requested_at' => DB::raw("COALESCE(created_at, datetime('now'))"),
        ]);
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropColumn('requested_at');
        });
    }
};
