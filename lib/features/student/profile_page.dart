import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            Text(user?['name'] ?? '-',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(user?['email'] ?? '-', style: const TextStyle(color: AppColors.textSecondary)),
            if ((user?['nim'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('NIM: ${user?['nim']}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
            const SizedBox(height: 8),
            Text('Role: ${user?['role'] ?? '-'}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                  label: 'Keluar',
                  outlined: true,
                  onPressed: () => _logout(context)),
            ),
          ],
        ),
      ),
    );
  }
}