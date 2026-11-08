// Ejemplo de llamada desde Flutter al modelo PROPIO (puerto 8001)
// No confundir con /api/cliente/chat del Laravel MiCEL.

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> chatConRedNeuronal(String message) async {
  // Emulador Android → 10.0.2.2 | celular real → IP de tu PC
  const base = 'http://10.0.2.2:8001';
  final res = await http.post(
    Uri.parse('$base/chat'),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    body: jsonEncode({'message': message}),
  );
  if (res.statusCode >= 200 && res.statusCode < 300) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
  throw Exception('Error ${res.statusCode}: ${res.body}');
}
