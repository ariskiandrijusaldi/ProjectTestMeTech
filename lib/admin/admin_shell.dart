import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'admin_common.dart';
import 'dashboard_page.dart';
import 'kelola_buku_page.dart';
import 'pengembalian_page.dart';
import 'permohonan_page.dart';
import '../../core/auth/auth_provider.dart';

/// Titik masuk modul admin. Panggil dari alur login tim:
/// Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AdminShell(onLogout: ...)));
class AdminShell extends StatefulWidget {
  final VoidCallback? onLogout;
  const AdminShell({super.key, this.onLogout});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    widget.onLogout?.call();
  }

  void _go(int i) {
    if (i < 0 || i > 4) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    final pages = <Widget>[
      DashboardPage(onSelectTab: _go),
      KelolaBukuPage(onBack: () => _go(0)),
      PermohonanPage(onBack: () => _go(0)),
      PengembalianPage(onBack: () => _go(0)),
      _ProfilPage(user: user, onLogout: _logout),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _go,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.muted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), activeIcon: Icon(Icons.menu_book), label: 'Buku'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Peminjaman'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_return_outlined), label: 'Pengembalian'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _ProfilPage extends StatelessWidget {
  final Map<String, String>? user;
  final VoidCallback onLogout;
  const _ProfilPage({this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(user?['name'] ?? 'Administrator',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 4),
          Text(user?['email'] ?? '-', style: const TextStyle(color: AppColors.muted)),
          if ((user?['nim'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('NIM: ${user?['nim']}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}