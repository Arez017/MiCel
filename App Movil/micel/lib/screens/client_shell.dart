import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'home_screen.dart';
import 'coins_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    CoinsScreen(),
    TrackingScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
          color: AppColors.surface,
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: AppColors.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.gray400,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on_rounded),
              label: 'Coins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner_rounded),
              label: 'Seguimiento',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
