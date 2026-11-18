<?php

use App\Models\User;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // --- personal_access_tokens: tokenable_type harus terisi agar Sanctum
        // dapat menemukan pemilik token saat autentikasi Bearer.
        DB::table('personal_access_tokens')
            ->whereNull('tokenable_type')
            ->update(['tokenable_type' => User::class]);

        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->string('tokenable_type')->nullable(false)->change();
        });

        // --- categories: samakan dengan ERD (id, name, timestamps).
        Schema::table('categories', function (Blueprint $table) {
            $table->dropUnique(['slug']);
        });

        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn('slug');
        });

        // --- books: buang kolom lama yang tidak dipakai lagi.
        Schema::table('books', function (Blueprint $table) {
            $table->dropColumn(['stok', 'description', 'image']);
        });

        // --- loans: backfill code dari loan_code sebelum kolom lama dihapus,
        // lalu jadikan code wajib dan unik.
        DB::table('loans')
            ->whereNull('code')
            ->update(['code' => DB::raw('loan_code')]);

        Schema::table('loans', function (Blueprint $table) {
            $table->dropUnique(['loan_code']);
            $table->dropUnique(['code']);
        });

        Schema::table('loans', function (Blueprint $table) {
            $table->dropColumn(['loan_code', 'quantity', 'loan_date', 'return_date']);
        });

        Schema::table('loans', function (Blueprint $table) {
            $table->string('code')->nullable(false)->change();
            $table->unique('code');
        });
    }

    public function down(): void
    {
        Schema::table('loans', function (Blueprint $table) {
            $table->dropUnique(['code']);
            $table->string('code')->nullable()->change();
            $table->string('loan_code')->nullable()->unique()->after('book_id');
            $table->integer('quantity')->default(1)->after('loan_code');
            $table->date('loan_date')->nullable()->after('status');
            $table->date('return_date')->nullable()->after('due_date');
        });

        Schema::table('books', function (Blueprint $table) {
            $table->integer('stok')->default(0)->after('isbn');
            $table->text('description')->nullable()->after('stok');
            $table->string('image')->nullable()->after('description');
        });

        Schema::table('categories', function (Blueprint $table) {
            $table->string('slug')->nullable()->unique()->after('name');
        });

        Schema::table('personal_access_tokens', function (Blueprint $table) {
            $table->string('tokenable_type')->nullable()->change();
        });
    }
};
