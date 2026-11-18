import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1B4F84); // biru tua
  static const primarySoft = Color(0xFFE6F0FA); // biru muda
  static const background = Colors.white;
  static const surface = Color(0xFFF1F6FB);
  static const textPrimary = Color(0xFF14283D);
  static const textSecondary = Color(0xFF6B7C8F);

  // Status
  static const pendingBg = Color(0xFFFFF3C4);
  static const pendingFg = Color(0xFF9A6A00);
  static const approvedBg = Color(0xFFDFF5E3);
  static const approvedFg = Color(0xFF1E8E3E);
  static const rejectedBg = Color(0xFFFDE2E2);
  static const rejectedFg = Color(0xFFD93025);

  static const thumb = Color(0xFFF1F2F8);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
