import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../services/session.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'recover_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController(text: 'demo');
  final _pass = TextEditingController(text: '1234');
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final u = await DatabaseHelper.instance.login(_user.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (u == null) {
      setState(() => _error = 'Usuario o contraseña incorrectos.');
      return;
    }
    await Session.save(u);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0A12), AppColors.bg],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('MC',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                    const SizedBox(height: 14),
                    const Text('MiCel Demo',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text)),
                    const SizedBox(height: 4),
                    const Text('Demo local · SQLite · sin internet',
                        style: TextStyle(color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 8),
                    const Text('Clientes demo: demo · egor4206\nClave: 1234',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.warn, fontSize: 11, height: 1.35)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _user,
                      decoration: const InputDecoration(
                        labelText: 'Usuario',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pass,
                      obscureText: _obscure,
                      onSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RecoverScreen()));
                        },
                        child: const Text('¿Olvidaste tu contraseña?',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Ingresar'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
