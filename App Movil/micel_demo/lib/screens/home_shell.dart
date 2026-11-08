import 'package:flutter/material.dart';
import '../theme.dart';
import 'catalog_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _i = 0;
  final _pages = const [CatalogScreen(), OrdersScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _i, children: _pages),
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.phone_android_rounded), label: 'Celulares'),
          NavigationDestination(icon: Icon(Icons.handyman_rounded), label: 'Órdenes'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}
