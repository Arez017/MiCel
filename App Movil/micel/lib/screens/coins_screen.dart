import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class CoinsScreen extends StatefulWidget {
  const CoinsScreen({super.key});

  @override
  State<CoinsScreen> createState() => _CoinsScreenState();
}

class _CoinsScreenState extends State<CoinsScreen> {
  List<dynamic> _cupones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      await ApiService.me();
      final cupones = await ApiService.cupones();
      if (!mounted) return;
      setState(() {
        _cupones = cupones;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('MiCel Coins',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF1440), Color(0xFFBE1F1F)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tu saldo', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text('${ClientSession.coins}',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  Text('≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(2)} de descuento',
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Cupones disponibles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            if (_loading)
              const Center(child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (_cupones.isEmpty)
              const Text('No hay cupones activos por ahora.',
                  style: TextStyle(color: AppColors.gray400))
            else
              ..._cupones.map((c) {
                final m = Map<String, dynamic>.from(c as Map);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.local_offer_rounded, color: AppColors.primary),
                    title: Text('${m['titulo'] ?? m['nombre'] ?? m['codigo'] ?? 'Cupón'}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${m['descripcion'] ?? ''}'
                      '${m['solo_vip'] == true ? ' · Solo VIP' : ''}',
                      style: const TextStyle(fontSize: 12),
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
