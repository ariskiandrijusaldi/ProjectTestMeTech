<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Category;
use App\Models\Book;
use App\Models\Loan;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database with exact data matching the UI mockup.
     */
    public function run(): void
    {
        // 1. User Aurelia (sesuai "Halo, Aurelia 👋" di Screen 2)
        $user = User::firstOrCreate(
            ['email' => 'aurelia@kampus.ac.id'],
            [
                'name' => 'Aurelia',
                'password' => Hash::make('password123'),
            ]
        );

        // 2. Kategori Barang (sesuai Chip Filter di Screen 3: Elektronik, Peralatan)
        $catElektronik = Category::firstOrCreate(
            ['slug' => 'elektronik'],
            ['name' => 'Elektronik']
        );

        $catPeralatan = Category::firstOrCreate(
            ['slug' => 'peralatan'],
            ['name' => 'Peralatan']
        );

        // 3. Data Barang / Inventaris (sesuai Screen 2, 3, dan 4)
        $items = [
            [
                'title' => 'Proyektor',
                'author' => 'Inventaris Kampus',
                'category_id' => $catElektronik->id,
                'stok' => 10,
                'description' => 'Proyektor untuk kegiatan perkuliahan dan seminar.',
                'image' => 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500',
            ],
            [
                'title' => 'Laptop',
                'author' => 'Inventaris Kampus',
                'category_id' => $catElektronik->id,
                'stok' => 8,
                'description' => 'Laptop inventaris untuk kegiatan praktikum, riset, dan presentasi mahasiswa.',
                'image' => 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500',
            ],
            [
                'title' => 'Kamera',
                'author' => 'Inventaris Kampus',
                'category_id' => $catPeralatan->id,
                'stok' => 5,
                'description' => 'Kamera DSLR profesional untuk dokumentasi acara dan kegiatan kampus.',
                'image' => 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
            ],
            [
                'title' => 'Speaker',
                'author' => 'Inventaris Kampus',
                'category_id' => $catPeralatan->id,
                'stok' => 7,
                'description' => 'Speaker portable untuk kegiatan seminar, perkuliahan, dan rapat.',
                'image' => 'https://images.unsplash.com/photo-1545454675-3531b543be5d?w=500',
            ],
            [
                'title' => 'Mic Wireless',
                'author' => 'Inventaris Kampus',
                'category_id' => $catElektronik->id,
                'stok' => 15,
                'description' => 'Mikrofon wireless ganda untuk presentasi aula dan ruang rapat.',
                'image' => 'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?w=500',
            ],
            [
                'title' => 'Tripod Kamera',
                'author' => 'Inventaris Kampus',
                'category_id' => $catPeralatan->id,
                'stok' => 12,
                'description' => 'Tripod kokoh untuk kamera video dan foto dokumentasi kegiatan.',
                'image' => 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=500',
            ],
            [
                'title' => 'Pointer Presentasi',
                'author' => 'Inventaris Kampus',
                'category_id' => $catElektronik->id,
                'stok' => 20,
                'description' => 'Laser pointer nirkabel dengan tombol kontrol slide presentasi.',
                'image' => 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
            ],
            [
                'title' => 'Kabel HDMI 15m',
                'author' => 'Inventaris Kampus',
                'category_id' => $catPeralatan->id,
                'stok' => 25,
                'description' => 'Kabel HDMI high-speed panjang untuk menghubungkan laptop ke proyektor.',
                'image' => 'https://images.unsplash.com/photo-1544652478-6653e09f18a2?w=500',
            ],
            [
                'title' => 'Terminal Colokan Kabel',
                'author' => 'Inventaris Kampus',
                'category_id' => $catPeralatan->id,
                'stok' => 18,
                'description' => 'Stop kontak kabel rol panjang 10 meter untuk acara kampus.',
                'image' => 'https://images.unsplash.com/photo-1588508065123-287b28e013da?w=500',
            ],
        ];

        $createdBooks = [];
        foreach ($items as $item) {
            $createdBooks[$item['title']] = Book::updateOrCreate(
                ['title' => $item['title']],
                $item
            );
        }

        // 4. Data Peminjaman (sesuai Screen 5: Status Peminjaman)
        // Card 1: Proyektor | #PJ250701 | Menunggu Persetujuan | Diajukan pada: 1 Jul 2025
        if (isset($createdBooks['Proyektor'])) {
            Loan::updateOrCreate(
                ['loan_code' => '#PJ250701'],
                [
                    'user_id' => $user->id,
                    'book_id' => $createdBooks['Proyektor']->id,
                    'quantity' => 1,
                    'status' => 'Menunggu Persetujuan',
                    'loan_date' => '2025-07-01',
                    'return_date' => null,
                ]
            );
        }

        // Card 2: Laptop | #PJ250630 | Disetujui | Dikembalikan pada: 30 Jun 2025
        if (isset($createdBooks['Laptop'])) {
            Loan::updateOrCreate(
                ['loan_code' => '#PJ250630'],
                [
                    'user_id' => $user->id,
                    'book_id' => $createdBooks['Laptop']->id,
                    'quantity' => 1,
                    'status' => 'Disetujui',
                    'loan_date' => '2025-06-25',
                    'return_date' => '2025-06-30',
                ]
            );
        }

        // Card 3: Speaker | #PJ250615 | Selesai (Untuk tab Riwayat)
        if (isset($createdBooks['Speaker'])) {
            Loan::updateOrCreate(
                ['loan_code' => '#PJ250615'],
                [
                    'user_id' => $user->id,
                    'book_id' => $createdBooks['Speaker']->id,
                    'quantity' => 1,
                    'status' => 'Selesai',
                    'loan_date' => '2025-06-10',
                    'return_date' => '2025-06-15',
                ]
            );
        }
    }
}
