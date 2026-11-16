import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'kategori_page.dart';
import 'models.dart';

class KelolaBukuPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaBukuPage({super.key, this.onBack});

  @override
  State<KelolaBukuPage> createState() => _KelolaBukuPageState();
}

class _KelolaBukuPageState extends State<KelolaBukuPage> {
  final _store = AdminStore.instance;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openForm([Book? book]) async {
    if (_store.categories.isEmpty) {
      showSnack(context, 'Buat kategori dulu sebelum menambah buku.', error: true);
      return;
    }
    final result = await showModalBottomSheet<BookInput>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookForm(book: book),
    );
    if (result == null || !mounted) return;

    if (book == null) {
      _store.tambahBuku(result);
      showSnack(context, '"${result.title}" berhasil ditambahkan');
    } else {
      _store.ubahBuku(book.id, result);
      showSnack(context, '"${result.title}" berhasil diperbarui');
    }
  }

  Future<void> _confirmDelete(Book b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus buku?'),
        content: Text('"${b.title}" akan dihapus dari koleksi perpustakaan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final err = _store.hapusBuku(b.id);
      if (err != null) {
        showSnack(context, err, error: true);
      } else {
        showSnack(context, '"${b.title}" dihapus');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: widget.onBack ?? () => Navigator.maybePop(context),
        ),
        title: const Text('Kelola Buku'),
        actions: [
          IconButton(
            tooltip: 'Kelola Kategori',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const KategoriPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, penulis, ISBN...',
                      hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.muted),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          _search.clear();
                          _query = '';
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Tambah'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _store,
              builder: (context, _) {
                final list = _store.books
                    .where((b) =>
                b.title.toLowerCase().contains(_query) ||
                    b.author.toLowerCase().contains(_query) ||
                    b.isbn.toLowerCase().contains(_query))
                    .toList();
                if (list.isEmpty) {
                  return EmptyState(
                    icon: Icons.menu_book_outlined,
                    message: _query.isEmpty
                        ? 'Belum ada buku.\nTekan "Tambah" untuk menambahkan.'
                        : 'Buku "$_query" tidak ditemukan.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final b = list[i];
                    final kategori = _store.categoryName(b.categoryId);
                    return AdminCard(
                      onTap: () => _openForm(b),
                      child: Row(
                        children: [
                          ItemThumb(cover: b.cover, size: 56),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(b.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                                const SizedBox(height: 2),
                                Text(b.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                const SizedBox(height: 2),
                                Text(
                                  '$kategori${b.rackLocation.isEmpty ? '' : ' · Rak ${b.rackLocation}'}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                                ),
                                const SizedBox(height: 2),
                                Text('Stok: ${b.stockAvailable}/${b.stockTotal}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: b.stockAvailable == 0 ? AppColors.danger : AppColors.text,
                                    )),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit',
                            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
                            onPressed: () => _openForm(b),
                          ),
                          IconButton(
                            tooltip: 'Hapus',
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                            onPressed: () => _confirmDelete(b),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BookForm extends StatefulWidget {
  final Book? book;
  const _BookForm({this.book});

  @override
  State<_BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<_BookForm> {
  final _store = AdminStore.instance;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cover;
  late final TextEditingController _isbn;
  late final TextEditingController _title;
  late final TextEditingController _author;
  late final TextEditingController _publisher;
  late final TextEditingController _year;
  late final TextEditingController _rack;
  late final TextEditingController _stock;
  late final TextEditingController _synopsis;
  int? _categoryId;

  bool get _edit => widget.book != null;

  /// Stok total tidak boleh di bawah jumlah buku yang sedang dipinjam.
  int get _minStok =>
      widget.book == null ? 0 : widget.book!.stockTotal - widget.book!.stockAvailable;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _cover = TextEditingController(text: b?.cover ?? '');
    _isbn = TextEditingController(text: b?.isbn ?? '');
    _title = TextEditingController(text: b?.title ?? '');
    _author = TextEditingController(text: b?.author ?? '');
    _publisher = TextEditingController(text: b?.publisher ?? '');
    _year = TextEditingController(text: b?.year.toString() ?? '');
    _rack = TextEditingController(text: b?.rackLocation ?? '');
    _stock = TextEditingController(text: b?.stockTotal.toString() ?? '');
    _synopsis = TextEditingController(text: b?.synopsis ?? '');
    _categoryId = b?.categoryId ??
        (_store.categories.isNotEmpty ? _store.categories.first.id : null);
  }

  @override
  void dispose() {
    for (final c in [_cover, _isbn, _title, _author, _publisher, _year, _rack, _stock, _synopsis]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      BookInput(
        categoryId: _categoryId!,
        isbn: _isbn.text.trim(),
        title: _title.text.trim(),
        author: _author.text.trim(),
        publisher: _publisher.text.trim(),
        year: int.parse(_year.text.trim()),
        synopsis: _synopsis.text.trim(),
        cover: _cover.text.trim(),
        rackLocation: _rack.text.trim(),
        stockTotal: int.parse(_stock.text.trim()),
      ),
    );
  }

  String? _req(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(height: 16),
              Text(_edit ? 'Edit Buku' : 'Tambah Buku',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cover,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Cover (URL gambar)',
                  hintText: 'https://... (opsional)',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _isbn,
                decoration: const InputDecoration(labelText: 'ISBN'),
                validator: (v) {
                  final e = _req(v, 'ISBN');
                  if (e != null) return e;
                  if (_store.isbnTerpakai(v!.trim(), exceptId: widget.book?.id)) {
                    return 'ISBN sudah terdaftar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Judul buku'),
                validator: (v) => _req(v, 'Judul'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _author,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Penulis'),
                validator: (v) => _req(v, 'Penulis'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _publisher,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(labelText: 'Penerbit'),
                      validator: (v) => _req(v, 'Penerbit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tahun'),
                      validator: (v) {
                        final n = int.tryParse((v ?? '').trim());
                        if (n == null) return 'Isi angka';
                        if (n < 1000 || n > DateTime.now().year) return 'Tahun tidak valid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Kategori'),
                      items: [
                        for (final c in _store.categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                      validator: (v) => v == null ? 'Pilih kategori' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _rack,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(labelText: 'Lokasi rak'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Stok total',
                  helperText: _edit && _minStok > 0
                      ? 'Minimal $_minStok (sedang dipinjam)'
                      : null,
                ),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Isi angka';
                  if (n < 0) return 'Tidak boleh minus';
                  if (n < _minStok) return 'Minimal $_minStok (sedang dipinjam)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _synopsis,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Sinopsis'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(_edit ? 'Simpan Perubahan' : 'Tambah Buku'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 