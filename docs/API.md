# Dokumentasi REST API Perpustakaan MeTech

Base URL: `http://localhost:8000/api` (Web / Desktop) atau `http://10.0.2.2:8000/api` (Android Emulator)

Header Standar:
- `Accept: application/json`
- `Content-Type: application/json` (kecuali upload multipart form-data)
- `Authorization: Bearer <token>` (untuk endpoint terproteksi)

---

## 1. Autentikasi

### `POST /api/login`
Login menggunakan email atau NIM + password.

**Request Body:**
```json
{
  "email": "2301001", // atau "aurelia@kampus.ac.id"
  "password": "password123"
}
```

**Response Sukses (200 OK):**
```json
{
  "message": "Login berhasil.",
  "token": "1|abcdef123456...",
  "user": {
    "id": 2,
    "name": "Aurelia",
    "email": "aurelia@kampus.ac.id",
    "nim": "2301001",
    "role": "mahasiswa"
  }
}
```

**Response Error (422 Unprocessable Entity):**
```json
{
  "message": "Kredensial yang diberikan salah.",
  "errors": {
    "email": ["Email / NIM atau password salah."]
  }
}
```

---

### `POST /api/logout`
Mencabut personal access token yang sedang aktif.

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "message": "Logout berhasil."
}
```

---

### `GET /api/me`
Mendapatkan info user yang sedang login.

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "data": {
    "id": 2,
    "name": "Aurelia",
    "email": "aurelia@kampus.ac.id",
    "nim": "2301001",
    "role": "mahasiswa"
  }
}
```

---

## 2. Mahasiswa / Publik

### `GET /api/categories`
Daftar seluruh kategori buku.

**Response (200 OK):**
```json
{
  "status": "success",
  "data": [
    { "id": 1, "name": "Elektronik", "slug": "elektronik" },
    { "id": 5, "name": "Teknologi", "slug": "teknologi" }
  ]
}
```

---

### `GET /api/books`
Daftar buku dengan paginasi, pencarian, dan filter kategori.
- Query params: `search` (judul/penulis/isbn), `category_id`, `page`, `per_page`

**Response (200 OK):**
```json
{
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
  ],
  "links": { "first": "...", "last": "...", "prev": null, "next": null },
  "meta": { "current_page": 1, "from": 1, "last_page": 1, "per_page": 10, "total": 1 }
}
```

---

### `GET /api/books/{id}`
Detail buku berdasarkan ID.

**Response (200 OK):**
```json
{
  "data": {
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
}
```

---

### `POST /api/loans`
Mengajukan peminjaman buku oleh mahasiswa.

**Headers:** `Authorization: Bearer <token>`
**Request Body:**
```json
{
  "book_id": 11
}
```

**Response Sukses (201 Created):**
```json
{
  "status": "success",
  "message": "Pengajuan peminjaman berhasil diajukan.",
  "data": {
    "id": 1,
    "code": "PJ26111601",
    "status": "pending",
    "status_label": "Menunggu",
    "requested_at": "2026-11-16T14:00:00+07:00",
    "due_date": null,
    "returned_at": null,
    "fine_amount": 0,
    "fine_paid": true,
    "book": {
      "id": 11,
      "title": "Pemrograman Flutter"
    }
  }
}
```

---

### `GET /api/my-loans`
Melihat daftar peminjaman milik mahasiswa yang sedang login.
- Query params: `status` (pending, approved, returned, rejected), `tab` (active, history), `page`, `per_page`

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "status": "success",
  "tab": "all",
  "data": {
    "current_page": 1,
    "data": [
      {
        "id": 1,
        "code": "PJ26111601",
        "status": "pending",
        "status_label": "Menunggu",
        "requested_at": "2026-11-16T14:00:00+07:00",
        "due_date": null,
        "returned_at": null,
        "is_overdue": false,
        "late_days": 0,
        "fine_amount": 0,
        "fine_paid": true,
        "book": { ... }
      }
    ],
    "total": 1
  }
}
```

---

### `GET /api/my-loans/{id}`
Melihat detail peminjaman milik sendiri berdasarkan ID.

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "code": "PJ26111601",
    "status": "pending",
    "status_label": "Menunggu",
    "requested_at": "2026-11-16T14:00:00+07:00",
    "due_date": null,
    "book": { ... }
  },
  "message": "Detail peminjaman ditemukan."
}
```

---

### `DELETE /api/my-loans/{id}`
Membatalkan pengajuan peminjaman (hanya selama status masih `pending`).

**Headers:** `Authorization: Bearer <token>`

**Response (200 OK):**
```json
{
  "status": "success",
  "message": "Pengajuan peminjaman dibatalkan."
}
```

---

## 3. Admin (Prefix: `/api/admin/*`, Wajib Role `admin`)

### `GET /api/admin/dashboard`
Ringkasan statistik peminjaman dan buku untuk dashboard admin.

**Response (200 OK):**
```json
{
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

---

### `GET /api/admin/loans`
Daftar seluruh peminjaman dengan filter status dan pencarian kode/NIM/nama/judul buku.

**Response (200 OK):**
```json
{
  "data": [ ... ],
  "links": { ... },
  "meta": { "total": 5 },
  "meta_counts": { "pending": 1 }
}
```

---

### `GET /api/admin/loans/code/{code}`
Mencari peminjaman via kode unik (contoh: `PJ25111601`).

**Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "code": "PJ25111601",
    "status": "pending",
    "status_label": "Menunggu",
    "user": { "id": 2, "name": "Aurelia", "nim": "2301001" },
    "book": { "id": 1, "title": "Proyektor" }
  }
}
```

---

### `PATCH /api/admin/loans/{id}/approve`
Menyetujui peminjaman (status menjadi `approved`, jatuh tempo +7 hari, stok berkurang 1).

**Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "status": "approved",
    "status_label": "Disetujui",
    "approved_at": "2026-11-16T14:10:00+07:00",
    "due_date": "2026-11-23"
  },
  "message": "Peminjaman disetujui."
}
```

---

### `PATCH /api/admin/loans/{id}/reject`
Menolak pengajuan peminjaman (stok tidak berubah).

**Request Body:**
```json
{
  "reason": "Stok buku sedang dalam perbaikan fisik."
}
```

**Response (200 OK):**
```json
{
  "data": {
    "id": 1,
    "status": "rejected",
    "status_label": "Ditolak",
    "rejected_reason": "Stok buku sedang dalam perbaikan fisik."
  },
  "message": "Peminjaman ditolak."
}
```

---

### `PATCH /api/admin/loans/{id}/return`
Mengonfirmasi pengembalian buku (stok bertambah 1, hitung denda otomatis jika telat).

**Response (200 OK):**
```json
{
  "data": {
    "id": 3,
    "status": "returned",
    "status_label": "Dikembalikan",
    "returned_at": "2026-11-16T14:15:00+07:00",
    "late_days": 3,
    "fine_amount": 3000,
    "fine_paid": false
  },
  "message": "Pengembalian berhasil dikonfirmasi."
}
```

---

### `PATCH /api/admin/loans/{id}/pay-fine`
Menandai denda peminjaman sudah lunas.

**Response (200 OK):**
```json
{
  "data": {
    "id": 3,
    "fine_amount": 3000,
    "fine_paid": true
  },
  "message": "Denda ditandai lunas."
}
```

---

### `GET /api/admin/loans/overdue`
Daftar seluruh peminjaman yang aktif namun sudah melewati batas tanggal jatuh tempo.

---

### `CRUD /api/admin/books`
- `GET /api/admin/books`: Paginated list buku dengan search & category_id
- `GET /api/admin/books/{id}`: Detail buku
- `POST /api/admin/books`: Tambah buku (multipart/form-data jika ada gambar cover)
- `PUT /api/admin/books/{id}`: Update buku (gunakan field `_method=PUT` jika form-data)
- `DELETE /api/admin/books/{id}`: Hapus buku (ditolak jika memiliki peminjaman aktif)

---

### `CRUD /api/admin/categories`
- `GET /api/admin/categories`: Daftar kategori
- `POST /api/admin/categories`: Tambah kategori (`{"name": "Ekonomi"}`)
- `DELETE /api/admin/categories/{id}`: Hapus kategori (ditolak jika masih punya buku)
- `GET /api/admin/users`: Daftar mahasiswa perpustakaan
