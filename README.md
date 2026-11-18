# MeTech Library

Aplikasi peminjaman buku perpustakaan kampus:

- `backend/`: Laravel 13 REST API + Sanctum + SQLite
- `lib/`: aplikasi Flutter untuk mahasiswa dan admin
- `docs/API.md`: dokumentasi endpoint

## Menjalankan Backend

Prasyarat: PHP 8.3+, Composer, ekstensi PHP SQLite.

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve
```

Di PowerShell gunakan `Copy-Item .env.example .env` sebagai pengganti `cp`.

API berjalan di `http://127.0.0.1:8000/api`. Untuk Android emulator, Flutter memakai `http://10.0.2.2:8000/api` secara otomatis.

## Menjalankan Aplikasi Flutter

```bash
flutter pub get
flutter run
```

Base URL bisa dioverride:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

`192.168.1.10` adalah contoh IP komputer yang menjalankan backend; gunakan IP LAN yang dapat diakses perangkat.

## Akun Demo

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@perpustakaan.ac.id` | `admin123` |
| Mahasiswa | `aurelia@kampus.ac.id` (NIM `2301001`) | `password123` |
| Mahasiswa | `budi@kampus.ac.id` (NIM `2301002`) | `password123` |
| Mahasiswa | `citra@kampus.ac.id` (NIM `2301003`) | `password123` |

## Aturan Bisnis

- Maksimal 3 peminjaman aktif per mahasiswa.
- Lama pinjam 7 hari sejak disetujui admin.
- Denda Rp1.000 per hari keterlambatan.
- Peminjaman berstatus `pending` boleh dibatalkan mahasiswa.
- Stok berkurang saat admin menyetujui dan bertambah saat pengembalian.
- Pendaftaran akun mandiri tidak tersedia; akun mahasiswa dibuat admin/seed.

## Pengujian

```bash
cd backend
php artisan test --compact

flutter analyze
flutter test
```
