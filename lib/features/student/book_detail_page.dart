import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_cover.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/quantity_stepper.dart';
import '../../data/dummy_data.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  const BookDetailPage({super.key, required this.bookId});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  int _days = 7; // lama peminjaman (hari)

  @override
  Widget build(BuildContext context) {
    final book = dummyBooks.firstWhere((b) => b.id == widget.bookId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: BookCover(book: book, width: 140, height: 190)),
              const SizedBox(height: 20),
              Text(book.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${book.author} · ${book.category}',
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.approvedBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Tersedia · ${book.stock} eksemplar',
                    style: const TextStyle(
                        color: AppColors.approvedFg,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              const Text('Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(book.description,
                  style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              const Text('Lama Peminjaman',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              QuantityStepper(
                value: _days,
                min: 1,
                max: 14,
                suffix: ' hari',
                onChanged: (v) => setState(() => _days = v),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Ajukan Peminjaman',
                onPressed: () {
                  // TODO: kirim ke API
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Mengajukan "${book.title}" selama $_days hari...')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
