import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';

class CommissionScreen extends StatelessWidget {
  const CommissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tecnicos = mockUsers.where((u) => u.role == UserRole.tecnico && u.activo).toList();
    final totalGeneral = tecnicos.fold(0.0, (sum, t) => sum + comisionTotalTecnico(t.nombre));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: AppColors.glowRed,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TOTAL A PAGAR ESTE MES', style: TextStyle(fontSize: 11, color: AppColors.gray400, letterSpacing: .6)),
                const SizedBox(height: 6),
                Text('Bs ${totalGeneral.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.accent)),
                const SizedBox(height: 4),
                const Text('15% por orden completada (estado "Listo")',
                    style: TextStyle(fontSize: 11.5, color: AppColors.gray500)),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text('Comisión por técnico',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),
          ...tecnicos.map((t) {
            final ordenesListas = mockOrders.where((o) => o.tecnico == t.nombre && o.estado == 'Listo').toList();
            final comision = comisionTotalTecnico(t.nombre);
            final iniciales = t.nombre.split(' ').map((p) => p.isNotEmpty ? p[0] : '').take(2).join();

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                childrenPadding: const EdgeInsets.only(left: 14, right: 14, bottom: 10),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(iniciales, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                title: Text(t.nombre, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                subtitle: Text('${ordenesListas.length} órdenes completadas',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.gray400)),
                trailing: Text('Bs ${comision.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.success)),
                children: ordenesListas.isEmpty
                    ? [const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Sin órdenes completadas todavía este mes.',
                              style: TextStyle(fontSize: 11.5, color: AppColors.gray400)),
                        ),
                      )]
                    : ordenesListas
                        .map((o) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text('${o.codigo} · ${o.servicio}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.gray700)),
                                  ),
                                  Text('Bs ${o.comisionTecnico.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                                ],
                              ),
                            ))
                        .toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}