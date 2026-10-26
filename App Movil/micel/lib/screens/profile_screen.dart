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
    final initials = ClientSession.nombre.isNotEmpty
        ? ClientSession.nombre
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
            .join()
        : 'C';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('Mi perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.gray900)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2.5),
                      gradient: const LinearGradient(
                        colors: [Color(0x33FF1440), Color(0x15FF1440)],
                      ),
                    ),
                    child: Text(initials,
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary)),
                  ),
                  const SizedBox(height: 14),
                  Text(ClientSession.nombre,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                  if (ClientSession.esVip) ...[
                    const SizedBox(height: 6),
                    const Text('⭐ Cliente VIP',
                        style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 16),
                  _infoRow(Icons.qr_code_rounded, 'Código', ClientSession.code),
                  _infoRow(Icons.phone_rounded, 'Teléfono', ClientSession.phone),
                  _infoRow(Icons.monetization_on_rounded, 'Coins',
                      '${ClientSession.coins} (≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(0)})'),
                  _infoRow(Icons.confirmation_number_outlined, 'Visitas', '${ClientSession.visits}'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
                label: const Text('Cerrar sesión',
                    style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gray400),
          const SizedBox(width: 10),
          SizedBox(
              width: 80,
              child: Text(k, style: const TextStyle(color: AppColors.gray400, fontSize: 13))),
          Expanded(
              child: Text(v.isEmpty ? '—' : v,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900))),
        ],
      ),
    );
  }
}
