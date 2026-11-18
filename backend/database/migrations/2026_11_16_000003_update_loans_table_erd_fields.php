<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->string('code')->unique()->nullable()->after('loan_code');
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete()->after('user_id');
            $table->timestamp('approved_at')->nullable()->after('approved_by');
            $table->date('due_date')->nullable()->after('loan_date');
            $table->timestamp('returned_at')->nullable()->after('due_date');
            $table->decimal('fine_amount', 12, 2)->default(0)->after('returned_at');
            $table->boolean('fine_paid')->default(0)->after('fine_amount');
            $table->text('rejected_reason')->nullable()->after('fine_paid');
            $table->enum('status', ['pending', 'approved', 'rejected', 'returned'])->default('pending')->change();
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropColumn(['code', 'approved_by', 'approved_at', 'due_date', 'returned_at', 'fine_amount', 'fine_paid', 'rejected_reason']);
            $table->enum('status', ['Menunggu Persetujuan', 'Disetujui', 'Ditolak', 'Selesai'])->default('Menunggu Persetujuan')->change();
        });
    }
};