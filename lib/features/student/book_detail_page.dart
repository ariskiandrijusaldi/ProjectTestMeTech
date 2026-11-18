import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_service.dart';
import '../../core/api/book_repository.dart';
import '../../core/api/loan_repository.dart';
import '../../core/models/api_book.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/category_icon.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/book.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final BookRepository _bookRepo = BookRepository();
  final LoanRepository _loanRepo = LoanRepository();

  ApiBook? _book;
  bool _loading = true;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final book = await _bookRepo.getBook(int.parse(widget.bookId));
      if (!mounted) return;
      setState(() {
        _book = book;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat detail buku.';
        _loading = false;
      });
    }
  }

  Future<void> _confirmAndRequest() async {
    if (_book == null) return;

    final confirmed = await showAppConfirmDialog(
      context,
      title: 'Konfirmasi Peminjaman',
      message: 'Apakah Anda yakin ingin meminjam buku "${_book!.title}"?',
      icon: Icons.menu_book_rounded,
      confirmLabel: 'Ya, Ajukan',
    );

    if (confirmed != true) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _loanRepo.requestLoan(_book!.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan peminjaman berhasil diajukan!'),
          backgroundColor: AppColors.approvedFg,
        ),
      );
      context.go('/history');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Terjadi kesalahan saat mengajukan peminjaman.';
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null && _book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Buku')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: AppColors.rejectedFg)),
              const SizedBox(height: 16),
              PrimaryButton(label: 'Coba Lagi', onPressed: _load),
            ],
          ),
        ),
      );
    }
    final book = _book!;

    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: BookCover(
                  book: Book.fromApi(book),
                  width: 140,
                  height: 190,
                ),
              ),
              const SizedBox(height: 20),
              Text(book.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(book.author,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon(book.category?['name']),
                        size: 15, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(book.category?['name'] ?? '-',
                        style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              if (book.isbn != null && book.isbn!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('ISBN: ${book.isbn}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
              if (book.rackLocation != null && book.rackLocation!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('Lokasi Rak: ${book.rackLocation}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: book.isAvailable
                      ? AppColors.approvedBg
                      : AppColors.rejectedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  book.isAvailable
                      ? 'Tersedia · ${book.stockAvailable} dari ${book.stockTotal} eksemplar'
                      : 'Stok Habis (0/${book.stockTotal})',
                  style: TextStyle(
                      color: book.isAvailable
                          ? AppColors.approvedFg
                          : AppColors.rejectedFg,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
              if (book.synopsis != null && book.synopsis!.isNotEmpty) ...[
                const Text('Sinopsis / Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 6),
                Text(book.synopsis!,
                    style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _submitting
                      ? 'Mengirim...'
                      : (book.isAvailable ? 'Ajukan Peminjaman' : 'Stok Tidak Tersedia'),
                  onPressed: book.isAvailable && !_submitting
                      ? _confirmAndRequest
                      : null,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.rejectedBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.rejectedFg, fontSize: 13)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
