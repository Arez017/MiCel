import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Mi perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ClientSession.nombre,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text('Código: ${ClientSession.code}', style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
                  Text('Tel: ${ClientSession.phone}', style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
                  if (ClientSession.esVip)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('⭐ Cliente VIP', style: TextStyle(color: Color(0xFFF59E0B))),
                    ),
                  const SizedBox(height: 8),
                  Text('Coins: ${ClientSession.coins} (≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(0)})',
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
