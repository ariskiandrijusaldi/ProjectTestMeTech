import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'models.dart';
import 'pengembalian_page.dart';

class DashboardPage extends StatelessWidget {
  final ValueChanged<int> onSelectTab;
  const DashboardPage({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    final store = AdminStore.instance;

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Text('Perpustakaan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ),
              for (final e in const [
                [0, 'Dashboard', Icons.home_outlined],
                [1, 'Kelola Buku', Icons.menu_book_outlined],
                [2, 'Peminjaman', Icons.history],
                [3, 'Profil', Icons.person_outline],
              ])
                ListTile(
                  leading: Icon(e[2] as IconData, color: AppColors.primary),
                  title: Text(e[1] as String),
                  onTap: () {
                    Navigator.pop(context);
                    onSelectTab(e[0] as int);
                  },
                ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final recent = store.terbaru.take(3).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.menu, color: AppColors.text),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFD9D9E3),
                      child: Icon(Icons.person, size: 20, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Dashboard',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.text)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book,
                        label: 'Total Buku',
                        value: store.totalBuku,
                        onTap: () => onSelectTab(1),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.groups,
                        label: 'Total Peminjaman',
                        value: store.totalPeminjaman,
                        onTap: () => onSelectTab(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Peminjaman Terbaru',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.text)),
                    InkWell(
                      onTap: () => onSelectTab(2),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Row(children: [
                          Text('Lihat Semua',
                              style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                          Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (recent.isEmpty)
                  const SizedBox(height: 160, child: EmptyState(icon: Icons.history, message: 'Belum ada peminjaman.'))
                else
                  for (final p in recent)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AdminCard(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        onTap: p.status == LoanStatus.approved || p.status == LoanStatus.returned
                            ? () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => PengembalianPage(loanId: p.id)))
                            : null,
                        child: Row(
                          children: [
                            ItemThumb(cover: store.bookById(p.bookId)?.cover ?? '', size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('#${p.code}',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text)),
                                  const SizedBox(height: 3),
                                  StatusChip(status: p.status, compact: true),
                                ],
                              ),
                            ),
                            Text(formatTanggal(p.requestedAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final VoidCallback onTap;
  const _StatCard({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.statBlue,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, size: 34, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.text)),
              const SizedBox(height: 2),
              Text('$value',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.text)),
            ],
          ),
        ),
      ),
    );
  }
}