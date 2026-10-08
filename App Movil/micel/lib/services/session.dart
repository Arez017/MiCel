import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Sesión del cliente (token Sanctum + datos).
class ClientSession {
  static String? token;
  static Map<String, dynamic>? cliente;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static String get nombre => (cliente?['name'] ?? 'Cliente').toString();
  static String get phone => (cliente?['phone'] ?? '').toString();
  static String get code => (cliente?['code'] ?? '').toString();
  static int get coins => (cliente?['coins'] is int)
      ? cliente!['coins'] as int
      : int.tryParse('${cliente?['coins'] ?? 0}') ?? 0;
  static double get coinsValorBs =>
      double.tryParse('${cliente?['coins_valor_bs'] ?? 0}') ?? 0;
  static bool get esVip => cliente?['es_vip'] == true;
  static int get visits => (cliente?['visits'] is int)
      ? cliente!['visits'] as int
      : int.tryParse('${cliente?['visits'] ?? 0}') ?? 0;

  static Future<void> save(String t, Map<String, dynamic> c) async {
    token = t;
    cliente = c;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('micel_cliente_token', t);
    await prefs.setString('micel_cliente_data', jsonEncode(c));
  }

  static Future<bool> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('micel_cliente_token');
    final raw = prefs.getString('micel_cliente_data');
    if (t == null || t.isEmpty || raw == null) return false;
    try {
      token = t;
      cliente = jsonDecode(raw) as Map<String, dynamic>;
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clear() async {
    token = null;
    cliente = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('micel_cliente_token');
    await prefs.remove('micel_cliente_data');
  }
}
