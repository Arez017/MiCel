import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';

class RecoverPasswordScreen extends StatefulWidget {
  const RecoverPasswordScreen({super.key});

  @override
  State<RecoverPasswordScreen> createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _userCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  String? _ok;

  @override
  void dispose() {
    _userCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = _userCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass = _passCtrl.text;
    final pass2 = _pass2Ctrl.text;
    if (user.isEmpty || phone.isEmpty || pass.isEmpty) {
      setState(() {
        _error = 'Completa usuario, teléfono y nueva contraseña';
        _ok = null;
      });
      return;
    }
    if (pass.length < 4) {
      setState(() {
        _error = 'La contraseña debe tener al menos 4 caracteres';
        _ok = null;
      });
      return;
    }
    if (pass != pass2) {
      setState(() {
        _error = 'Las contraseñas no coinciden';
        _ok = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _ok = null;
    });
    try {
      await ApiService.recuperarPassword(
        username: user,
        phone: phone,
        password: pass,
        passwordConfirmation: pass2,
      );
      if (!mounted) return;
      setState(() {
        _ok = 'Listo. Ya puedes iniciar sesión con la nueva contraseña.';
        _passCtrl.clear();
        _pass2Ctrl.clear();
      });
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'No se pudo conectar con el servidor');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Restablecer contraseña',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Ingresa el usuario de la app y el teléfono registrado en el taller. '
            'Si coinciden, podrás definir una nueva contraseña.',
            style: TextStyle(color: AppColors.gray400, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _userCtrl,
            decoration: const InputDecoration(
              labelText: 'Usuario (login)',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Teléfono registrado',
              hintText: 'Ej: 71234567',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: 'Nueva contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pass2Ctrl,
            obscureText: _obscure,
            decoration: const InputDecoration(
              labelText: 'Repetir contraseña',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3F1219),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_error!, style: const TextStyle(color: Color(0xFFFECACA), fontSize: 13)),
            ),
          ],
          if (_ok != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF14301F),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(_ok!, style: const TextStyle(color: Color(0xFFBBF7D0), fontSize: 13)),
            ),
          ],
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Guardar nueva contraseña',
                      style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver al login'),
          ),
        ],
      ),
    );
  }
}
