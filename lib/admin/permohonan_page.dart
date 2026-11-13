import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'models.dart';
import 'pengembalian_page.dart';

class PermohonanPage extends StatelessWidget {
  final VoidCallback? onBack;
  const PermohonanPage({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final store = AdminStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final menunggu = store.menunggu;
        final riwayat = store.riwayat;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                onPressed: onBack ?? () => Navigator.maybePop(context),
              ),
              title: const Text('Permohonan Peminjaman'),
              bottom: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.muted,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: AppColors.border,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                tabs: [
                  Tab(text: 'Menunggu (${menunggu.length})'),
                  const Tab(text: 'Riwayat'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildMenunggu(context, store, menunggu),
                _buildRiwayat(context, store, riwayat),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenunggu(BuildContext context, AdminStore store, List<Loan> list) {
    if (list.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: 'Tidak ada permohonan yang menunggu.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        final p = list[i];
        final book = store.bookById(p.bookId);
        final user = store.userById(p.userId);
        return AdminCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ItemThumb(cover: book?.cover ?? '', size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${p.code}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(book?.title ?? 'Buku tidak ditemukan',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(
                          '${user?.name ?? '-'}${user?.nim == null ? '' : ' · ${user!.nim}'}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                        Text('Diajukan ${formatTanggal(p.requestedAt)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        if (book != null)
                          Text('Stok tersedia: ${book.stockAvailable}',
                              style: TextStyle(
                                fontSize: 12,
                                color: book.stockAvailable == 0 ? AppColors.danger : AppColors.muted,
                              )),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      minimumSize: const Size(84, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      final alasan = await showDialog<String>(
                        context: context,
                        builder: (_) => const _TolakDialog(),
                      );
                      if (alasan != null && context.mounted) {
                        store.tolak(p.id, alasan);
                        showSnack(context, 'Permohonan #${p.code} ditolak');
                      }
                    },
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(84, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final err = store.setujui(p.id);
                      if (err != null) {
                        showSnack(context, err, error: true);
                      } else {
                        showSnack(context, 'Permohonan #${p.code} disetujui');
                      }
                    },
                    child: const Text('Setujui'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiwayat(BuildContext context, AdminStore store, List<Loan> list) {
    if (list.isEmpty) {
      return const EmptyState(icon: Icons.history, message: 'Riwayat masih kosong.');
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final p = list[i];
        final book = store.bookById(p.bookId);
        final user = store.userById(p.userId);
        final bisaDibuka =
            p.status == LoanStatus.approved || p.status == LoanStatus.returned;
        final bisaDihapus = p.status != LoanStatus.approved;
        return AdminCard(
          onTap: bisaDibuka
              ? () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => PengembalianPage(loanId: p.id)))
              : null,
          child: Row(
            children: [
              ItemThumb(cover: book?.cover ?? '', size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${p.code}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                    Text('${book?.title ?? '-'} · ${user?.name ?? '-'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Row(children: [
                      StatusChip(status: p.status),
                      const SizedBox(width: 8),
                      Text(formatTanggal(p.requestedAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ]),
                    if (p.status == LoanStatus.rejected && (p.rejectedReason ?? '').isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Alasan: ${p.rejectedReason}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.danger)),
                      ),
                    if (p.terlambat)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Terlambat ${p.hariTerlambat} hari',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger)),
                      ),
                    if (p.status == LoanStatus.returned && p.fineAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Denda ${formatRupiah(p.fineAmount)} · ${p.finePaid ? 'Lunas' : 'Belum lunas'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: p.finePaid ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (bisaDihapus)
                IconButton(
                  tooltip: 'Hapus riwayat',
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Hapus riwayat?'),
                        content: Text('Data #${p.code} akan dihapus permanen.'),
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
                      store.hapusPeminjaman(p.id);
                      showSnack(context, 'Riwayat #${p.code} dihapus');
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Dialog alasan penolakan (kolom rejected_reason wajib diisi).
class _TolakDialog extends StatefulWidget {
  const _TolakDialog();

  @override
  State<_TolakDialog> createState() => _TolakDialogState();
}

class _TolakDialogState extends State<_TolakDialog> {
  final _formKey = GlobalKey<FormState>();
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tolak permohonan'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _alasan,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Alasan penolakan'),
          validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Alasan wajib diisi' : null,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            minimumSize: const Size(80, 40),
          ),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _alasan.text.trim());
            }
          },
          child: const Text('Tolak'),
        ),
      ],
    );
  }
}