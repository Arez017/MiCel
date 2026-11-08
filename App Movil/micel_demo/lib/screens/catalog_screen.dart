import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../theme.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.celulares();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vitrina MiCel Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warn.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('DEMO OFFLINE', style: TextStyle(color: AppColors.warn, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final list = snap.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = list[i];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.smartphone_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${c['marca']} ${c['modelo']}',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.text)),
                          const SizedBox(height: 2),
                          Text('${c['almacenamiento']} · ${c['color']} · ${c['estado']}',
                              style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(c['descripcion']?.toString() ?? '',
                              style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text('Bs ${c['precio']}',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
