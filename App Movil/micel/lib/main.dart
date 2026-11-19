import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'services/api_config.dart';
import 'services/session.dart';
import 'screens/login_screen.dart';
import 'screens/client_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.init();
  await ModoTema.cargar();
  final restored = await ClientSession.restore();
  runApp(MiCelApp(startLoggedIn: restored));
}

class MiCelApp extends StatefulWidget {
  final bool startLoggedIn;
  const MiCelApp({super.key, this.startLoggedIn = false});

  @override
  State<MiCelApp> createState() => _MiCelAppState();
}

class _MiCelAppState extends State<MiCelApp> {
  @override
  void initState() {
    super.initState();
    ModoTema.claro.addListener(_temaCambiado);
  }

  @override
  void dispose() {
    ModoTema.claro.removeListener(_temaCambiado);
    super.dispose();
  }

  /// Los colores de AppColors se leen al construir cada pantalla: al cambiar de
  /// modo se reconstruye todo el árbol (sin perder la navegación ni los datos).
  void _temaCambiado() {
    setState(() {});
    void reconstruir(Element e) {
      e.markNeedsBuild();
      e.visitChildren(reconstruir);
    }

    (context as Element).visitChildren(reconstruir);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiCel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: widget.startLoggedIn ? const ClientShell() : const LoginScreen(),
    );
  }
}
