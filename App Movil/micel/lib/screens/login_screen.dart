import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_config.dart';
import '../services/api_service.dart';
import 'client_shell.dart';
import 'recover_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Ingresa usuario y contraseña');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.loginCliente(user, pass);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClientShell()),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error =
          'No se pudo conectar.\nServidor: ${ApiConfig.baseUrl}\n'
          'Toca "Cambiar servidor / IP" para ajustar la URL.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _abrirConfigServidor() async {
    final ctrl = TextEditingController(text: ApiConfig.baseUrl);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Servidor API',
          style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pon la IP de tu laptop en esta red.\n'
                'Ej: http://192.168.43.15:8000/api\n\n'
                'No hace falta generar otro APK: se guarda en el celular.',
                style: TextStyle(fontSize: 13, color: AppColors.gray400, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: ctrl,
                style: const TextStyle(color: AppColors.gray900, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'URL base',
                  hintText: 'http://192.168.x.x:8000/api',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await ApiConfig.setBaseUrl(ctrl.text);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('API: ${ApiConfig.baseUrl}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2A0A12), Color(0xFF0D0D0F)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'MC',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'MiCel Cliente',
                        style: TextStyle(
                          color: AppColors.gray900,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Seguimiento de tu equipo y beneficios',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gray400, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ApiConfig.baseUrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.gray400,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 22),
                      TextField(
                        controller: _userCtrl,
                        textInputAction: TextInputAction.next,
                        style: const TextStyle(color: AppColors.gray900),
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        onSubmitted: (_) => _doLogin(),
                        style: const TextStyle(color: AppColors.gray900),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                      ),
                      // ★ Restablecer contraseña
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const RecoverPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFF8A8A),
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _doLogin,
                          child: _loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Ingresar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _abrirConfigServidor,
                        icon: const Icon(
                          Icons.settings_ethernet_rounded,
                          size: 16,
                          color: AppColors.gray400,
                        ),
                        label: const Text(
                          'Cambiar servidor / IP',
                          style: TextStyle(fontSize: 12, color: AppColors.gray400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
