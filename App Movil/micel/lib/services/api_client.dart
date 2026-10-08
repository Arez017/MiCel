import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Excepción con el mensaje real que mandó Laravel (validación, 403, etc.)
/// en vez de un error genérico de "algo salió mal".
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Cliente HTTP único para toda la app. Centraliza la URL base, el header
/// de autenticación y el manejo de errores para no repetir este código
/// en cada pantalla.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  // ⚠️ IMPORTANTE — AJUSTA ESTO SEGÚN DÓNDE CORRAS EL BACKEND:
  //  - Emulador Android:        http://10.0.2.2:8000/api
  //  - Emulador iOS / Simulator: http://localhost:8000/api
  //  - Celular físico (misma red Wi-Fi que tu PC): http://192.168.X.X:8000/api
  //  - Servidor real ya desplegado: https://tu-dominio.com/api
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'micel_cliente_token';

  String? _token;

  Future<String?> get token async {
    _token ??= await _storage.read(key: _tokenKey);
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (auth) {
      final t = await token;
      if (t != null) headers['Authorization'] = 'Bearer $t';
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: await _headers(auth: auth));
    return _handle(res);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final res = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(res);
  }

  dynamic _handle(http.Response res) {
    final isJson = res.headers['content-type']?.contains('application/json') ?? false;
    final decoded = isJson && res.body.isNotEmpty ? jsonDecode(res.body) : null;

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decoded;
    }

    // Laravel manda los errores de validación como {"errors": {"campo": ["mensaje"]}}
    // y los abort(403)/mensajes simples como {"message": "..."}.
    String mensaje = 'Error de conexión (${res.statusCode}).';
    if (decoded is Map) {
      if (decoded['errors'] is Map && (decoded['errors'] as Map).isNotEmpty) {
        final primerError = (decoded['errors'] as Map).values.first;
        mensaje = primerError is List ? primerError.first.toString() : primerError.toString();
      } else if (decoded['message'] != null) {
        mensaje = decoded['message'].toString();
      }
    }
    throw ApiException(mensaje, statusCode: res.statusCode);
  }
}
