import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';

class MiComisionScreen extends StatelessWidget {
  const MiComisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nombre = Session.currentUser?.nombre ?? '';
    final completadas = mockOrders.where((o) => o.tecnico == nombre && o.estado == 'Listo').toList();
    final total = comisionTotalTecnico(nombre);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppColors.glowYellow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TU COMISIÓN ESTE MES', style: TextStyle(fontSize: 11, color: AppColors.gray400, letterSpacing: .6)),
                const SizedBox(height: 6),
                Text('Bs ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.accent)),
                const SizedBox(height: 4),
                Text('${completadas.length} órdenes completadas · 15% por orden',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Detalle', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),
          if (completadas.isEmpty)
            const Text('Aún no completas órdenes este mes.', style: TextStyle(fontSize: 12.5, color: AppColors.gray500)),
          ...completadas.map((o) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${o.codigo} · ${o.servicio}',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                            const SizedBox(height: 2),
                            Text('Precio del servicio: Bs ${o.precio.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                          ],
                        ),
                      ),
                      Text('+Bs ${o.comisionTecnico.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.success)),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}