import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'models.dart';

class PengembalianPage extends StatelessWidget {
  final int loanId;
  const PengembalianPage({super.key, required this.loanId});

  @override
  Widget build(BuildContext context) {
    final store = AdminStore.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Pengembalian Buku'),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final p = store.loanById(loanId);
          if (p == null) {
            return const EmptyState(icon: Icons.search_off, message: 'Data peminjaman tidak ditemukan.');
          }
          final book = store.bookById(p.bookId);
          final user = store.userById(p.userId);
          final dikembalikan = p.status == LoanStatus.returned;
          final dipinjam = p.status == LoanStatus.approved;
          final denda = dikembalikan ? p.fineAmount : p.dendaBerjalan;

          late Color statusColor;
          late String statusTitle;
          late String statusDesc;
          late IconData statusIcon;
          if (dikembalikan) {
            statusColor = AppColors.success;
            statusTitle = 'Sudah Dikembalikan';
            statusDesc = p.returnedAt != null ? formatTanggalJam(p.returnedAt!) : '-';
            statusIcon = Icons.check;
          } else if (p.terlambat) {
            statusColor = AppColors.danger;
            statusTitle = 'Terlambat ${p.hariTerlambat} hari';
            statusDesc = 'Menunggu konfirmasi pengembalian';
            statusIcon = Icons.warning_amber_rounded;
          } else {
            statusColor = AppColors.warn;
            statusTitle = 'Sedang Dipinjam';
            statusDesc = 'Menunggu konfirmasi pengembalian';
            statusIcon = Icons.schedule;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              AdminCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ItemThumbLarge(cover: book?.cover ?? ''),
                    const SizedBox(height: 12),
                    Text(book?.title ?? 'Buku tidak ditemukan',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                    const SizedBox(height: 4),
                    Text('No. ${p.code}', style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    Text(
                      'Dipinjam: ${formatTanggal(p.approvedAt ?? p.requestedAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    if (p.dueDate != null)
                      Text('Batas kembali: ${formatTanggal(p.dueDate!)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    Text(
                      'Peminjam: ${user?.name ?? '-'}${user?.nim == null ? '' : ' (${user!.nim})'}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: dipinjam
                            ? () {
                          store.konfirmasiPengembalian(p.id);
                          showSnack(context, 'Pengembalian #${p.code} dikonfirmasi');
                        }
                            : null,
                        child: const Text('Konfirmasi\nPengembalian', textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Status',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 10),
              AdminCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      child: Icon(statusIcon, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(statusTitle,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: statusColor)),
                          const SizedBox(height: 2),
                          Text(statusDesc,
                              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (denda > 0) ...[
                const SizedBox(height: 20),
                const Text('Denda',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 10),
                AdminCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dikembalikan ? 'Total denda' : 'Denda berjalan',
                            style: const TextStyle(fontSize: 13, color: AppColors.muted),
                          ),
                          Text(formatRupiah(denda),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${p.hariTerlambat} hari × ${formatRupiah(kDendaPerHari)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.muted),
                        ),
                      ),
                      if (dikembalikan) ...[
                        const SizedBox(height: 12),
                        if (p.finePaid)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 18, color: AppColors.success),
                                SizedBox(width: 6),
                                Text('Denda sudah lunas',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                store.tandaiDendaLunas(p.id);
                                showSnack(context, 'Denda #${p.code} ditandai lunas');
                              },
                              child: const Text('Tandai Denda Lunas'),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Cover besar untuk halaman detail.
class ItemThumbLarge extends StatelessWidget {
  final String cover;
  const ItemThumbLarge({super.key, required this.cover});

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.menu_book, size: 64, color: AppColors.primary);
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.thumb,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: cover.trim().startsWith('http')
          ? Image.network(
        cover.trim(),
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback,
      )
          : fallback,
    );
  }
}