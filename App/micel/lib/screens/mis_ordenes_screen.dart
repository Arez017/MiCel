import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';

class MisOrdenesScreen extends StatelessWidget {
  const MisOrdenesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = Session.currentUser?.nombre ?? '';
    final misOrdenes = mockOrders.where((o) => o.tecnico == nombre).toList();

    if (misOrdenes.isEmpty) {
      return const Center(
        child: Text('No tienes órdenes asignadas por ahora.', style: TextStyle(color: AppColors.gray500)),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: misOrdenes.map((o) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.codigo,
                                style: const TextStyle(fontSize: 11, color: AppColors.gray400, fontFamily: 'monospace')),
                            const SizedBox(height: 3),
                            Text('${o.equipo} · ${o.servicio}',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                          ],
                        ),
                      ),
                      _EstadoBadge(estado: o.estado),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(o.cliente, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
                      const Spacer(),
                      Text('Bs ${o.precio.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.gray800)),
                    ],
                  ),
                  if (o.estado == 'Listo') ...[
                    const SizedBox(height: 6),
                    Text('Tu comisión: Bs ${o.comisionTecnico.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
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