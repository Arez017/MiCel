import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// En **web**: datos en memoria + SharedPreferences (sin worker SQLite).
/// En **móvil**: SQLite real (sqflite).
class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();

  Database? _db;
  // Web store
  final List<Map<String, dynamic>> _usuarios = [];
  final List<Map<String, dynamic>> _celulares = [];
  final List<Map<String, dynamic>> _ordenes = [];
  int _uid = 1;
  bool _ready = false;

  static String hash(String plain) =>
      sha256.convert(utf8.encode(plain)).toString();

  Future<void> init() async {
    if (_ready) return;
    if (kIsWeb) {
      await _initWeb();
    } else {
      await _initNative();
    }
    _ready = true;
  }

  // ---------- WEB ----------
  Future<void> _initWeb() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString('micel_demo_db');
    if (raw != null) {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _usuarios
        ..clear()
        ..addAll((data['usuarios'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      _celulares
        ..clear()
        ..addAll((data['celulares'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      _ordenes
        ..clear()
        ..addAll((data['ordenes'] as List).map((e) => Map<String, dynamic>.from(e as Map)));
      _uid = (data['uid'] as int?) ?? 10;
      return;
    }
    _seedWeb();
    await _persistWeb();
  }

  void _seedWeb() {
    final h = hash('1234');
    _usuarios.addAll([
      {
        'id': 1,
        'username': 'egor4206',
        'password_hash': h,
        'name': 'Egor Kamado',
        'phone': '61154206',
        'coins': 175,
        'visits': 4,
        'es_vip': 1,
      },
      {
        'id': 2,
        'username': 'demo',
        'password_hash': h,
        'name': 'Cliente Demo',
        'phone': '70000000',
        'coins': 50,
        'visits': 2,
        'es_vip': 0,
      },
    ]);
    _uid = 3;
    final phones = [
      ['Samsung', 'Galaxy A32', 850, 'Excelente', '128 GB', 'Negro', 'Equipo revisado, batería 92%'],
      ['Xiaomi', 'Redmi Note 10', 950, 'Como nuevo', '128 GB', 'Azul', 'Garantía taller 30 días'],
      ['Tecno', 'Spark 10 Pro', 700, 'Bueno', '64 GB', 'Celeste', 'Pantalla original'],
      ['Apple', 'iPhone 11', 1800, 'Excelente', '64 GB', 'Blanco', 'Batería cambiada en MiCel'],
      ['Motorola', 'G54', 1100, 'Nuevo', '256 GB', 'Verde', 'Sellado de vitrina'],
      ['Samsung', 'A14', 780, 'Bueno', '64 GB', 'Negro', 'Listo para entregar'],
    ];
    for (var i = 0; i < phones.length; i++) {
      final p = phones[i];
      _celulares.add({
        'id': i + 1,
        'marca': p[0],
        'modelo': p[1],
        'precio': p[2],
        'estado': p[3],
        'almacenamiento': p[4],
        'color': p[5],
        'descripcion': p[6],
      });
    }
    _ordenes.addAll([
      {
        'id': 1,
        'code': 'OS-0021',
        'cliente_username': 'egor4206',
        'device': 'Samsung A32',
        'service': 'Cambio de pantalla',
        'status': 'Listo',
        'monto': 250,
      },
      {
        'id': 2,
        'code': 'OS-0019',
        'cliente_username': 'egor4206',
        'device': 'Tecno Spark 10',
        'service': 'Cambio de batería',
        'status': 'En proceso',
        'monto': 120,
      },
      {
        'id': 3,
        'code': 'OS-0015',
        'cliente_username': 'demo',
        'device': 'Redmi Note 10',
        'service': 'Pin de carga',
        'status': 'Listo',
        'monto': 80,
      },
    ]);
  }

  Future<void> _persistWeb() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(
      'micel_demo_db',
      jsonEncode({
        'usuarios': _usuarios,
        'celulares': _celulares,
        'ordenes': _ordenes,
        'uid': _uid,
      }),
    );
  }

  // ---------- NATIVE SQLITE ----------
  Future<void> _initNative() async {
    final path = join(await getDatabasesPath(), 'micel_demo.db');
    _db = await openDatabase(path, version: 1, onCreate: _onCreateNative);
  }

  Future<void> _onCreateNative(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT,
        coins INTEGER DEFAULT 0,
        visits INTEGER DEFAULT 1,
        es_vip INTEGER DEFAULT 0
      )
    ''');
    await db.execute('''
      CREATE TABLE celulares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        marca TEXT NOT NULL,
        modelo TEXT NOT NULL,
        precio REAL NOT NULL,
        estado TEXT NOT NULL,
        almacenamiento TEXT,
        color TEXT,
        descripcion TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE ordenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL,
        cliente_username TEXT,
        device TEXT,
        service TEXT,
        status TEXT,
        monto REAL DEFAULT 0
      )
    ''');

    final h = hash('1234');
    await db.insert('usuarios', {
      'username': 'egor4206',
      'password_hash': h,
      'name': 'Egor Kamado',
      'phone': '61154206',
      'coins': 175,
      'visits': 4,
      'es_vip': 1,
    });
    await db.insert('usuarios', {
      'username': 'demo',
      'password_hash': h,
      'name': 'Cliente Demo',
      'phone': '70000000',
      'coins': 50,
      'visits': 2,
      'es_vip': 0,
    });

    final phones = [
      ['Samsung', 'Galaxy A32', 850, 'Excelente', '128 GB', 'Negro', 'Equipo revisado, batería 92%'],
      ['Xiaomi', 'Redmi Note 10', 950, 'Como nuevo', '128 GB', 'Azul', 'Garantía taller 30 días'],
      ['Tecno', 'Spark 10 Pro', 700, 'Bueno', '64 GB', 'Celeste', 'Pantalla original'],
      ['Apple', 'iPhone 11', 1800, 'Excelente', '64 GB', 'Blanco', 'Batería cambiada en MiCel'],
      ['Motorola', 'G54', 1100, 'Nuevo', '256 GB', 'Verde', 'Sellado de vitrina'],
      ['Samsung', 'A14', 780, 'Bueno', '64 GB', 'Negro', 'Listo para entregar'],
    ];
    for (final p in phones) {
      await db.insert('celulares', {
        'marca': p[0],
        'modelo': p[1],
        'precio': p[2],
        'estado': p[3],
        'almacenamiento': p[4],
        'color': p[5],
        'descripcion': p[6],
      });
    }
    await db.insert('ordenes', {
      'code': 'OS-0021',
      'cliente_username': 'egor4206',
      'device': 'Samsung A32',
      'service': 'Cambio de pantalla',
      'status': 'Listo',
      'monto': 250,
    });
    await db.insert('ordenes', {
      'code': 'OS-0019',
      'cliente_username': 'egor4206',
      'device': 'Tecno Spark 10',
      'service': 'Cambio de batería',
      'status': 'En proceso',
      'monto': 120,
    });
    await db.insert('ordenes', {
      'code': 'OS-0015',
      'cliente_username': 'demo',
      'device': 'Redmi Note 10',
      'service': 'Pin de carga',
      'status': 'Listo',
      'monto': 80,
    });
  }

  // ---------- API pública ----------
  Future<Map<String, dynamic>?> login(String username, String password) async {
    await init();
    final h = hash(password);
    if (kIsWeb) {
      try {
        return Map<String, dynamic>.from(
          _usuarios.firstWhere(
            (u) => u['username'] == username.trim() && u['password_hash'] == h,
          ),
        );
      } catch (_) {
        return null;
      }
    }
    final rows = await _db!.query(
      'usuarios',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username.trim(), h],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    await init();
    if (kIsWeb) {
      try {
        return Map<String, dynamic>.from(
          _usuarios.firstWhere((u) => u['username'] == username),
        );
      } catch (_) {
        return null;
      }
    }
    final rows = await _db!.query('usuarios', where: 'username = ?', whereArgs: [username], limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  Future<String?> recuperarPassword({
    required String username,
    required String phone,
    required String newPassword,
  }) async {
    await init();
    final u = await getUser(username.trim());
    if (u == null) return 'Usuario no encontrado';
    final pDb = (u['phone'] ?? '').toString().replaceAll(RegExp(r'\D'), '');
    final pIn = phone.replaceAll(RegExp(r'\D'), '');
    if (pDb.isEmpty || pIn.isEmpty || !(pDb == pIn || pDb.endsWith(pIn) || pIn.endsWith(pDb))) {
      return 'El teléfono no coincide';
    }
    final h = hash(newPassword);
    if (kIsWeb) {
      final i = _usuarios.indexWhere((e) => e['username'] == username.trim());
      if (i >= 0) {
        _usuarios[i]['password_hash'] = h;
        await _persistWeb();
      }
      return null;
    }
    await _db!.update('usuarios', {'password_hash': h}, where: 'id = ?', whereArgs: [u['id']]);
    return null;
  }

  Future<String?> changePassword({
    required String username,
    required String actual,
    required String nueva,
  }) async {
    final ok = await login(username, actual);
    if (ok == null) return 'Contraseña actual incorrecta';
    return recuperarPassword(username: username, phone: ok['phone']?.toString() ?? '', newPassword: nueva);
  }

  Future<void> updateProfile(String username, {String? name, String? phone}) async {
    await init();
    if (kIsWeb) {
      final i = _usuarios.indexWhere((e) => e['username'] == username);
      if (i >= 0) {
        if (name != null) _usuarios[i]['name'] = name;
        if (phone != null) _usuarios[i]['phone'] = phone;
        await _persistWeb();
      }
      return;
    }
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (data.isEmpty) return;
    await _db!.update('usuarios', data, where: 'username = ?', whereArgs: [username]);
  }

  Future<List<Map<String, dynamic>>> celulares() async {
    await init();
    if (kIsWeb) return List.from(_celulares);
    return _db!.query('celulares', orderBy: 'precio ASC');
  }

  Future<List<Map<String, dynamic>>> ordenesDe(String username) async {
    await init();
    if (kIsWeb) {
      return _ordenes.where((o) => o['cliente_username'] == username).toList();
    }
    return _db!.query('ordenes', where: 'cliente_username = ?', whereArgs: [username], orderBy: 'id DESC');
  }
}
