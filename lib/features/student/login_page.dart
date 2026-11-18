import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_service.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _fieldErrors;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailOrNim = _email.text.trim();
    final password = _password.text;

    if (emailOrNim.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Email/NIM dan password wajib diisi.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _fieldErrors = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final user = await authProvider.login(emailOrNim, password);
      if (!mounted) return;

      if (user.isAdmin) {
        context.go('/admin');
      } else {
        context.go('/home');
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _fieldErrors = e.errors;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal terhubung ke server. Periksa koneksi backend.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school, size: 80, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Perpustakaan Kampus',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Login untuk meminjam buku kampus',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'Email atau NIM',
                  prefixIcon: const Icon(Icons.email),
                  errorText: _fieldErrors?['email'] != null
                      ? (_fieldErrors!['email'] as List).join(', ')
                      : null,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _fieldErrors?['password'] != null
                      ? (_fieldErrors!['password'] as List).join(', ')
                      : null,
                ),
                obscureText: true,
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.rejectedBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.rejectedFg, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: AppColors.rejectedFg, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: _loading ? 'Memproses...' : 'Login',
                  onPressed: _loading ? null : _login,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Daftar Akun',
                  outlined: true,
                  onPressed: _loading ? null : () => context.go('/register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
