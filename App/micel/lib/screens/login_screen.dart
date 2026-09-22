import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';
import 'client_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  void _doLogin() {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    final match = mockUsers.where((u) => u.username == user && u.password == pass);

    if (match.isEmpty) {
      setState(() => _error = 'Usuario o contraseña incorrectos');
      return;
    }

    final found = match.first;

    // Solo se permite acceso a clientes
    if (found.role != UserRole.cliente) {
      setState(() => _error = 'Esta aplicación es solo para clientes.\nAdmin y Técnicos deben usar el sistema web.');
      return;
    }

    if (!found.activo) {
      setState(() => _error = 'Este usuario está inactivo. Contacta a un administrador.');
      return;
    }

    Session.currentUser = found;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ClientShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.7, 0.7),
            radius: 1.2,
            colors: [Color(0x30FF1440), Color(0xFF000000)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: 380,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppColors.gray200),
                boxShadow: AppColors.glowRed,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      boxShadow: AppColors.glowRed,
                    ),
                    alignment: Alignment.center,
                    child: const Text('MC',
                        style: TextStyle(color: Color(0xFF0A0A0C), fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 14),
                  const Text('MiCel', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  const SizedBox(height: 4),
                  const Text('App para Clientes',
                      style: TextStyle(fontSize: 13, color: AppColors.gray500)),
                  const SizedBox(height: 26),
                  TextField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(labelText: 'Usuario', hintText: 'ej: jquispe'),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    onSubmitted: (_) => _doLogin(),
                    decoration: const InputDecoration(labelText: 'Contraseña', hintText: '••••••••'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_error!,
                          textAlign: TextAlign.center, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _doLogin,
                      child: const Text('Ingresar'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Ver usuarios de prueba (solo clientes)',
                        style: TextStyle(fontSize: 12, color: AppColors.gray400)),
                    childrenPadding: EdgeInsets.zero,
                    iconColor: AppColors.gray400,
                    collapsedIconColor: AppColors.gray400,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray200),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          children: mockUsers.map((u) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(u.username,
                                        style: const TextStyle(fontSize: 11, color: AppColors.gray700)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(u.password,
                                        style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      u.activo ? 'Cliente' : 'Cliente (inactivo)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: u.activo ? AppColors.success : AppColors.danger,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}