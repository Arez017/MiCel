import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({super.key});

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final _user = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  String? _msg;
  bool _ok = false;
  bool _loading = false;

  Future<void> _save() async {
    if (_pass.text != _pass2.text) {
      setState(() {
        _ok = false;
        _msg = 'Las contraseñas no coinciden';
      });
      return;
    }
    if (_pass.text.length < 4) {
      setState(() {
        _ok = false;
        _msg = 'Mínimo 4 caracteres';
      });
      return;
    }
    setState(() => _loading = true);
    final err = await DatabaseHelper.instance.recuperarPassword(
      username: _user.text.trim(),
      phone: _phone.text.trim(),
      newPassword: _pass.text,
    );
    setState(() {
      _loading = false;
      if (err == null) {
        _ok = true;
        _msg = 'Listo. Ya puedes iniciar sesión con la nueva clave.';
      } else {
        _ok = false;
        _msg = err;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer contraseña')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Demo local: valida usuario + teléfono guardados en SQLite.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(controller: _user, decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 12),
          TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 12),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Nueva contraseña', prefixIcon: Icon(Icons.lock_outline))),
          const SizedBox(height: 12),
          TextField(controller: _pass2, obscureText: true, decoration: const InputDecoration(labelText: 'Repetir contraseña', prefixIcon: Icon(Icons.lock_outline))),
          if (_msg != null) ...[
            const SizedBox(height: 14),
            Text(_msg!, style: TextStyle(color: _ok ? AppColors.success : const Color(0xFFFF8A8A))),
          ],
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loading ? null : _save, child: const Text('Guardar nueva contraseña')),
        ],
      ),
    );
  }
}
