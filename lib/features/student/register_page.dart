import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameC = TextEditingController();
  final _nimC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _nameC.dispose();
    _nimC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // TODO: kirim data ke API register
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pendaftaran berhasil, silakan login')),
    );
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.school, size: 56, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text('Buat Akun Baru',
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                const Center(
                  child: Text('Daftar untuk meminjam buku perpustakaan kampus',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
                const SizedBox(height: 24),

                _label('Nama Lengkap'),
                TextFormField(
                  controller: _nameC,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Nama wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                _label('NIM'),
                TextFormField(
                  controller: _nimC,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Nomor Induk Mahasiswa',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'NIM wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),

                _label('Email'),
                TextFormField(
                  controller: _emailC,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email wajib diisi';
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Password'),
                TextFormField(
                  controller: _passC,
                  obscureText: _hidePass,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Minimal 6 karakter',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hidePass
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () => setState(() => _hidePass = !_hidePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password wajib diisi';
                    if (v.length < 6) return 'Password minimal 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _label('Konfirmasi Password'),
                TextFormField(
                  controller: _confirmC,
                  obscureText: _hideConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Ulangi password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_hideConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _hideConfirm = !_hideConfirm),
                    ),
                  ),
                  validator: (v) =>
                  v != _passC.text ? 'Password tidak sama' : null,
                ),
                const SizedBox(height: 28),

                PrimaryButton(label: 'Daftar', onPressed: _submit),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun?',
                        style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}