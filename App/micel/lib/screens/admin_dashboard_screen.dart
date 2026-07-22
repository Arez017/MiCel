import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final enTaller = mockOrders.where((o) => o.estado != 'Listo').length;
    final stockCritico = mockStock.where((s) => s.esCritico).length;
    final ventasDelMes = mockOrders.where((o) => o.pagado).fold(0.0, (sum, o) => sum + o.precio);
    final comisionesPendientes =
        mockOrders.where((o) => o.estado == 'Listo').fold(0.0, (sum, o) => sum + o.comisionTecnico);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _MetricCard(label: 'EQUIPOS EN TALLER', value: '$enTaller'),
              _MetricCard(label: 'STOCK CRÍTICO', value: '$stockCritico', danger: stockCritico > 0),
              _MetricCard(label: 'VENTAS DEL MES', value: 'Bs ${ventasDelMes.toStringAsFixed(0)}'),
              _MetricCard(label: 'COMISIONES A PAGAR', value: 'Bs ${comisionesPendientes.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Órdenes recientes',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),
          ...mockOrders.reversed.take(4).map((o) => Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${o.equipo} · ${o.servicio}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                            const SizedBox(height: 2),
                            Text('${o.cliente} · Técnico: ${o.tecnico}',
                                style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                          ],
                        ),
                      ),
                      _EstadoBadge(estado: o.estado),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final bool danger;
  const _MetricCard({required this.label, required this.value, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5, color: AppColors.gray500, fontWeight: FontWeight.w500, letterSpacing: 0.4)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: danger ? AppColors.danger : AppColors.gray900)),
          ],
        ),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    switch (estado) {
      case 'Listo':
        bg = AppColors.successLight; fg = AppColors.success; break;
      case 'Reparando':
        bg = AppColors.primaryLight; fg = AppColors.accent; break;
      case 'Diagnóstico':
        bg = AppColors.warningLight; fg = AppColors.warning; break;
      default:
        bg = AppColors.gray100; fg = AppColors.gray500;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(estado, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.w600)),
    );
  }
}