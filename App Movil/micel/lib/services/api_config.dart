import 'package:shared_preferences/shared_preferences.dart';

/// URL de la API configurable (se guarda en el celular).
/// No hace falta recompilar el APK para cambiar de red / IP.
class ApiConfig {
  static const String _prefsKey = 'micel_api_base_url';

  /// Valor por defecto (PC con Herd / demo).
  static const String defaultUrl = 'http://micel.test/api';

  static String _baseUrl = defaultUrl;

  static String get baseUrl => _baseUrl;

  /// Cargar URL guardada al arrancar la app.
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && saved.trim().isNotEmpty) {
      _baseUrl = _normalize(saved);
    }
  }

  /// Guardar nueva URL (ej. http://192.168.43.15:8000/api).
  static Future<void> setBaseUrl(String url) async {
    final n = _normalize(url);
    _baseUrl = n;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, n);
  }

  static String _normalize(String url) {
    var u = url.trim();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    // Si el usuario pone solo la IP o el host sin /api
    if (!u.endsWith('/api') && !u.contains('/api/')) {
      u = '$u/api';
    }
    if (!u.startsWith('http://') && !u.startsWith('https://')) {
      u = 'http://$u';
    }
    return u;
  }

  /// Sugerencias rápidas según el entorno.
  static List<String> get sugerencias => [
        'http://micel.test/api',
        'http://10.0.2.2/api',
        'http://127.0.0.1:8000/api',
        'http://192.168.1.1:8000/api',
      ];
}
