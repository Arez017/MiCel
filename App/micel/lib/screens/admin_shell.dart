import 'package:flutter/material.dart';
import 'mock_data.dart';
import '../app_theme.dart';
import 'login_screen.dart';
import 'admin_dashboard_screen.dart';
import 'stock_screen.dart';
import 'commission_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  final _screens = const [
    AdminDashboardScreen(),
    StockScreen(),
    CommissionScreen(),
  ];

  static const _titles = ['Dashboard', 'Control de Stock', 'Comisiones de Técnicos'];

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
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Row(
                children: [
                  Text(user?.nombre ?? 'Admin',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                  IconButton(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout_rounded, size: 20, color: AppColors.danger),
                    tooltip: 'Cerrar sesión',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_rounded), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.payments_rounded), label: 'Comisiones'),
        ],
      ),
    );
  }
}