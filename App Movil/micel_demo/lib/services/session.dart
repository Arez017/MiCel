import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';

class Session {
  static Map<String, dynamic>? user;

  static Future<void> save(Map<String, dynamic> u) async {
    user = Map<String, dynamic>.from(u);
    final p = await SharedPreferences.getInstance();
    await p.setString('username', u['username'] as String);
  }

  static Future<bool> restore() async {
    final p = await SharedPreferences.getInstance();
    final username = p.getString('username');
    if (username == null) return false;
    final u = await DatabaseHelper.instance.getUser(username);
    if (u == null) return false;
    user = Map<String, dynamic>.from(u);
    return true;
  }

  static Future<void> clear() async {
    user = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('username');
  }

  static String get username => user?['username']?.toString() ?? '';
  static String get name => user?['name']?.toString() ?? '';
}
