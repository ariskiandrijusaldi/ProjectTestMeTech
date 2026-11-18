import 'package:flutter/material.dart';
import 'admin_common.dart';
import '../../core/api/admin_repository.dart';
import '../../core/widgets/app_confirm_dialog.dart';
import '../../core/widgets/category_icon.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  final AdminRepository _repo = AdminRepository();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _users = [];
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
      final results = await Future.wait([
        _repo.listCategories(),
        _repo.listUsers(),
      ]);
      if (!mounted) return;
      setState(() {
        _categories = results[0];
        _users = results[1];
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

  Future<void> _openForm([Map<String, dynamic>? cat]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _KategoriDialog(category: cat),
    );
    if (name == null || name.isEmpty || !mounted) return;
    try {
      if (cat == null) {
        await _repo.createCategory(name);
        if (!mounted) return;
        showSnack(context, 'Kategori "$name" ditambahkan');
      } else {
        await _repo.updateCategory(cat['id'] as int, name);
        if (!mounted) return;
        showSnack(context, 'Kategori "$name" berhasil diperbarui');
      }
      _load();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, 'Gagal: ${apiError(e)}', error: true);
    }
  }

  Future<void> _delete(Map<String, dynamic> c) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Hapus Kategori?',
      message: 'Kategori "${c['name']}" akan dihapus. Kategori yang masih dipakai buku tidak dapat dihapus.',
      icon: Icons.delete_outline_rounded,
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (ok && mounted) {
      try {
        await _repo.deleteCategory(c['id'] as int);
        if (!mounted) return;
        showSnack(context, 'Kategori "${c['name']}" berhasil dihapus');
        _load();
      } catch (e) {
        if (!mounted) return;
        showSnack(context, 'Gagal menghapus: ${apiError(e)}', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text('Master Data'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Kategori Buku'),
              Tab(text: 'Daftar Mahasiswa'),
            ],
          ),
        ),
        floatingActionButton: _loading
            ? null
            : FloatingActionButton.extended(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kategori'),
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
                : TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _categories.isEmpty
                        ? const EmptyState(icon: Icons.category, message: 'Belum ada kategori buku.')
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                            itemCount: _categories.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final c = _categories[i];
                              return AdminCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(categoryIcon(c['name'] as String?), color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(c['name'] as String,
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                                          Text('ID: ${c['id']}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                     IconButton(
                                       tooltip: 'Edit',
                                       icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                       onPressed: () => _openForm(c),
                                     ),
                                     IconButton(
                                       tooltip: 'Hapus',
                                       icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                       onPressed: () => _delete(c),
                                     ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                  RefreshIndicator(
                    onRefresh: _load,
                    child: _users.isEmpty
                        ? const EmptyState(icon: Icons.people_outline, message: 'Belum ada data mahasiswa.')
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            itemCount: _users.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final u = _users[i];
                              return AdminCard(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: AppColors.primaryLight,
                                      child: Icon(Icons.person, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(u['name'] ?? '-',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                                          const SizedBox(height: 2),
                                          Text('NIM: ${u['nim'] ?? '-'} · Email: ${u['email'] ?? '-'}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _KategoriDialog extends StatefulWidget {
  final Map<String, dynamic>? category;
  const _KategoriDialog({this.category});

  @override
  State<_KategoriDialog> createState() => _KategoriDialogState();
}

class _KategoriDialogState extends State<_KategoriDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name.text = widget.category?['name'] as String? ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Nama Kategori'),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama kategori wajib diisi' : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _name.text.trim());
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
