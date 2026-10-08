import 'api_client.dart';

/// Datos reales del cliente logueado (reemplaza al AppUser de mock_data.dart
/// para todo lo que tenga que ver con la sesión).
class ClienteSesion {
  final int id;
  final String code;
  final String name;
  final String phone;
  final String username;
  final String? sucursal;
  final int visits;
  final int coins;
  final double coinsValorBs;
  final double totalGastado;
  final bool esVip;

  ClienteSesion({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.username,
    required this.sucursal,
    required this.visits,
    required this.coins,
    required this.coinsValorBs,
    required this.totalGastado,
    required this.esVip,
  });

  factory ClienteSesion.fromJson(Map<String, dynamic> json) {
    return ClienteSesion(
      id: json['id'],
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      username: json['username'] ?? '',
      sucursal: json['sucursal'],
      visits: json['visits'] ?? 0,
      coins: json['coins'] ?? 0,
      coinsValorBs: double.tryParse('${json['coins_valor_bs']}') ?? 0,
      totalGastado: double.tryParse('${json['total_gastado']}') ?? 0,
      esVip: json['es_vip'] ?? false,
    );
  }

  /// Iniciales para el avatar circular (ej. "Juan Quispe" -> "JQ")
  String get iniciales {
    final partes = name.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    final primera = partes.first[0];
    final segunda = partes.length > 1 ? partes[1][0] : '';
    return (primera + segunda).toUpperCase();
  }
}

class ClienteAuthService {
  ClienteAuthService._();
  static final ClienteAuthService instance = ClienteAuthService._();

  ClienteSesion? _actual;
  ClienteSesion? get actual => _actual;

  Future<ClienteSesion?> intentarSesionGuardada() async {
    final token = await ApiClient.instance.token;
    if (token == null) return null;

    try {
      final data = await ApiClient.instance.get('/cliente/me');
      _actual = ClienteSesion.fromJson(data as Map<String, dynamic>);
      return _actual;
    } on ApiException {
      await ApiClient.instance.clearToken();
      return null;
    }
  }

  Future<ClienteSesion> login(String username, String password) async {
    final data = await ApiClient.instance.post(
      '/cliente/login',
      {'username': username, 'password': password},
      auth: false,
    );

    await ApiClient.instance.setToken(data['token']);
    _actual = ClienteSesion.fromJson(data['cliente'] as Map<String, dynamic>);
    return _actual!;
  }

  /// Vuelve a pedir /cliente/me (ej. para refrescar coins después de visitar
  /// la sucursal). Usa esto en un pull-to-refresh del home.
  Future<ClienteSesion?> refrescar() async {
    try {
      final data = await ApiClient.instance.get('/cliente/me');
      _actual = ClienteSesion.fromJson(data as Map<String, dynamic>);
      return _actual;
    } on ApiException {
      return _actual;
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/cliente/logout', {});
    } on ApiException {
      // token ya vencido del lado del servidor — no importa, igual limpiamos local
    }
    await ApiClient.instance.clearToken();
    _actual = null;
  }
}
