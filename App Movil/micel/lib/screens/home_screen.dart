import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _ordenes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ApiService.me();
      final ordenes = await ApiService.misOrdenes();
      if (!mounted) return;
      setState(() {
        _ordenes = ordenes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _statusLabel(String? s) {
    switch (s) {
      case 'recepcion':
        return 'Recepción';
      case 'diagnostico':
        return 'Diagnóstico';
      case 'en_proceso':
        return 'En proceso';
      case 'listo':
        return 'Listo';
      default:
        return s ?? '—';
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = ClientSession.nombre.split(' ').first;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, $nombre 👋',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                      const SizedBox(height: 6),
                      if (ClientSession.esVip)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0x33F59E0B),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text('⭐ Cliente VIP',
                              style: TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    label: 'MiCel Coins',
                    value: '${ClientSession.coins}',
                    sub: '≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(0)}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    label: 'Visitas',
                    value: '${ClientSession.visits}',
                    sub: ClientSession.phone.isNotEmpty ? ClientSession.phone : '—',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Mis órdenes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray800)),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))
            else if (_ordenes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aún no tienes órdenes vinculadas a tu teléfono.',
                    style: TextStyle(color: AppColors.gray400)),
              )
            else
              ..._ordenes.map((o) {
                final m = Map<String, dynamic>.from(o as Map);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('${m['code'] ?? ''} · ${m['device'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text('${m['service'] ?? ''} · ${_statusLabel(m['status']?.toString())}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      m['monto'] != null ? 'Bs ${m['monto']}' : '',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value, sub;
  const _MetricCard({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
        ],
      ),
    );
  }
}
