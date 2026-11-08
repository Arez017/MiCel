import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF1440);
  static const bg = Color(0xFF0D0D0F);
  static const surface = Color(0xFF18181B);
  static const border = Color(0xFF27272A);
  static const text = Color(0xFFF4F4F5);
  static const muted = Color(0xFFA1A1AA);
  static const success = Color(0xFF22C55E);
  static const warn = Color(0xFFFBBF24);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg,
          labelStyle: const TextStyle(color: AppColors.muted),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
      );
}
