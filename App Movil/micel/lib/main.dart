import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'services/session.dart';
import 'screens/login_screen.dart';
import 'screens/client_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final restored = await ClientSession.restore();
  runApp(MiCelApp(startLoggedIn: restored));
}

class MiCelApp extends StatelessWidget {
  final bool startLoggedIn;
  const MiCelApp({super.key, this.startLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiCel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: startLoggedIn ? const ClientShell() : const LoginScreen(),
    );
  }
}
