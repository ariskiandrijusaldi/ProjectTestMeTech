import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/primary_button.dart';

// Placeholder: belum ada di desain.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: 12),
            const Text('Aurel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            PrimaryButton(
                label: 'Keluar',
                outlined: true,
                onPressed: () => context.go('/login')),
          ],
        ),
      ),
    );
  }
}
