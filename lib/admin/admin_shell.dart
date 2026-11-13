import 'package:flutter/material.dart';
import 'admin_common.dart';
import 'dashboard_page.dart';
import 'kelola_buku_page.dart';
import 'permohonan_page.dart';

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

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardPage(onSelectTab: _go),
      KelolaBukuPage(onBack: () => _go(0)),
      PermohonanPage(onBack: () => _go(0)),
      _ProfilPage(onLogout: widget.onLogout),
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
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _ProfilPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const _ProfilPage({this.onLogout});

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
          const Text('Administrator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text)),
          const SizedBox(height: 4),
          const Text('admin@perpustakaan.ac.id', style: TextStyle(color: AppColors.muted)),
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
              onPressed: onLogout ?? () => showSnack(context, 'Hubungkan ke alur logout dari tim.'),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ),
        ],
      ),
    );
  }
}