import 'package:flutter/material.dart';
import 'admin/admin_common.dart';
import 'admin/admin_shell.dart';

void main() => runApp(const PerpustakaanApp());

class PerpustakaanApp extends StatelessWidget {
  const PerpustakaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan',
      debugShowCheckedModeBanner: false,
      theme: adminTheme(),
      // Sementara langsung ke modul admin. Setelah login dari tim siap,
      // arahkan ke AdminShell(onLogout: ...) dari alur login.
      home: const AdminShell(),
    );
  }
}