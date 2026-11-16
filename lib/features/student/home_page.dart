import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/book_card.dart';
import '../../data/dummy_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final popular = dummyBooks.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Halo, Aurel! 👋',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('Semangat membaca dan belajar!',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none)),
              ],
            ),
            const SizedBox(height: 20),

            // Kartu total buku
            InkWell(
              onTap: () => context.push('/books'),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_book, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Buku',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12)),
                          Text('120',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Menu utama (grid 2x2)
            const Text('Menu Utama',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
              children: [
                _MenuTile(
                    icon: Icons.search,
                    label: 'Cari Buku',
                    onTap: () => context.push('/books')),
                _MenuTile(
                    icon: Icons.event_available,
                    label: 'Ajukan\nPeminjaman',
                    onTap: () => context.push('/books')),
                _MenuTile(
                    icon: Icons.history,
                    label: 'Riwayat',
                    onTap: () => context.go('/history')),
                _MenuTile(
                    icon: Icons.person,
                    label: 'Profil',
                    onTap: () => context.go('/profile')),
              ],
            ),
            const SizedBox(height: 24),

            // Buku populer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Buku Populer',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                TextButton(
                    onPressed: () => context.push('/books'),
                    child: const Text('Lihat Semua >')),
              ],
            ),
            for (final b in popular) ...[
              BookCard(
                  book: b, onTap: () => context.push('/books/${b.id}')),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
