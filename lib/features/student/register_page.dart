import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/api/api_service.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _name = TextEditingController();
  final _nim = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _fieldErrors;

  @override
  void dispose() {
    _name.dispose();
    _nim.dispose();
    _email.dispose();
    _password.dispose();
    _passwordConfirmation.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _name.text.trim();
    final nim = _nim.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    final passwordConfirmation = _passwordConfirmation.text;

    if (name.isEmpty ||
        nim.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        passwordConfirmation.isEmpty) {
      setState(() {
        _error = 'Semua data wajib diisi.';
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _error = 'Password minimal 8 karakter.';
      });
      return;
    }
    if (password != passwordConfirmation) {
      setState(() {
        _error = 'Konfirmasi password tidak cocok.';
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
      await authProvider.register(
        name: name,
        nim: nim,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (!mounted) return;
      context.go('/home');
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

  String? _fieldError(String key) {
    final value = _fieldErrors?[key];
    if (value is List) return value.join(', ');
    if (value != null) return value.toString();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const Icon(Icons.school, size: 72, color: AppColors.primary),
              const SizedBox(height: 12),
              const Text('Buat Akun Mahasiswa',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Daftar untuk mulai meminjam buku kampus',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 28),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: _fieldError('name'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nim,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NIM',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText: _fieldError('nim'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  errorText: _fieldError('email'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  errorText: _fieldError('password'),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordConfirmation,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  errorText: _fieldError('password_confirmation'),
                ),
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
                  label: _loading ? 'Memproses...' : 'Daftar',
                  onPressed: _loading ? null : _register,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loading ? null : () => context.go('/login'),
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
