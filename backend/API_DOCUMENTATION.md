# Dokumentasi REST API - Sistem Peminjaman Inventaris Kampus

Dokumentasi ini dibuat untuk memandu integrasi antara Frontend (Flutter) dan Backend (Laravel) sesuai dengan 4 layar wireframe/mockup.

---

## 1. Menjalankan Backend & Database

1. Pastikan **MySQL di XAMPP** (atau service MySQL lokal) sudah **START**.
2. Jalankan migrasi dan seeder data mockup (Proyektor, Laptop, Kamera, Speaker, #PJ250701, dll.):
   ```bash
   cd backend
   php artisan migrate
   php artisan db:seed
   ```
3. Jalankan server lokal:
   ```bash
   php artisan serve
   ```
   *Base URL default: `http://127.0.0.1:8000/api`* (atau gunakan IP WiFi laptop jika testing via HP/emulator: `http://192.168.x.x:8000/api` / `http://10.0.2.2:8000/api` untuk emulator Android).

---

## 2. Pemetaan Layar ke Endpoint API

---

### Layar 2: Halaman Beranda

#### A. Ringkasan Beranda (Dashboard Summary)
* **Endpoint:** `GET /api/dashboard`
* **Kegunaan:** Menampilkan profil ringkas user ("Halo, Aurelia"), kartu Total Barang (120), dan daftar Barang Populer.
* **Contoh Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "user": {
      "name": "Aurelia",
      "greeting": "Semangat beraktivitas di kampus!"
    },
    "total_barang": 120,
    "popular_items": [
      {
        "id": 1,
        "name": "Proyektor",
        "stock": 10,
        "is_available": true,
        "image_url": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500"
      },
      {
        "id": 2,
        "name": "Laptop",
        "stock": 8,
        "is_available": true,
        "image_url": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500"
      }
    ]
  }
}
```

#### B. Daftar Barang Populer Saja
* **Endpoint:** `GET /api/items/popular` (atau `GET /api/books/popular`)
* **Kegunaan:** Menampilkan list barang teratas berdasarkan frekuensi peminjaman.

---

### Layar 3: Halaman Daftar Barang

#### A. Kategori untuk Chip Filter
* **Endpoint:** `GET /api/categories`
* **Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    { "id": 1, "name": "Elektronik", "slug": "elektronik" },
    { "id": 2, "name": "Peralatan", "slug": "peralatan" }
  ]
}
```

#### B. Pencarian & Filter Barang
* **Endpoint:** `GET /api/items` (atau `GET /api/books`)
* **Query Parameters (Opsional):**
  - `search=proyektor` (Pencarian nama/deskripsi barang)
  - `category_id=1` (Filter berdasarkan ID kategori)
  - `category=Elektronik` (Filter berdasarkan nama/slug kategori)
* **Contoh Request:**
  `GET /api/items?search=lap&category_id=1`
* **Response (200 OK):**
```json
{
  "status": "success",
  "total": 4,
  "data": [
    {
      "id": 1,
      "name": "Proyektor",
      "stock": 10,
      "description": "Proyektor untuk kegiatan perkuliahan dan seminar.",
      "image_url": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500",
      "is_available": true,
      "category": {
        "id": 1,
        "name": "Elektronik"
      }
    }
  ]
}
```

---

### Layar 4: Halaman Pengajuan Peminjaman

#### A. Detail Barang
* **Endpoint:** `GET /api/items/{id}` (atau `GET /api/books/{id}`)
* **Contoh Request:** `GET /api/items/1`
* **Response (200 OK):**
```json
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Proyektor",
    "stock": 10,
    "description": "Proyektor untuk kegiatan perkuliahan dan seminar.",
    "is_available": true,
    "image_url": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500",
    "category": {
      "id": 1,
      "name": "Elektronik"
    }
  }
}
```

#### B. Submit Pengajuan Peminjaman
* **Endpoint:** `POST /api/loans`
* **Request Header:** `Content-Type: application/json`
* **Request Body:**
```json
{
  "item_id": 1,
  "quantity": 1
}
```
*(Catatan: `item_id` atau `book_id` sama-sama didukung. `loan_date` opsional, default hari ini).*
* **Response Berhasil (201 Created):**
```json
{
  "status": "success",
  "message": "Pengajuan peminjaman berhasil diajukan",
  "data": {
    "id": 4,
    "user_id": 1,
    "book_id": 1,
    "loan_code": "#PJ250702",
    "quantity": 1,
    "status": "Menunggu Persetujuan",
    "loan_date": "2025-07-01",
    "loan_date_formatted": "1 Jul 2025"
  }
}
```
* **Response Gagal Jika Stok Kurang (400 Bad Request):**
```json
{
  "status": "error",
  "message": "Stok barang tidak mencukupi. Sisa stok: 0 unit."
}
```

---

### Layar 5: Halaman Status Peminjaman ("Peminjaman Saya")

#### A. Tab "Aktif"
* **Endpoint:** `GET /api/loans/me?tab=aktif`
* **Response:** Menampilkan data peminjaman yang berstatus **`Menunggu Persetujuan`** atau **`Disetujui`**.
* **Contoh Response (200 OK):**
```json
{
  "status": "success",
  "tab": "aktif",
  "total": 2,
  "data": [
    {
      "id": 1,
      "loan_code": "#PJ250701",
      "quantity": 1,
      "status": "Menunggu Persetujuan",
      "loan_date": "2025-07-01",
      "loan_date_formatted": "1 Jul 2025",
      "book": {
        "id": 1,
        "name": "Proyektor",
        "image_url": "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=500"
      }
    },
    {
      "id": 2,
      "loan_code": "#PJ250630",
      "quantity": 1,
      "status": "Disetujui",
      "loan_date": "2025-06-25",
      "return_date": "2025-06-30",
      "return_date_formatted": "30 Jun 2025",
      "book": {
        "id": 2,
        "name": "Laptop",
        "image_url": "https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500"
      }
    }
  ]
}
```

#### B. Tab "Riwayat"
* **Endpoint:** `GET /api/loans/me?tab=riwayat`
* **Response:** Menampilkan peminjaman yang berstatus **`Selesai`** atau **`Ditolak`**.

#### C. Simulasi Ubah Status Peminjaman (Admin / Testing)
* **Endpoint:** `PATCH /api/loans/{id}/status`
* **Request Body:**
```json
{
  "status": "Disetujui"
}
```
*(Status yang valid: `Menunggu Persetujuan`, `Disetujui`, `Ditolak`, `Selesai`). Stok otomatis dikembalikan jika status menjadi `Ditolak` atau `Selesai`.*
