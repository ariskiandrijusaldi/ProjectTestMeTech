import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'admin_common.dart';
import 'kategori_page.dart';
import '../../core/api/admin_repository.dart';
import '../../core/models/api_book.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/category_icon.dart';

class KelolaBukuPage extends StatefulWidget {
  final VoidCallback? onBack;
  const KelolaBukuPage({super.key, this.onBack});

  @override
  State<KelolaBukuPage> createState() => _KelolaBukuPageState();
}

class _KelolaBukuPageState extends State<KelolaBukuPage> {
  final _repo = AdminRepository();
  final _search = TextEditingController();
  String _query = '';
  List<ApiBook> _books = [];
  bool _loading = true;
  String? _error;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
      final res = await _repo.listBooks();
      final list = (res['data'] as List? ?? []);
      if (!mounted) return;
      setState(() {
        _books = list.map((e) => ApiBook.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = apiError(e);
        _loading = false;
      });
    }
  }

  Future<void> _openForm([ApiBook? book]) async {
    final cats = await _repo.listCategories();
    if (cats.isEmpty && book == null) {
      if (!mounted) return;
      showSnack(context, 'Buat kategori dulu sebelum menambah buku.', error: true);
      return;
    }
    if (!mounted) return;
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _BookForm(book: book, categories: cats),
    );
    if (result == null || !mounted) return;
    try {
      final coverBytes = result['coverBytes'] as Uint8List?;
      final coverName = result['coverName'] as String?;
      if (book == null) {
        await _repo.createBook(
          categoryId: result['categoryId'] as int,
          isbn: result['isbn'] as String,
          title: result['title'] as String,
          author: result['author'] as String,
          publisher: result['publisher'] as String?,
          year: result['year'] as int?,
          synopsis: result['synopsis'] as String?,
          rackLocation: result['rackLocation'] as String?,
          stockTotal: result['stockTotal'] as int,
          coverBytes: coverBytes,
          coverFileName: coverName,
        );
        if (!mounted) return;
        showSnack(context, '"${result['title']}" berhasil ditambahkan');
      } else {
        await _repo.updateBook(
          bookId: book.id,
          categoryId: result['categoryId'] as int,
          isbn: result['isbn'] as String,
          title: result['title'] as String,
          author: result['author'] as String,
          publisher: result['publisher'] as String?,
          year: result['year'] as int?,
          synopsis: result['synopsis'] as String?,
          rackLocation: result['rackLocation'] as String?,
          stockTotal: result['stockTotal'] as int,
          coverBytes: coverBytes,
          coverFileName: coverName,
        );
        if (!mounted) return;
        showSnack(context, '"${result['title']}" berhasil diperbarui');
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal: ${apiError(e)}', error: true);
    }
  }

  Future<void> _confirmDelete(ApiBook b) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Hapus Buku?',
      message: '"${b.title}" akan dihapus dari koleksi perpustakaan.',
      icon: Icons.delete_outline_rounded,
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (ok && mounted) {
      try {
        await _repo.deleteBook(b.id);
        if (!mounted) return;
        showSnack(context, '"${b.title}" berhasil dihapus');
        _load();
      } catch (e) {
        if (!mounted) return;
        showSnack(context, 'Gagal: ${apiError(e)}', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _books.where((b) {
      if (_query.isEmpty) return true;
      return b.title.toLowerCase().contains(_query) ||
          b.author.toLowerCase().contains(_query) ||
          (b.isbn?.toLowerCase().contains(_query) ?? false);
    }).toList();

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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
                        const SizedBox(height: 12),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
                        const SizedBox(height: 16),
                        OutlinedButton(onPressed: _load, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : Column(
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
                  child: filtered.isEmpty
                      ? const EmptyState(icon: Icons.menu_book, message: 'Tidak ada buku ditemukan.')
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: filtered.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final b = filtered[i];
                              final kategori = b.category?['name'] ?? '-';
                              return AdminCard(
                                onTap: () => _openForm(b),
                                child: Row(
                                  children: [
                                    ItemThumb(cover: b.coverUrl ?? '', size: 56),
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
                                          Row(
                                            children: [
                                              Icon(categoryIcon(b.category?['name']),
                                                  size: 12, color: AppColors.muted),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  '$kategori${b.rackLocation == null || b.rackLocation!.isEmpty ? '' : ' · Rak ${b.rackLocation}'}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                                                ),
                                              ),
                                            ],
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
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}

class _BookForm extends StatefulWidget {
  final ApiBook? book;
  final List<Map<String, dynamic>> categories;
  const _BookForm({this.book, required this.categories});

  @override
  State<_BookForm> createState() => _BookFormState();
}

class _BookFormState extends State<_BookForm> {
  final _formKey = GlobalKey<FormState>();
  final _isbn = TextEditingController();
  final _title = TextEditingController();
  final _author = TextEditingController();
  final _publisher = TextEditingController();
  final _year = TextEditingController();
  final _rack = TextEditingController();
  final _stock = TextEditingController();
  final _synopsis = TextEditingController();
  Uint8List? _coverBytes;
  String? _coverName;
  int? _categoryId;

  bool get _edit => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _isbn.text = b?.isbn ?? '';
    _title.text = b?.title ?? '';
    _author.text = b?.author ?? '';
    _publisher.text = b?.publisher ?? '';
    _year.text = b?.year?.toString() ?? '';
    _rack.text = b?.rackLocation ?? '';
    _stock.text = b?.stockTotal.toString() ?? '';
    _synopsis.text = b?.synopsis ?? '';
    _categoryId = b?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.first['id'] as int : null);
  }

  @override
  void dispose() {
    for (final c in [_isbn, _title, _author, _publisher, _year, _rack, _stock, _synopsis]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (!mounted) return;
    setState(() {
      _coverBytes = bytes;
      _coverName = file.name;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'categoryId': _categoryId,
      'isbn': _isbn.text.trim(),
      'title': _title.text.trim(),
      'author': _author.text.trim(),
      'publisher': _publisher.text.trim().isEmpty ? null : _publisher.text.trim(),
      'year': int.tryParse(_year.text.trim()),
      'synopsis': _synopsis.text.trim().isEmpty ? null : _synopsis.text.trim(),
      'rackLocation': _rack.text.trim().isEmpty ? null : _rack.text.trim(),
      'stockTotal': int.tryParse(_stock.text.trim()) ?? 0,
      'coverBytes': _coverBytes,
      'coverName': _coverName,
    });
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
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 100,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.thumb,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: _coverBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(_coverBytes!, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.add_a_photo, color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _isbn,
                          decoration: const InputDecoration(labelText: 'ISBN'),
                          validator: (v) => _req(v, 'ISBN'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _title,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Judul buku'),
                          validator: (v) => _req(v, 'Judul'),
                        ),
                      ],
                    ),
                  ),
                ],
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _year,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tahun'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: [
                  for (final c in widget.categories)
                    DropdownMenuItem(value: c['id'] as int, child: Text(c['name'] as String)),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Pilih kategori' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rack,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Lokasi rak'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stock,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok total'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null) return 'Isi angka';
                  if (n < 0) return 'Tidak boleh minus';
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
