import 'package:flutter/material.dart';
import 'models.dart';

class AppColors {
  static const primary = Color(0xFF4F3FC9);
  static const primaryLight = Color(0xFFEDEBFF);
  static const statBlue = Color(0xFFE4EBFB);
  static const text = Color(0xFF1B1B3A);
  static const muted = Color(0xFF7A7A93);
  static const border = Color(0xFFEAEAF4);
  static const thumb = Color(0xFFF1F2F8);
  static const success = Color(0xFF2E9E5B);
  static const successBg = Color(0xFFE3F6EA);
  static const warn = Color(0xFF9A6A0A);
  static const warnBg = Color(0xFFFFF1C9);
  static const danger = Color(0xFFE5484D);
  static const dangerBg = Color(0xFFFDE8E8);
}

ThemeData adminTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(
        color: AppColors.text,
        fontSize: 17,
        fontWeight: FontWeight.w600,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    ),
  );
}

const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

String formatTanggalJam(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '${formatTanggal(d)}, $h:$m';
}

String formatRupiah(int n) {
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

/// Kartu putih dengan border tipis & bayangan halus.
class AdminCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const AdminCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0F4F3FC9), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Thumbnail cover buku. Memakai gambar dari URL (kolom `cover`);
/// jika kosong atau gagal dimuat, tampil ikon buku.
class ItemThumb extends StatelessWidget {
  final String cover;
  final double size;
  const ItemThumb({super.key, this.cover = '', this.size = 56});

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.menu_book, color: AppColors.primary, size: size * 0.5);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.thumb,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: cover.trim().startsWith('http')
          ? Image.network(
        cover.trim(),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) =>
        progress == null ? child : fallback,
      )
          : fallback,
    );
  }
}

class StatusChip extends StatelessWidget {
  final LoanStatus status;
  final bool compact;
  const StatusChip({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    late Color fg, bg;
    late String label;
    switch (status) {
      case LoanStatus.pending:
        fg = AppColors.warn;
        bg = AppColors.warnBg;
        label = 'Menunggu';
        break;
      case LoanStatus.approved:
        fg = AppColors.success;
        bg = AppColors.successBg;
        label = 'Disetujui';
        break;
      case LoanStatus.rejected:
        fg = AppColors.danger;
        bg = AppColors.dangerBg;
        label = 'Ditolak';
        break;
      case LoanStatus.returned:
        fg = AppColors.primary;
        bg = AppColors.primaryLight;
        label = 'Dikembalikan';
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.muted.withAlpha(120)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

void showSnack(BuildContext context, String msg, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? AppColors.danger : AppColors.text,
    ));
}