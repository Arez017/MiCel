import 'package:flutter/material.dart';
import 'mock_data.dart';
import '../app_theme.dart';
import 'login_screen.dart';
import 'mis_ordenes_screen.dart';
import 'mi_comision_screen.dart';

class TecnicoShell extends StatefulWidget {
  const TecnicoShell({super.key});

  @override
  State<TecnicoShell> createState() => _TecnicoShellState();
}

class _TecnicoShellState extends State<TecnicoShell> {
  int _index = 0;

  final _screens = const [
    MisOrdenesScreen(),
    MiComisionScreen(),
  ];

  static const _titles = ['Mis Órdenes', 'Mi Comisión'];

  void _logout() {
    Session.currentUser = null;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Session.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Row(
              children: [
                Text(user?.nombre ?? 'Técnico', style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                IconButton(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Mis Órdenes'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Mi Comisión'),
        ],
      ),
    );
  }
}