import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'client_shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          // ---- Encabezado ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hola, Juan 👋',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        _VipChip(),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight,
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text('JQ',
                    style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ---- Accesos rápidos: coins + seguimiento ----
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.monetization_on_rounded,
                  iconColor: AppColors.accent,
                  title: 'MiCel Coins',
                  value: '${ClientData.coins} MC',
                  subtitle: 'Bs ${ClientData.bsPorDescuento.toStringAsFixed(0)} en descuento',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.build_rounded,
                  iconColor: AppColors.warning,
                  title: 'Tu equipo',
                  value: 'En reparación',
                  subtitle: 'iPhone 13 Pro · ORD-2291',
                  badge: const MiCelBadge(text: 'En proceso', type: MiCelBadgeType.warning),
                ),
              ),
            ],
          ),

          const SizedBox(height: 26),

          const Text('Tus cupones y descuentos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),

          const _CouponCard(
            title: '20% OFF en cambio de pantalla',
            desc: 'Válido para todos los modelos. Preséntalo en sucursal.',
            code: 'PANTALLA20',
            expiry: 'Vence el 31 de julio',
          ),
          const SizedBox(height: 10),
          const _CouponCard(
            title: 'Diagnóstico gratis',
            desc: 'Revisión técnica completa sin costo, solo clientes VIP.',
            code: 'DIAG-VIP',
            expiry: 'Sin fecha de vencimiento',
          ),
          const SizedBox(height: 10),
          const _CouponCard(
            title: '2x1 en mica protectora',
            desc: 'Aplica en la compra de tu próximo accesorio.',
            code: 'MICA2X1',
            expiry: 'Vence el 15 de agosto',
          ),

          const SizedBox(height: 26),

          const Text('Beneficios VIP',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _BenefitRow(icon: Icons.priority_high_rounded, text: 'Atención y soporte prioritario'),
                  Divider(height: 22),
                  _BenefitRow(icon: Icons.verified_rounded, text: 'Garantía extendida en reparaciones'),
                  Divider(height: 22),
                  _BenefitRow(icon: Icons.local_shipping_rounded, text: 'Recojo y entrega a domicilio gratis'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VipChip extends StatelessWidget {
  const _VipChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text('CLIENTE VIP',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF0A0A0C), letterSpacing: .4)),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Widget? badge;

  const _QuickCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 11, color: AppColors.gray500, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
            const SizedBox(height: 4),
            if (badge != null) badge! else Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          ],
        ),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final String title;
  final String desc;
  final String code;
  final String expiry;

  const _CouponCard({required this.title, required this.desc, required this.code, required this.expiry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray900)),
                  const SizedBox(height: 3),
                  Text(desc, style: const TextStyle(fontSize: 11.5, color: AppColors.gray500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(code,
                            style: const TextStyle(
                                fontSize: 10.5, color: AppColors.accent, fontFamily: 'monospace', fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(expiry,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.gray400), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.gray700))),
      ],
    );
  }
}