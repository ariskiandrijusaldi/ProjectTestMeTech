import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

// Versi awal: tombol Login langsung masuk ke Beranda (belum ada auth).
// TODO: tambahkan form email & password setelah desain/backend jelas.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.school, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Perpustakaan Kampus',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Pinjam buku perpustakaan\nkampus lebih mudah!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              PrimaryButton(label: 'Login', onPressed: () => context.go('/home')),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Daftar Akun',
                outlined: true,
                  onPressed: () => context.push('/register'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
