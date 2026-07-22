import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'client_shell.dart';

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Meta simple de gamificación: próximo nivel a 1000 MC
    const meta = 1000;
    final progreso = ClientData.coins / meta;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const Text('MiCel Coins', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          const SizedBox(height: 4),
          const Text('Acumula y canjea en tus reparaciones', style: TextStyle(fontSize: 12.5, color: AppColors.gray500)),
          const SizedBox(height: 18),

          // ---- Card de saldo ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.surface, AppColors.surfaceAlt],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: AppColors.gray200),
              boxShadow: AppColors.glowYellow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SALDO ACTUAL', style: TextStyle(fontSize: 11, color: AppColors.gray400, letterSpacing: .8)),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${ClientData.coins}',
                        style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: AppColors.accent, height: 1)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, left: 6),
                      child: Text('MC', style: TextStyle(fontSize: 16, color: AppColors.gray400, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Equivale a Bs ${ClientData.bsPorDescuento.toStringAsFixed(2)} de descuento',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.gray600)),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progreso.clamp(0, 1),
                    minHeight: 6,
                    backgroundColor: AppColors.gray100,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                ),
                const SizedBox(height: 6),
                Text('${ClientData.coins} / $meta MC para tu próxima recompensa VIP',
                    style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Solicitud de canje enviada. Te confirmaremos por WhatsApp.')),
                      );
                    },
                    child: const Text('Canjear coins en mi próxima reparación'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),
          const Text('Historial de movimientos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),

          const _CoinHistoryTile(
            title: 'Reparación · Cambio de batería',
            date: '02 jul 2026',
            amount: '+50 MC',
            positive: true,
          ),
          const _CoinHistoryTile(
            title: 'Referido: Ana Mamani',
            date: '28 jun 2026',
            amount: '+100 MC',
            positive: true,
          ),
          const _CoinHistoryTile(
            title: 'Canje: Bs 20 de descuento',
            date: '14 jun 2026',
            amount: '-200 MC',
            positive: false,
          ),
          const _CoinHistoryTile(
            title: 'Reparación · Cambio de pantalla',
            date: '30 may 2026',
            amount: '+80 MC',
            positive: true,
          ),
        ],
      ),
    );
  }
}

class _CoinHistoryTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final bool positive;

  const _CoinHistoryTile({required this.title, required this.date, required this.amount, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  positive ? Icons.add_rounded : Icons.remove_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                    const SizedBox(height: 2),
                    Text(date, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                  ],
                ),
              ),
              Text(amount, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}