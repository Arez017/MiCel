import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'session.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, [this.status]);
  @override
  String toString() => message;
}

class ApiService {
  static Map<String, String> _headers({bool auth = false}) {
    final h = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth && ClientSession.token != null) {
      h['Authorization'] = 'Bearer ${ClientSession.token}';
    }
    return h;
  }

  static Future<dynamic> _handle(http.Response res) async {
    dynamic data;
    try {
      data = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      data = res.body;
    }
    if (res.statusCode == 401) {
      await ClientSession.clear();
      throw ApiException('Sesión expirada. Vuelve a iniciar sesión.', 401);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String msg = 'Error ${res.statusCode}';
      if (data is Map) {
        msg = (data['message'] ?? data['error'] ?? msg).toString();
        if (data['errors'] is Map) {
          final errs = (data['errors'] as Map).values.expand((e) => e is List ? e : [e]);
          msg = errs.join('\n');
        }
      }
      throw ApiException(msg, res.statusCode);
    }
    return data;
  }

  /// Login cliente (cuenta creada por el staff en el panel web)
  static Future<Map<String, dynamic>> loginCliente(String username, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cliente/login'),
      headers: _headers(),
      body: jsonEncode({'username': username, 'password': password}),
    );
    final data = await _handle(res) as Map<String, dynamic>;
    final token = data['token']?.toString() ?? '';
    final cliente = Map<String, dynamic>.from(data['cliente'] as Map? ?? {});
    await ClientSession.save(token, cliente);
    return data;
  }

  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/cliente/logout'),
        headers: _headers(auth: true),
      );
    } catch (_) {}
    await ClientSession.clear();
  }

  static Future<Map<String, dynamic>> me() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cliente/me'),
      headers: _headers(auth: true),
    );
    final data = await _handle(res) as Map<String, dynamic>;
    await ClientSession.save(ClientSession.token!, data);
    return data;
  }

  static Future<List<dynamic>> misOrdenes() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cliente/mis-ordenes'),
      headers: _headers(auth: true),
    );
    final data = await _handle(res);
    return data is List ? data : [];
  }

  static Future<List<dynamic>> cupones() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/cliente/cupones'),
      headers: _headers(auth: true),
    );
    final data = await _handle(res);
    return data is List ? data : [];
  }

  /// Seguimiento público por código de orden (sin login)
  static Future<Map<String, dynamic>> seguimiento(String codigo) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/seguimiento/${Uri.encodeComponent(codigo.trim())}'),
      headers: _headers(),
    );
    final data = await _handle(res);
    return Map<String, dynamic>.from(data as Map);
  }
}
