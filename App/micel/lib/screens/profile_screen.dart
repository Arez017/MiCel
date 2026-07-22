import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'client_shell.dart';
import 'mock_data.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryLight,
                    border: Border.all(color: AppColors.primary, width: 2.5),
                    boxShadow: AppColors.glowRed,
                  ),
                  alignment: Alignment.center,
                  child: const Text('JQ',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
                const SizedBox(height: 12),
                const Text(ClientData.nombre, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('CLIENTE VIP',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0A0A0C), letterSpacing: .4)),
                ),
                const SizedBox(height: 4),
                const Text('Cliente desde ${ClientData.clienteDesde}', style: TextStyle(fontSize: 11.5, color: AppColors.gray400)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Card(
            child: Column(
              children: const [
                _ProfileTile(icon: Icons.phone_rounded, label: 'Teléfono', value: '+591 700 12345'),
                Divider(height: 1),
                _ProfileTile(icon: Icons.email_rounded, label: 'Correo', value: 'juan.quispe@email.com'),
                Divider(height: 1),
                _ProfileTile(icon: Icons.location_on_rounded, label: 'Dirección', value: 'Zona Sopocachi, La Paz'),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Card(
            child: Column(
              children: [
                _MenuTile(icon: Icons.credit_card_rounded, text: 'Métodos de pago', onTap: () {}),
                const Divider(height: 1),
                _MenuTile(icon: Icons.notifications_rounded, text: 'Notificaciones', onTap: () {}),
                const Divider(height: 1),
                _MenuTile(icon: Icons.headset_mic_rounded, text: 'Ayuda y soporte', onTap: () {}),
                const Divider(height: 1),
                _MenuTile(icon: Icons.description_rounded, text: 'Términos y condiciones', onTap: () {}),
              ],
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Session.currentUser = null;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
              label: const Text('Cerrar sesión', style: TextStyle(color: AppColors.danger)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gray400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, color: AppColors.gray800, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray800))),
            const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}