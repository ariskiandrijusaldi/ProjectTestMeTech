<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Konfigurasi Peminjaman Perpustakaan
    |--------------------------------------------------------------------------
    */

    'loan_days' => (int) env('LIBRARY_LOAN_DAYS', 7),

    'fine_per_day' => (int) env('LIBRARY_FINE_PER_DAY', 1000),

    'max_active_loans' => (int) env('LIBRARY_MAX_ACTIVE_LOANS', 3),

];