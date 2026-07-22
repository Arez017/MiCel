import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'mock_data.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = mockStock.map((s) => s.categoria).toSet().toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${mockStock.length} repuestos en catálogo',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.gray500)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final cat in categorias) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 8),
              child: Text(cat.toUpperCase(),
                  style: const TextStyle(fontSize: 11, color: AppColors.gray400, letterSpacing: .6, fontWeight: FontWeight.w600)),
            ),
            ...mockStock.where((s) => s.categoria == cat).map((item) => _StockTile(item: item)),
          ],
        ],
      ),
    );
  }
}

class _StockTile extends StatelessWidget {
  final StockItem item;
  const _StockTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = item.esCritico
        ? AppColors.danger
        : item.esBajo
            ? AppColors.warning
            : AppColors.gray200;
    final double ratio = (item.cantidad / (item.minimo * 2)).clamp(0.05, 1.0);
    final Color barColor = item.esCritico ? AppColors.danger : (item.esBajo ? AppColors.warning : AppColors.success);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.id,
                        style: const TextStyle(fontSize: 10, color: AppColors.gray400, fontFamily: 'monospace')),
                    const SizedBox(height: 4),
                    Text(item.nombre,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 5,
                        backgroundColor: AppColors.gray100,
                        valueColor: AlwaysStoppedAnimation(barColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item.cantidad}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: barColor)),
                  Text('mín. ${item.minimo}', style: const TextStyle(fontSize: 10.5, color: AppColors.gray400)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}