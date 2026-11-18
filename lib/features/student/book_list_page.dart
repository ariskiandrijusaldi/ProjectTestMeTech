import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/book_repository.dart';
import '../../core/api/category_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../core/widgets/category_icon.dart';
import '../../models/book.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final BookRepository _bookRepo = BookRepository();
  final CategoryRepository _catRepo = CategoryRepository();

  List<Book> _books = [];
  List<Map<String, dynamic>> _categories = [];
  String _category = 'Semua';
  String _query = '';
  bool _loading = true;
  String? _error;

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
      final books = await _bookRepo.listBooks();
      final cats = await _catRepo.listCategories();
      if (!mounted) return;
      setState(() {
        _books = books.map((e) => Book.fromApi(e)).toList();
        _categories = cats;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat katalog buku. Periksa koneksi backend.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final filtered = _books.where((b) {
      final matchCat = _category == 'Semua' || b.category == _category;
      final matchQuery =
          b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q);
      return matchCat && matchQuery;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Buku')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.rejectedFg)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Padding(
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
                            itemCount: _categories.length + 1,
                            separatorBuilder: (_, index) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              if (i == 0) {
                                final selected = _category == 'Semua';
                                return ChoiceChip(
                                  avatar: Icon(
                                    Icons.apps,
                                    size: 16,
                                    color: selected ? Colors.white : AppColors.primary,
                                  ),
                                  label: const Text('Semua'),
                                  selected: selected,
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                      color: selected ? Colors.white : null),
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() => _category = 'Semua'),
                                );
                              }
                              final c = _categories[i - 1];
                              final selected = _category == c['name'];
                              return ChoiceChip(
                                avatar: Icon(
                                  categoryIcon(c['name'] as String?),
                                  size: 16,
                                  color: selected ? Colors.white : AppColors.primary,
                                ),
                                label: Text(c['name'] as String),
                                selected: selected,
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                    color: selected ? Colors.white : null),
                                showCheckmark: false,
                                onSelected: (_) =>
                                    setState(() => _category = c['name'] as String),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filtered.isEmpty
                              ? const Center(child: Text('Buku tidak ditemukan'))
                              : ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, index) => const SizedBox(height: 12),
                                  itemBuilder: (_, i) => BookCard(
                                    book: filtered[i],
                                    onTap: () =>
                                        context.push('/books/${filtered[i].id}'),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
