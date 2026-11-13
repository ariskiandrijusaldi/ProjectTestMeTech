import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'models.dart';

class KategoriPage extends StatelessWidget {
  const KategoriPage({super.key});

  Future<void> _openForm(BuildContext context, [Category? cat]) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _KategoriDialog(category: cat),
    );
    if (name == null || !context.mounted) return;
    final store = AdminStore.instance;
    if (cat == null) {
      store.tambahKategori(name);
      showSnack(context, 'Kategori "$name" ditambahkan');
    } else {
      store.ubahKategori(cat.id, name);
      showSnack(context, 'Kategori diperbarui');
    }
  }

  Future<void> _delete(BuildContext context, Category c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus kategori?'),
        content: Text('Kategori "${c.name}" akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final err = AdminStore.instance.hapusKategori(c.id);
      showSnack(context, err ?? 'Kategori "${c.name}" dihapus', error: err != null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AdminStore.instance;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Kelola Kategori'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list = store.categories;
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.category_outlined,
              message: 'Belum ada kategori.\nTekan "Tambah" untuk membuat.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final c = list[i];
              final jumlah = store.jumlahBukuDiKategori(c.id);
              return AdminCard(
                onTap: () => _openForm(context, c),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.category, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                          const SizedBox(height: 2),
                          Text('$jumlah buku',
                              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.muted),
                      onPressed: () => _openForm(context, c),
                    ),
                    IconButton(
                      tooltip: 'Hapus',
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                      onPressed: () => _delete(context, c),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _KategoriDialog extends StatefulWidget {
  final Category? category;
  const _KategoriDialog({this.category});

  @override
  State<_KategoriDialog> createState() => _KategoriDialogState();
}

class _KategoriDialogState extends State<_KategoriDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.category != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(edit ? 'Edit Kategori' : 'Tambah Kategori'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nama kategori'),
          validator: (v) {
            final s = (v ?? '').trim();
            if (s.isEmpty) return 'Nama wajib diisi';
            if (AdminStore.instance.namaKategoriTerpakai(s, exceptId: widget.category?.id)) {
              return 'Nama kategori sudah ada';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
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