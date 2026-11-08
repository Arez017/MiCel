import 'package:flutter/material.dart';
import 'db/database_helper.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.init();
  runApp(const MicelDemoApp());
}

class MicelDemoApp extends StatelessWidget {
  const MicelDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MiCel Demo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}
