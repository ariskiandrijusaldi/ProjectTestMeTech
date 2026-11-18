# Dokumentasi REST API Perpustakaan MeTech

Base URL:

- Web / desktop / iOS simulator: `http://127.0.0.1:8000/api`
- Android emulator: `http://10.0.2.2:8000/api`

Header standar:

```http
Accept: application/json
Content-Type: application/json
Authorization: Bearer <token>
```

Untuk upload cover buku gunakan `multipart/form-data` dan kirim `_method=PUT` saat update.

## Format Respons

Respons sukses memakai envelope `message` + `data`. Endpoint list memakai format pagination Laravel (`data`, `links`, `meta`). Error validasi memakai HTTP 422:

```json
{
  "message": "Data yang diberikan tidak valid.",
  "errors": {
    "email": ["Email atau password salah."]
  }
}
```

Kode error yang dipakai: `401` belum login/token tidak valid, `403` bukan admin, `404` data tidak ditemukan, `405` method salah, `422` validasi/aturan bisnis, `429` terlalu banyak request, `500` server error.

---

## 1. Autentikasi

### `POST /api/login`

Login memakai email atau NIM + password.

Request:

```json
{
  "email": "2301001",
  "password": "password123",
  "device_name": "flutter-mobile"
}
```

Response `200 OK`:

```json
{
  "message": "Login berhasil.",
  "data": {
    "token": "1|abcdef123456...",
    "token_type": "Bearer",
    "user": {
      "id": 2,
      "name": "Aurelia",
      "email": "aurelia@kampus.ac.id",
      "nim": "2301001",
      "role": "mahasiswa"
    }
  }
}
```

### `GET /api/me`

Mengambil user yang sedang login. Memerlukan Bearer token.

```json
{
  "message": "Data pengguna berhasil diambil.",
  "data": {
    "id": 2,
    "name": "Aurelia",
    "email": "aurelia@kampus.ac.id",
    "nim": "2301001",
    "role": "mahasiswa"
  }
}
```

### `POST /api/logout`

Mencabut token yang sedang dipakai.

```json
{
  "message": "Logout berhasil."
}
```

---

## 2. Endpoint Publik / Mahasiswa

### `GET /api/categories`

Daftar kategori (tanpa slug).

```json
{
  "message": "Daftar kategori berhasil diambil.",
  "data": [
    { "id": 1, "name": "Elektronik" },
    { "id": 5, "name": "Teknologi" }
  ]
}
```

### `GET /api/books/popular`

Enam buku paling sering dipinjam.

```json
{
  "message": "Buku populer berhasil diambil.",
  "data": [
    {
      "id": 11,
      "category_id": 5,
      "category": { "id": 5, "name": "Teknologi" },
      "isbn": "978-1000000011",
      "title": "Pemrograman Flutter",
      "author": "Andi Wijaya",
      "publisher": "Informatika",
      "year": 2024,
      "synopsis": "Panduan Flutter komprehensif...",
      "cover_url": "http://localhost:8000/storage/covers/sample.jpg",
      "rack_location": "Rak A-01",
      "stock_total": 10,
      "stock_available": 9,
      "is_available": true
    }
  ]
}
```

### `GET /api/books`

Query params:

- `search`: judul, penulis, atau ISBN
- `category_id`: ID kategori
- `category`: nama kategori (`Semua` untuk semua)
- `page`: halaman, default `1`
- `per_page`: `1..100`, default `10`

Response memakai format pagination:

```json
{
  "message": "Daftar buku berhasil diambil.",
  "data": [ ... ],
  "links": { "first": "...", "last": "...", "prev": null, "next": null },
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 1,
    "per_page": 100,
    "total": 13
  }
}
```

### `GET /api/books/{id}`

Detail satu buku. Response `404` jika tidak ada.

```json
{
  "message": "Detail buku berhasil diambil.",
  "data": {
    "id": 11,
    "category_id": 5,
    "category": { "id": 5, "name": "Teknologi" },
    "title": "Pemrograman Flutter",
    "author": "Andi Wijaya",
    "stock_total": 10,
    "stock_available": 9,
    "is_available": true
  }
}
```

### `POST /api/loans`

Mengajukan peminjaman. Body hanya `book_id`; aturan bisnis dicek di server.

Batas: maksimal 3 peminjaman aktif per mahasiswa. Buku harus tersedia.

```json
{
  "book_id": 11
}
```

Response `201 Created`:

```json
{
  "message": "Pengajuan peminjaman berhasil diajukan.",
  "data": {
    "id": 6,
    "code": "PJ26111801",
    "status": "pending",
    "status_label": "Menunggu",
    "requested_at": "2026-11-18T10:00:00+07:00",
    "approved_at": null,
    "due_date": null,
    "returned_at": null,
    "is_overdue": false,
    "late_days": 0,
    "fine_amount": 0,
    "fine_paid": true,
    "rejected_reason": null,
    "book": { "id": 11, "title": "Pemrograman Flutter" }
  }
}
```

### `GET /api/my-loans`

Daftar peminjaman milik user yang login. `data` berupa list (bukan nested pagination).

Query params:

- `tab`: `active`, `history`, atau `all`
- `status`: `pending`, `approved`, `rejected`, `returned`, atau `all`
- `page`, `per_page` (`1..100`, default `10`)

`active` berisi `pending` + `approved`; `history` berisi `rejected` + `returned`.

```json
{
  "message": "Daftar peminjaman berhasil diambil.",
  "data": [
    {
      "id": 6,
      "code": "PJ26111801",
      "status": "pending",
      "status_label": "Menunggu",
      "requested_at": "2026-11-18T10:00:00+07:00",
      "due_date": null,
      "is_overdue": false,
      "late_days": 0,
      "fine_amount": 0,
      "fine_paid": true,
      "book": { ... }
    }
  ],
  "links": { ... },
  "meta": { "current_page": 1, "last_page": 1, "per_page": 100, "total": 1 },
  "tab": "active"
}
```

### `GET /api/my-loans/{id}`

Detail peminjaman milik sendiri. Peminjaman milik user lain menghasilkan `404`.

### `DELETE /api/my-loans/{id}`

Membatalkan pengajuan selama status masih `pending`.

```json
{
  "message": "Pengajuan peminjaman dibatalkan."
}
```

---

## 3. Admin

Semua endpoint di bawah memerlukan Bearer token dengan role `admin`, prefix `/api/admin`.

### `GET /api/admin/dashboard`

```json
{
  "message": "Ringkasan dashboard berhasil diambil.",
  "data": {
    "total_books": 13,
    "total_stock": 140,
    "available_stock": 138,
    "total_loans": 5,
    "pending_loans": 1,
    "active_loans": 2,
    "overdue_loans": 1,
    "latest_loans": [ ... ]
  }
}
```

### `GET /api/admin/loans`

Query params:

- `status`: `all` (default), `pending`, `approved`, `rejected`, `returned`, `history`, `overdue`
- `search`: kode, nama/NIM/email peminjam, atau judul buku
- `page`, `per_page` (`1..100`, default `10`)

`history` berarti semua status selain `pending`.

```json
{
  "message": "Daftar peminjaman berhasil diambil.",
  "data": [ ... ],
  "links": { ... },
  "meta": { ... },
  "meta_counts": {
    "pending": 1,
    "approved": 2,
    "overdue": 1
  }
}
```

### `GET /api/admin/loans/overdue`

Daftar peminjaman `approved` yang sudah melewati `due_date`.

### `GET /api/admin/loans/code/{code}`

Cari peminjaman berdasarkan kode, contoh `PJ26111801`. Pencarian tidak case-sensitive dan kode di-trim.

### `GET /api/admin/loans/{id}`

Detail peminjaman untuk admin.

### `PATCH /api/admin/loans/{id}/approve`

Menyetujui peminjaman:

- status menjadi `approved`
- `approved_at` diisi
- `due_date` = hari ini + 7 hari
- `stock_available` berkurang 1

### `PATCH /api/admin/loans/{id}/reject`

Body:

```json
{
  "reason": "Buku sedang dalam perbaikan fisik."
}
```

Status menjadi `rejected`; stok tidak berubah.

### `PATCH /api/admin/loans/{id}/return`

Mengembalikan buku:

- status menjadi `returned`
- `returned_at` diisi
- stok bertambah 1
- denda dihitung `hari_terlambat × Rp1.000`

Response `LoanResource` berisi `late_days`, `fine_amount`, dan `fine_paid`.

### `PATCH /api/admin/loans/{id}/pay-fine`

Menandai denda sudah lunas. Ditolak jika belum dikembalikan atau sudah lunas.

### CRUD Buku

- `GET /api/admin/books`: list + pagination, query `search`, `category_id`, `page`, `per_page`
- `GET /api/admin/books/{id}`: detail
- `POST /api/admin/books`: tambah buku (`multipart/form-data` bila upload cover)
- `PUT /api/admin/books/{id}`: update buku (`_method=PUT` untuk multipart)
- `DELETE /api/admin/books/{id}`: hapus buku; ditolak jika masih punya peminjaman aktif

Field buku: `category_id`, `isbn`, `title`, `author`, `publisher`, `year`, `synopsis`, `rack_location`, `stock_total`, `cover`.

### CRUD Kategori

- `GET /api/admin/categories`
- `POST /api/admin/categories` body `{ "name": "Ekonomi" }`
- `PUT /api/admin/categories/{id}` body `{ "name": "Ekonomi Terapan" }`
- `DELETE /api/admin/categories/{id}`; ditolak `422` jika masih dipakai buku

### `GET /api/admin/users`

Daftar mahasiswa. Query `search` untuk nama/NIM/email.

```json
{
  "message": "Daftar mahasiswa berhasil diambil.",
  "data": [
    {
      "id": 2,
      "name": "Aurelia",
      "email": "aurelia@kampus.ac.id",
      "nim": "2301001",
      "role": "mahasiswa"
    }
  ]
}
```
