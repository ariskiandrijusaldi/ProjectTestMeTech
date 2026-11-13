import 'package:flutter/material.dart';

const int kDendaPerHari = 1000; // Rp per hari terlambat
const int kLamaPinjamHari = 7; // batas pinjam default

// ---------- users ----------
class AppUser {
  final int id;
  final String name;
  final String email;
  final String? nim; // null untuk admin
  final String role; // 'admin' | 'mahasiswa'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.nim,
    required this.role,
  });
}

// ---------- categories ----------
class Category {
  final int id;
  String name;
  Category({required this.id, required this.name});
}

// ---------- books ----------
class Book {
  final int id;
  int categoryId;
  String isbn;
  String title;
  String author;
  String publisher;
  int year;
  String synopsis;
  String cover; // URL gambar, boleh kosong
  String rackLocation;
  int stockTotal;
  int stockAvailable;

  Book({
    required this.id,
    required this.categoryId,
    required this.isbn,
    required this.title,
    required this.author,
    this.publisher = '',
    required this.year,
    this.synopsis = '',
    this.cover = '',
    this.rackLocation = '',
    required this.stockTotal,
    required this.stockAvailable,
  });
}

/// Data input form buku (dipakai untuk tambah & ubah).
class BookInput {
  final int categoryId;
  final String isbn, title, author, publisher, synopsis, cover, rackLocation;
  final int year, stockTotal;

  const BookInput({
    required this.categoryId,
    required this.isbn,
    required this.title,
    required this.author,
    required this.publisher,
    required this.year,
    required this.synopsis,
    required this.cover,
    required this.rackLocation,
    required this.stockTotal,
  });
}

// ---------- loans ----------
enum LoanStatus { pending, approved, rejected, returned }

class Loan {
  final int id;
  final String code; // contoh: PJ250701
  final int userId;
  final int bookId;
  LoanStatus status;
  final DateTime requestedAt;
  int? approvedBy;
  DateTime? approvedAt;
  DateTime? dueDate;
  DateTime? returnedAt;
  int fineAmount;
  bool finePaid;
  String? rejectedReason;

  Loan({
    required this.id,
    required this.code,
    required this.userId,
    required this.bookId,
    this.status = LoanStatus.pending,
    required this.requestedAt,
    this.approvedBy,
    this.approvedAt,
    this.dueDate,
    this.returnedAt,
    this.fineAmount = 0,
    this.finePaid = false,
    this.rejectedReason,
  });

  /// Hari terlambat (sampai dikembalikan, atau sampai hari ini jika belum).
  int get hariTerlambat {
    final due = dueDate;
    if (due == null) return 0;
    if (status != LoanStatus.approved && status != LoanStatus.returned) return 0;
    final end = returnedAt ?? DateTime.now();
    final d = DateTime(end.year, end.month, end.day)
        .difference(DateTime(due.year, due.month, due.day))
        .inDays;
    return d > 0 ? d : 0;
  }

  int get dendaBerjalan => hariTerlambat * kDendaPerHari;
  bool get terlambat => status == LoanStatus.approved && hariTerlambat > 0;
}

/// Store in-memory (dummy). Saat API tim sudah siap,
/// cukup ganti isi method di bawah dengan pemanggilan repository/API.
class AdminStore extends ChangeNotifier {
  AdminStore._();
  static final AdminStore instance = AdminStore._();

  static const int adminId = 1; // admin yang sedang login (dummy)

  int _catSeq = 5;
  int _bookSeq = 4;

  final List<AppUser> _users = const [
    AppUser(id: 1, name: 'Administrator', email: 'admin@perpustakaan.ac.id', role: 'admin'),
    AppUser(id: 2, name: 'Budi', email: 'budi@mail.ac.id', nim: '2301001', role: 'mahasiswa'),
    AppUser(id: 3, name: 'Aurelia', email: 'aurelia@mail.ac.id', nim: '2301002', role: 'mahasiswa'),
    AppUser(id: 4, name: 'Citra', email: 'citra@mail.ac.id', nim: '2301003', role: 'mahasiswa'),
    AppUser(id: 5, name: 'Dimas', email: 'dimas@mail.ac.id', nim: '2301004', role: 'mahasiswa'),
    AppUser(id: 6, name: 'Eka', email: 'eka@mail.ac.id', nim: '2301005', role: 'mahasiswa'),
  ].toList();

  final List<Category> _categories = [
    Category(id: 1, name: 'Novel'),
    Category(id: 2, name: 'Sains'),
    Category(id: 3, name: 'Teknologi'),
    Category(id: 4, name: 'Sejarah'),
    Category(id: 5, name: 'Pelajaran'),
  ];

  final List<Book> _books = [
    Book(id: 1, categoryId: 1, isbn: '9789793062792', title: 'Laskar Pelangi',
        author: 'Andrea Hirata', publisher: 'Bentang Pustaka', year: 2005,
        synopsis: 'Novel tentang perjuangan anak-anak Belitung meraih pendidikan.',
        rackLocation: 'A-01', stockTotal: 10, stockAvailable: 10),
    Book(id: 2, categoryId: 2, isbn: '9780470913604', title: 'Fisika Dasar',
        author: 'Halliday & Resnick', publisher: 'Erlangga', year: 2010,
        synopsis: 'Buku ajar fisika dasar untuk mahasiswa.',
        rackLocation: 'B-03', stockTotal: 8, stockAvailable: 8),
    Book(id: 3, categoryId: 3, isbn: '9786020000001', title: 'Pemrograman Dart',
        author: 'Tim Informatika', publisher: 'Informatika', year: 2022,
        synopsis: 'Panduan dasar pemrograman Dart dan Flutter.',
        rackLocation: 'C-02', stockTotal: 5, stockAvailable: 4),
    Book(id: 4, categoryId: 4, isbn: '9786020000002', title: 'Sejarah Indonesia',
        author: 'M.C. Ricklefs', publisher: 'Serambi', year: 2008,
        synopsis: 'Sejarah Indonesia modern dari 1200 sampai sekarang.',
        rackLocation: 'D-05', stockTotal: 7, stockAvailable: 7),
  ];

  final List<Loan> _loans = [
    Loan(id: 5, code: 'PJ250702', userId: 2, bookId: 2,
        requestedAt: DateTime(2025, 7, 1)),
    Loan(id: 4, code: 'PJ250701', userId: 3, bookId: 1,
        requestedAt: DateTime(2025, 7, 1)),
    Loan(id: 3, code: 'PJ250700', userId: 4, bookId: 3,
        requestedAt: DateTime(2025, 6, 30),
        status: LoanStatus.approved,
        approvedBy: 1,
        approvedAt: DateTime(2025, 6, 30),
        dueDate: DateTime(2025, 7, 7)),
    Loan(id: 2, code: 'PJ250699', userId: 5, bookId: 4,
        requestedAt: DateTime(2025, 6, 29),
        status: LoanStatus.rejected,
        rejectedReason: 'Buku sedang dalam perbaikan.'),
    Loan(id: 1, code: 'PJ250690', userId: 6, bookId: 1,
        requestedAt: DateTime(2025, 6, 25),
        status: LoanStatus.returned,
        approvedBy: 1,
        approvedAt: DateTime(2025, 6, 25),
        dueDate: DateTime(2025, 7, 2),
        returnedAt: DateTime(2025, 7, 5, 14, 30),
        fineAmount: 3 * kDendaPerHari,
        finePaid: false),
  ];

  // ---------- GETTERS ----------
  List<Category> get categories => List.unmodifiable(_categories);
  List<Book> get books => List.unmodifiable(_books);
  List<Loan> get loans => List.unmodifiable(_loans);

  /// Total eksemplar buku (jumlah stock_total).
  int get totalBuku => _books.fold(0, (s, b) => s + b.stockTotal);
  int get totalPeminjaman => _loans.length;

  List<Loan> get terbaru {
    final list = [..._loans]
      ..sort((a, b) {
        final c = b.requestedAt.compareTo(a.requestedAt);
        return c != 0 ? c : b.id.compareTo(a.id);
      });
    return list;
  }

  List<Loan> get menunggu =>
      terbaru.where((p) => p.status == LoanStatus.pending).toList();

  List<Loan> get riwayat =>
      terbaru.where((p) => p.status != LoanStatus.pending).toList();

  Loan? loanById(int id) {
    for (final p in _loans) {
      if (p.id == id) return p;
    }
    return null;
  }

  Book? bookById(int id) {
    for (final b in _books) {
      if (b.id == id) return b;
    }
    return null;
  }

  AppUser? userById(int id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  String categoryName(int id) {
    for (final c in _categories) {
      if (c.id == id) return c.name;
    }
    return '-';
  }

  int jumlahBukuDiKategori(int categoryId) =>
      _books.where((b) => b.categoryId == categoryId).length;

  // ---------- CRUD KATEGORI ----------
  bool namaKategoriTerpakai(String name, {int? exceptId}) => _categories.any(
          (c) => c.name.toLowerCase() == name.toLowerCase() && c.id != exceptId);

  void tambahKategori(String name) {
    _catSeq++;
    _categories.add(Category(id: _catSeq, name: name));
    notifyListeners();
  }

  void ubahKategori(int id, String name) {
    _categories.firstWhere((c) => c.id == id).name = name;
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  String? hapusKategori(int id) {
    if (jumlahBukuDiKategori(id) > 0) {
      return 'Kategori masih dipakai ${jumlahBukuDiKategori(id)} buku.';
    }
    _categories.removeWhere((c) => c.id == id);
    notifyListeners();
    return null;
  }

  // ---------- CRUD BUKU ----------
  bool isbnTerpakai(String isbn, {int? exceptId}) => _books.any(
          (b) => b.isbn.toLowerCase() == isbn.toLowerCase() && b.id != exceptId);

  void tambahBuku(BookInput i) {
    _bookSeq++;
    _books.add(Book(
      id: _bookSeq,
      categoryId: i.categoryId,
      isbn: i.isbn,
      title: i.title,
      author: i.author,
      publisher: i.publisher,
      year: i.year,
      synopsis: i.synopsis,
      cover: i.cover,
      rackLocation: i.rackLocation,
      stockTotal: i.stockTotal,
      stockAvailable: i.stockTotal,
    ));
    notifyListeners();
  }

  void ubahBuku(int id, BookInput i) {
    final b = _books.firstWhere((e) => e.id == id);
    final dipinjam = b.stockTotal - b.stockAvailable;
    b
      ..categoryId = i.categoryId
      ..isbn = i.isbn
      ..title = i.title
      ..author = i.author
      ..publisher = i.publisher
      ..year = i.year
      ..synopsis = i.synopsis
      ..cover = i.cover
      ..rackLocation = i.rackLocation
      ..stockTotal = i.stockTotal
      ..stockAvailable = i.stockTotal - dipinjam;
    notifyListeners();
  }

  /// Mengembalikan pesan error, atau null jika berhasil.
  String? hapusBuku(int id) {
    if (_loans.any((l) => l.bookId == id)) {
      return 'Buku punya riwayat peminjaman, tidak bisa dihapus.';
    }
    _books.removeWhere((e) => e.id == id);
    notifyListeners();
    return null;
  }

  // ---------- PEMINJAMAN ----------
  /// Mengembalikan pesan error, atau null jika berhasil.
  String? setujui(int id) {
    final p = _loans.firstWhere((e) => e.id == id);
    final b = bookById(p.bookId);
    if (b == null) return 'Buku tidak ditemukan.';
    if (b.stockAvailable < 1) {
      return 'Stok "${b.title}" habis, tidak bisa disetujui.';
    }
    final now = DateTime.now();
    b.stockAvailable -= 1;
    p
      ..status = LoanStatus.approved
      ..approvedBy = adminId
      ..approvedAt = now
      ..dueDate = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: kLamaPinjamHari));
    notifyListeners();
    return null;
  }

  void tolak(int id, String alasan) {
    _loans.firstWhere((e) => e.id == id)
      ..status = LoanStatus.rejected
      ..rejectedReason = alasan;
    notifyListeners();
  }

  void konfirmasiPengembalian(int id) {
    final p = _loans.firstWhere((e) => e.id == id);
    p.returnedAt = DateTime.now();
    p.fineAmount = p.hariTerlambat * kDendaPerHari;
    p.finePaid = false;
    p.status = LoanStatus.returned;
    final b = bookById(p.bookId);
    if (b != null) b.stockAvailable += 1;
    notifyListeners();
  }

  void tandaiDendaLunas(int id) {
    _loans.firstWhere((e) => e.id == id).finePaid = true;
    notifyListeners();
  }

  void hapusPeminjaman(int id) {
    _loans.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}