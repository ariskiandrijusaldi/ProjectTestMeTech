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
        $admin = User::updateOrCreate(
            ['email' => 'admin@perpustakaan.ac.id'],
            [
                'name' => 'Administrator',
                'nim' => null,
                'password' => Hash::make('admin123'),
                'role' => 'admin',
            ]
        );

        $mahasiswaData = [
            ['email' => 'aurelia@kampus.ac.id', 'nim' => '2301001', 'name' => 'Aurelia'],
            ['email' => 'budi@kampus.ac.id', 'nim' => '2301002', 'name' => 'Budi Santoso'],
            ['email' => 'citra@kampus.ac.id', 'nim' => '2301003', 'name' => 'Citra Dewi'],
        ];

        $mahasiswa = [];
        foreach ($mahasiswaData as $data) {
            $mahasiswa[] = User::updateOrCreate(
                ['email' => $data['email']],
                [
                    'name' => $data['name'],
                    'nim' => $data['nim'],
                    'password' => Hash::make('password123'),
                    'role' => 'mahasiswa',
                ]
            );
        }

        $kategoriData = ['Elektronik', 'Peralatan', 'Sains', 'Sastra', 'Teknologi'];
        $categories = [];
        foreach ($kategoriData as $name) {
            $categories[$name] = Category::firstOrCreate(['name' => $name]);
        }

        $booksData = [
            [
                'title' => 'Dasar-Dasar Elektronika',
                'author' => 'Albert Paul Malvino',
                'category' => 'Elektronik',
                'stock' => 10,
                'isbn' => '978-1000000001',
                'publisher' => 'Erlangga',
                'year' => 2016,
                'rack' => 'E-01',
                'synopsis' => 'Pengantar lengkap tentang komponen, rangkaian, dan prinsip dasar elektronika untuk mahasiswa teknik.',
            ],
            [
                'title' => 'Rangkaian Listrik',
                'author' => 'James W. Nilsson',
                'category' => 'Elektronik',
                'stock' => 8,
                'isbn' => '978-1000000002',
                'publisher' => 'Erlangga',
                'year' => 2017,
                'rack' => 'E-02',
                'synopsis' => 'Pembahasan analisis rangkaian listrik mulai dari hukum dasar hingga rangkaian arus bolak-balik.',
            ],
            [
                'title' => 'Sistem Digital',
                'author' => 'Thomas L. Floyd',
                'category' => 'Elektronik',
                'stock' => 5,
                'isbn' => '978-1000000003',
                'publisher' => 'Pearson',
                'year' => 2018,
                'rack' => 'E-03',
                'synopsis' => 'Konsep sistem digital, gerbang logika, dan perancangan rangkaian logika terapan.',
            ],
            [
                'title' => 'Panduan Praktikum Peralatan Laboratorium',
                'author' => 'Tim Laboran Kampus',
                'category' => 'Peralatan',
                'stock' => 7,
                'isbn' => '978-1000000004',
                'publisher' => 'UPT Perpustakaan',
                'year' => 2020,
                'rack' => 'P-01',
                'synopsis' => 'Tata cara penggunaan, perawatan, dan keselamatan kerja saat memakai peralatan laboratorium.',
            ],
            [
                'title' => 'Teknik Pengukuran dan Alat Ukur',
                'author' => 'Hery Setiawan',
                'category' => 'Peralatan',
                'stock' => 15,
                'isbn' => '978-1000000005',
                'publisher' => 'Andi Publisher',
                'year' => 2019,
                'rack' => 'P-02',
                'synopsis' => 'Prinsip pengukuran besaran listrik dan mekanik menggunakan alat ukur standar industri.',
            ],
            [
                'title' => 'Manajemen Perawatan Peralatan',
                'author' => 'Daryanto',
                'category' => 'Peralatan',
                'stock' => 12,
                'isbn' => '978-1000000006',
                'publisher' => 'Gava Media',
                'year' => 2018,
                'rack' => 'P-03',
                'synopsis' => 'Strategi perencanaan dan pelaksanaan perawatan peralatan agar tetap andal dan awet.',
            ],
            [
                'title' => 'Fisika Dasar',
                'author' => 'Budi Santoso',
                'category' => 'Sains',
                'stock' => 20,
                'isbn' => '978-1000000007',
                'publisher' => 'Erlangga',
                'year' => 2015,
                'rack' => 'S-01',
                'synopsis' => 'Materi fisika dasar meliputi mekanika, termodinamika, gelombang, dan elektromagnetika.',
            ],
            [
                'title' => 'Sapiens: Riwayat Singkat Umat Manusia',
                'author' => 'Yuval Noah Harari',
                'category' => 'Sains',
                'stock' => 25,
                'isbn' => '978-1000000008',
                'publisher' => 'Kepustakaan Populer Gramedia',
                'year' => 2017,
                'rack' => 'S-02',
                'synopsis' => 'Perjalanan sejarah manusia dari zaman batu hingga era revolusi sains dan teknologi.',
            ],
            [
                'title' => 'Laskar Pelangi',
                'author' => 'Andrea Hirata',
                'category' => 'Sastra',
                'stock' => 18,
                'isbn' => '978-1000000009',
                'publisher' => 'Bentang Pustaka',
                'year' => 2005,
                'rack' => 'F-01',
                'synopsis' => 'Kisah persahabatan anak-anak Belitung yang berjuang menempuh pendidikan dengan penuh semangat.',
            ],
            [
                'title' => 'Bumi Manusia',
                'author' => 'Pramoedya Ananta Toer',
                'category' => 'Sastra',
                'stock' => 8,
                'isbn' => '978-1000000010',
                'publisher' => 'Lentera Dipantara',
                'year' => 1980,
                'rack' => 'F-02',
                'synopsis' => 'Novel sejarah tentang perjuangan identitas dan cinta di masa kolonial Hindia Belanda.',
            ],
            [
                'title' => 'Perahu Kertas',
                'author' => 'Dee Lestari',
                'category' => 'Sastra',
                'stock' => 10,
                'isbn' => '978-1000000011',
                'publisher' => 'Bentang Pustaka',
                'year' => 2009,
                'rack' => 'F-03',
                'synopsis' => 'Cerita tentang mimpi, persahabatan, dan pencarian jati diri dua anak muda.',
            ],
            [
                'title' => 'Basis Data Dasar',
                'author' => 'Siti Rahma',
                'category' => 'Teknologi',
                'stock' => 5,
                'isbn' => '978-1000000012',
                'publisher' => 'Informatika',
                'year' => 2021,
                'rack' => 'T-01',
                'synopsis' => 'Konsep basis data relasional, perancangan ERD, normalisasi, dan dasar-dasar SQL.',
            ],
            [
                'title' => 'Pemrograman Flutter',
                'author' => 'Andi Wijaya',
                'category' => 'Teknologi',
                'stock' => 7,
                'isbn' => '978-1000000013',
                'publisher' => 'Informatika',
                'year' => 2022,
                'rack' => 'T-02',
                'synopsis' => 'Panduan membangun aplikasi mobile lintas platform menggunakan Flutter dan Dart.',
            ],
        ];

        $createdBooks = [];
        foreach ($booksData as $item) {
            $createdBooks[$item['title']] = Book::updateOrCreate(
                ['isbn' => $item['isbn']],
                [
                    'category_id' => $categories[$item['category']]->id,
                    'title' => $item['title'],
                    'author' => $item['author'],
                    'publisher' => $item['publisher'],
                    'year' => $item['year'],
                    'synopsis' => $item['synopsis'],
                    'rack_location' => $item['rack'],
                    'stock_total' => $item['stock'],
                    'stock_available' => $item['stock'],
                    'cover' => 'https://placehold.co/400x300?text='.urlencode($item['title']),
                ]
            );
        }

        $aurelia = $mahasiswa[0];
        $budi = $mahasiswa[1];

        Loan::firstOrCreate(
            ['code' => 'PJ25111601'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Dasar-Dasar Elektronika']->id,
                'status' => 'pending',
                'requested_at' => Carbon::now(),
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        Loan::firstOrCreate(
            ['code' => 'PJ25111602'],
            [
                'user_id' => $budi->id,
                'book_id' => $createdBooks['Rangkaian Listrik']->id,
                'status' => 'approved',
                'requested_at' => Carbon::today()->subDays(2),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(2),
                'due_date' => Carbon::today()->addDays(5),
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        Loan::firstOrCreate(
            ['code' => 'PJ25111603'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Sistem Digital']->id,
                'status' => 'approved',
                'requested_at' => Carbon::today()->subDays(10),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(10),
                'due_date' => Carbon::today()->subDays(3),
                'fine_amount' => 0,
                'fine_paid' => true,
            ]
        );

        Loan::firstOrCreate(
            ['code' => 'PJ25111604'],
            [
                'user_id' => $budi->id,
                'book_id' => $createdBooks['Panduan Praktikum Peralatan Laboratorium']->id,
                'status' => 'returned',
                'requested_at' => Carbon::today()->subDays(10),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(10),
                'due_date' => Carbon::today()->subDays(8),
                'returned_at' => Carbon::today()->subDays(5),
                'fine_amount' => 3000,
                'fine_paid' => false,
            ]
        );

        Loan::firstOrCreate(
            ['code' => 'PJ25111605'],
            [
                'user_id' => $aurelia->id,
                'book_id' => $createdBooks['Teknik Pengukuran dan Alat Ukur']->id,
                'status' => 'rejected',
                'requested_at' => Carbon::today()->subDays(5),
                'approved_by' => $admin->id,
                'approved_at' => Carbon::today()->subDays(5),
                'fine_amount' => 0,
                'fine_paid' => true,
                'rejected_reason' => 'Buku sedang dalam perbaikan.',
            ]
        );

        foreach ($createdBooks as $book) {
            $borrowed = Loan::where('book_id', $book->id)
                ->where('status', 'approved')
                ->count();

            $book->update([
                'stock_available' => max(0, $book->stock_total - $borrowed),
            ]);
        }
    }
}
