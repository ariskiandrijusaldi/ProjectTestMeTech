<?php

namespace Database\Seeders;

use App\Models\Book;
use App\Models\Category;
use App\Models\Loan;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        // 1. Admin
        $admin = User::firstOrCreate(
            ['email' => 'admin@perpustakaan.ac.id'],
            [
                'name' => 'Administrator',
                'nim' => null,
                'password' => Hash::make('admin123'),
                'role' => 'admin',
            ]
        );

        // 2. Mahasiswa
        $mahasiswa = [];
        $mahasiswaData = [
            ['email' => 'aurelia@kampus.ac.id', 'nim' => '2301001', 'name' => 'Aurelia', 'password' => 'password123'],
            ['email' => 'budi@kampus.ac.id', 'nim' => '2301002', 'name' => 'Budi Santoso', 'password' => 'password123'],
            ['email' => 'citra@kampus.ac.id', 'nim' => '2301003', 'name' => 'Citra Dewi', 'password' => 'password123'],
        ];
        foreach ($mahasiswaData as $data) {
            $mahasiswa[] = User::firstOrCreate(
                ['email' => $data['email']],
                [
                    'name' => $data['name'],
                    'nim' => $data['nim'],
                    'password' => Hash::make($data['password']),
                    'role' => 'mahasiswa',
                ]
            );
        }

        // 3. Kategori
        $kategoriData = ['Elektronik', 'Peralatan', 'Sains', 'Sastra', 'Teknologi'];
        $categories = [];
        foreach ($kategoriData as $name) {
            $categories[] = Category::firstOrCreate(
                ['slug' => StrSlug($name)],
                ['name' => $name]
            );
        }

        // 4. Buku
        $booksData = [
            ['title' => 'Proyektor', 'author' => 'Inventaris Kampus', 'category' => 'Elektronik', 'stock' => 10, 'isbn' => '978-1000000001'],
            ['title' => 'Laptop', 'author' => 'Inventaris Kampus', 'category' => 'Elektronik', 'stock' => 8, 'isbn' => '978-1000000002'],
            ['title' => 'Kamera', 'author' => 'Inventaris Kampus', 'category' => 'Elektronik', 'stock' => 5, 'isbn' => '978-1000000003'],
            ['title' => 'Speaker', 'author' => 'Inventaris Kampus', 'category' => 'Peralatan', 'stock' => 7, 'isbn' => '978-1000000004'],
            ['title' => 'Mic Wireless', 'author' => 'Inventaris Kampus', 'category' => 'Elektronik', 'stock' => 15, 'isbn' => '978-1000000005'],
            ['title' => 'Tripod Kamera', 'author' => 'Inventaris Kampus', 'category' => 'Peralatan', 'stock' => 12, 'isbn' => '978-1000000006'],
            ['title' => 'Pointer Presentasi', 'author' => 'Inventaris Kampus', 'category' => 'Peralatan', 'stock' => 20, 'isbn' => '978-1000000007'],
            ['title' => 'Kabel HDMI 15m', 'author' => 'Inventaris Kampus', 'category' => 'Peralatan', 'stock' => 25, 'isbn' => '978-1000000008'],
            ['title' => 'Terminal Colokan Kabel', 'author' => 'Inventaris Kampus', 'category' => 'Peralatan', 'stock' => 18, 'isbn' => '978-1000000009'],
            ['title' => 'Basis Data Dasar', 'author' => 'Siti Rahma', 'category' => 'Teknologi', 'stock' => 8, 'isbn' => '978-1000000010'],
            ['title' => 'Pemrograman Flutter', 'author' => 'Andi Wijaya', 'category' => 'Teknologi', 'stock' => 10, 'isbn' => '978-1000000011'],
            ['title' => 'Fisika Dasar', 'author' => 'Budi Santoso', 'category' => 'Sains', 'stock' => 5, 'isbn' => '978-1000000012'],
            ['title' => 'Kumpulan Cerpen Kampus', 'author' => 'Rina Maharani', 'category' => 'Sastra', 'stock' => 7, 'isbn' => '978-1000000013'],
        ];

        $createdBooks = [];
        foreach ($booksData as $item) {
            $cat = $categories[array_search($item['category'], $kategoriData)];
            $createdBooks[$item['title']] = Book::updateOrCreate(
                ['isbn' => $item['isbn']],
                [
                    'category_id' => $cat->id,
                    'title' => $item['title'],
                    'author' => $item['author'],
                    'stock_total' => $item['stock'],
                    'stock_available' => $item['stock'],
                    'cover' => 'https://placehold.co/400x300?text=' . urlencode($item['title']),
                ]
            );
        }

        // 5. Loan contoh di berbagai status
        $aurelia = $mahasiswa[0];
        $budi = $mahasiswa[1];

        // Pending
        Loan::firstOrCreate(
            ['code' => 'PJ25111601'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Proyektor']->id,
                'quantity' => 1,
                'status' => 'pending',
                'loan_date' => Carbon::today(),
                'due_date' => null,
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        // Approved (aktif dipinjam)
        Loan::firstOrCreate(
            ['code' => 'PJ25111602'],
            [
                'user_id' => $budi->id,
                'book_id' => $createdBooks['Laptop']->id,
                'quantity' => 1,
                'status' => 'approved',
                'loan_date' => Carbon::today()->subDays(2),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(2),
                'due_date' => Carbon::today()->addDays(5),
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        // Approved terlambat (untuk uji denda)
        Loan::firstOrCreate(
            ['code' => 'PJ25111603'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Kamera']->id,
                'quantity' => 1,
                'status' => 'approved',
                'loan_date' => Carbon::today()->subDays(10),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(10),
                'due_date' => Carbon::today()->subDays(3),
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        // Returned dengan denda
        Loan::firstOrCreate(
            ['code' => 'PJ25111604'],
            [
                'user_id' => $budi->id,
                'book_id' => $createdBooks['Speaker']->id,
                'quantity' => 1,
                'status' => 'returned',
                'loan_date' => Carbon::today()->subDays(10),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(10),
                'due_date' => Carbon::today()->subDays(8),
                'returned_at' => Carbon::today()->subDays(5),
                'fine_amount' => 3000,
                'fine_paid' => false,
                'rejected_reason' => null,
            ]
        );

        // Rejected
        Loan::firstOrCreate(
            ['code' => 'PJ25111605'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Mic Wireless']->id,
                'quantity' => 1,
                'status' => 'rejected',
                'loan_date' => Carbon::today()->subDays(5),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(5),
                'due_date' => null,
                'fine_amount' => 0,
                'fine_paid' => true,
                'rejected_reason' => 'Buku sedang dalam perbaikan.',
            ]
        );
    }
}

function StrSlug(string $name): string
{
    return strtolower(str_replace(' ', '-', $name));
}