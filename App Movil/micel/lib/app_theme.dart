import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paleta alineada al panel web MiCel: modo oscuro (por defecto) y modo claro
/// (mismos tonos que public/css/theme-light.css de la web).
///
/// Los colores son getters: cambian al activar el modo claro. Por eso no se
/// pueden usar dentro de expresiones `const`.
class AppColors {
  /// true = modo claro. Se cambia solo con [ModoTema.cambiar].
  static bool claro = false;

  static Color _c(int oscuro, int luz) => Color(claro ? luz : oscuro);

  static Color get primary => _c(0xFFFF1440, 0xFFE11D48);
  static Color get primaryDark => _c(0xFFBE1F1F, 0xFFBE123C);
  static Color get primarySoft => _c(0x33FF1440, 0x1FE11D48);
  static Color get primaryLight => primarySoft;
  static Color get accent => primary;

  static Color get bg => _c(0xFF0A0A0B, 0xFFE8EEF6);
  static Color get surface => _c(0xFF141416, 0xFFF3F6FB);
  static Color get surface2 => _c(0xFF1C1C1F, 0xFFEEF2F8);
  static Color get border => _c(0xFF2A2A2E, 0xFFC5D0E0);

  // gray900 = texto principal ... gray100 = fondos sutiles (en ambos modos)
  static Color get gray900 => _c(0xFFF4F4F5, 0xFF0F1724);
  static Color get gray800 => _c(0xFFE4E4E7, 0xFF1A2332);
  static Color get gray700 => _c(0xFFE4E4E7, 0xFF2C3A4D);
  static Color get gray600 => _c(0xFFD4D4D8, 0xFF334155);
  static Color get gray500 => _c(0xFFD4D4D8, 0xFF475569);
  static Color get gray400 => _c(0xFFA1A1AA, 0xFF64748B);
  static Color get gray200 => _c(0xFF3F3F46, 0xFFD5DEE9);
  static Color get gray100 => _c(0xFF27272A, 0xFFE8EEF6);

  static Color get success => _c(0xFF22C55E, 0xFF16A34A);
  static Color get successLight => _c(0x3322C55E, 0x2216A34A);
  static Color get warning => _c(0xFFF59E0B, 0xFFD97706);
  static Color get warningLight => _c(0x33F59E0B, 0x22D97706);
  static Color get danger => _c(0xFFEF4444, 0xFFDC2626);

  static Color get glowRed => _c(0x55FF1440, 0x33E11D48);
  static Color get glowYellow => _c(0x55F59E0B, 0x33D97706);
}

/// Guarda y aplica el modo claro/oscuro (se recuerda entre aperturas de la app).
class ModoTema {
  static const _clave = 'micel_modo_claro';

  /// Escúchalo para saber cuándo cambió el tema.
  static final ValueNotifier<bool> claro = ValueNotifier<bool>(false);

  /// Llamar en main() antes de runApp.
  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    _aplicar(prefs.getBool(_clave) ?? false);
  }

  static Future<void> cambiar(bool valor) async {
    _aplicar(valor);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_clave, valor);
  }

  static void _aplicar(bool valor) {
    AppColors.claro = valor;
    SystemChrome.setSystemUIOverlayStyle(
      valor ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
    );
    claro.value = valor;
  }
}

class AppTheme {
  static const radius = 12.0;
  static const radiusLg = 18.0;

  static ThemeData get theme {
    final claro = AppColors.claro;
    final base = ThemeData(
      useMaterial3: true,
      brightness: claro ? Brightness.light : Brightness.dark,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: claro
          ? ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.primaryDark,
              surface: AppColors.surface,
              error: AppColors.danger,
              onPrimary: Colors.white,
              onSurface: AppColors.gray900,
            )
          : ColorScheme.dark(
              primary: AppColors.primary,
              secondary: AppColors.primaryDark,
              surface: AppColors.surface,
              error: AppColors.danger,
              onPrimary: Colors.white,
              onSurface: AppColors.gray900,
            ),
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: claro ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AppColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.gray800),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: BorderSide(color: AppColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface2,
        hintStyle: TextStyle(color: AppColors.gray400, fontSize: 14),
        labelStyle: TextStyle(color: AppColors.gray400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(color: AppColors.primary, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          borderSide: BorderSide(color: AppColors.danger),
        ),
        prefixIconColor: AppColors.gray400,
        suffixIconColor: AppColors.gray400,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray800,
          side: BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface2,
        contentTextStyle: TextStyle(color: AppColors.gray900),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
