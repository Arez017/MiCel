import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'coins_screen.dart';
import 'tracking_screen.dart';
import 'profile_screen.dart';

/// Datos del cliente VIP (mock, luego los conectas a tu backend)
class ClientData {
  static const nombre = 'Juan Quispe';
  static const esVip = true;
  static const clienteDesde = 'Marzo 2024';
  static const coins = 680;
  static const bsPorDescuento = 34.0; // equivalente en Bs de descuento
}

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on_rounded), label: 'MiCel Coins'),
          BottomNavigationBarItem(icon: Icon(Icons.phone_iphone_rounded), label: 'Seguimiento'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
        ],
      ),
    );
  }
}