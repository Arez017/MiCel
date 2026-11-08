import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../services/session.dart';
import '../theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.ordenesDe(Session.username);
  }

  Color _statusColor(String s) {
    if (s.toLowerCase().contains('listo')) return AppColors.success;
    if (s.toLowerCase().contains('proceso')) return AppColors.warn;
    return AppColors.muted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis órdenes (demo)')),
      body: FutureBuilder(
        future: _future,
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final list = snap.data!;
          if (list.isEmpty) {
            return const Center(child: Text('Sin órdenes de demo para este usuario', style: TextStyle(color: AppColors.muted)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final o = list[i];
              final st = o['status']?.toString() ?? '';
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(o['code']?.toString() ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(st).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(st, style: TextStyle(color: _statusColor(st), fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('${o['device']} — ${o['service']}', style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Bs ${o['monto']}', style: const TextStyle(color: AppColors.muted, fontSize: 13)),
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
