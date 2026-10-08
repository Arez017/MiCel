import 'package:flutter/material.dart';

/// ==========================================
/// MICEL — Tema Neon (negro / rojo / amarillo)
/// Mismo lenguaje visual que styles.css / extensions.css
/// ==========================================

class AppColors {
  AppColors._();

  // Núcleo neon
  static const primary = Color(0xFFFF1440); // rojo neon
  static const primaryDark = Color(0xFFC4002F);
  static const primaryLight = Color(0x24FF1440); // ~14% opacidad

  static const accent = Color(0xFFFFE600); // amarillo neon
  static const accentDark = Color(0xFFD4BF00);
  static const accentLight = Color(0x24FFE600);

  static const success = Color(0xFFC6FF2E); // amarillo-lima
  static const successLight = Color(0x24C6FF2E);
  static const warning = Color(0xFFFFB800);
  static const warningLight = Color(0x24FFB800);
  static const danger = Color(0xFFFF1440);
  static const dangerLight = Color(0x29FF1440);

  // Superficies oscuras
  static const background = Color(0xFF0A0A0C);
  static const surface = Color(0xFF16161A);
  static const surfaceAlt = Color(0xFF1D1D22);

  // Escala de grises (invertida, texto claro sobre fondo negro)
  static const gray50 = Color(0xFF1A1A1F);
  static const gray100 = Color(0xFF222227);
  static const gray200 = Color(0xFF2D2D33);
  static const gray300 = Color(0xFF3C3C43);
  static const gray400 = Color(0xFF6E6E76);
  static const gray500 = Color(0xFF8D8D95);
  static const gray600 = Color(0xFFB3B3BA);
  static const gray700 = Color(0xFFD3D3D8);
  static const gray800 = Color(0xFFECECEF);
  static const gray900 = Color(0xFFFFFFFF);

  // Glows (para BoxShadow)
  static List<BoxShadow> glowRed = [
    BoxShadow(color: primary.withOpacity(0.45), blurRadius: 16, spreadRadius: 0),
  ];
  static List<BoxShadow> glowYellow = [
    BoxShadow(color: accent.withOpacity(0.40), blurRadius: 16, spreadRadius: 0),
  ];
}

class AppTheme {
  AppTheme._();

  static const double radius = 8;
  static const double radiusLg = 12;

  static ThemeData get theme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSecondary: Color(0xFF0A0A0C),
        onSurface: AppColors.gray800,
        onError: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'DM Sans',
        bodyColor: AppColors.gray800,
        displayColor: AppColors.gray900,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.gray900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.gray900,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        hintStyle: const TextStyle(color: AppColors.gray500, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.gray600, fontSize: 12, fontWeight: FontWeight.w500),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceAlt,
          foregroundColor: AppColors.gray700,
          side: const BorderSide(color: AppColors.gray300),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      dividerTheme: const DividerThemeData(color: AppColors.gray100, thickness: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: const TextStyle(color: AppColors.gray800),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        behavior: SnackBarBehavior.floating,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.gray100,
        labelStyle: const TextStyle(color: AppColors.gray700, fontSize: 11),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: const BorderSide(color: AppColors.gray200),
        ),
        titleTextStyle: const TextStyle(color: AppColors.gray900, fontSize: 16, fontWeight: FontWeight.w600),
        contentTextStyle: const TextStyle(color: AppColors.gray700, fontSize: 13),
      ),
    );
  }
}

/// ==========================================
/// Badge reutilizable (equivalente a .badge-green / .badge-amber / etc.)
/// ==========================================
class MiCelBadge extends StatelessWidget {
  final String text;
  final MiCelBadgeType type;

  const MiCelBadge({super.key, required this.text, this.type = MiCelBadgeType.info});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    switch (type) {
      case MiCelBadgeType.success:
        bg = AppColors.successLight; fg = AppColors.success; break;
      case MiCelBadgeType.warning:
        bg = AppColors.warningLight; fg = AppColors.warning; break;
      case MiCelBadgeType.danger:
        bg = AppColors.dangerLight; fg = AppColors.danger; break;
      case MiCelBadgeType.info:
        bg = AppColors.accentLight; fg = AppColors.accent; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

enum MiCelBadgeType { success, warning, danger, info }