import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../data/dummy_data.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  static const _categories = ['Semua', 'Teknologi', 'Sains', 'Sastra'];
  String _category = 'Semua';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final books = dummyBooks.where((b) {
      final matchCat = _category == 'Semua' || b.category == _category;
      final matchQuery =
          b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Buku')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Cari judul atau penulis...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = _categories[i];
                  final selected = _category == c;
                  return ChoiceChip(
                    label: Text(c),
                    selected: selected,
                    selectedColor: AppColors.primary,
                    labelStyle:
                        TextStyle(color: selected ? Colors.white : null),
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _category = c),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: books.isEmpty
                  ? const Center(child: Text('Buku tidak ditemukan'))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => BookCard(
                        book: books[i],
                        onTap: () => context.push('/books/${books[i].id}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
