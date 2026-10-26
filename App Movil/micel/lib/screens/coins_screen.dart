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
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.9, -0.9),
            radius: 1.1,
            colors: [Color(0x33FF1440), Color(0xFF0A0A0B)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text('MiCel Coins',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.gray900)),
                const SizedBox(height: 6),
                const Text('Acumula al pagar servicios y canjea descuentos',
                    style: TextStyle(fontSize: 13, color: AppColors.gray400)),
                const SizedBox(height: 18),

                // Saldo grande animado
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF1440), Color(0xFF9F1239), Color(0xFF4C0519)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Tu saldo',
                              style: TextStyle(color: Colors.white70, fontSize: 14)),
                          const Spacer(),
                          if (ClientSession.esVip)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text('⭐ VIP',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TweenAnimationBuilder<int>(
                        tween: IntTween(begin: 0, end: ClientSession.coins),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, __) => Text('$v',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 1)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                          '≈ Bs ${ClientSession.coinsValorBs.toStringAsFixed(2)} de descuento',
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cómo funcionan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('¿Cómo funcionan?',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: AppColors.gray900)),
                      const SizedBox(height: 12),
                      _rule(Icons.add_circle_outline, 'Ganas 1 coin por cada Bs 10 que pagas'),
                      _rule(Icons.sell_outlined, '1 coin = Bs 1 de descuento al canjear'),
                      _rule(Icons.workspace_premium_outlined,
                          'Al gastar Bs 1000 en total → pasas a VIP'),
                      _rule(Icons.phone_android_outlined,
                          'Se acreditan si el teléfono de la orden coincide con tu cuenta'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text('Cupones disponibles',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (_cupones.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                        'No hay cupones activos por ahora.\nSigue acumulando coins con tus servicios.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.gray400, fontSize: 13, height: 1.4)),
                  )
                else
                  ..._cupones.map((c) {
                    final m = Map<String, dynamic>.from(c as Map);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x33FF1440), Color(0x15FF1440)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.local_offer_rounded,
                                color: AppColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${m['titulo'] ?? m['nombre'] ?? m['codigo'] ?? 'Cupón'}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: AppColors.gray900)),
                                if ((m['descripcion'] ?? '').toString().isNotEmpty)
                                  Text('${m['descripcion']}',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.gray400)),
                                if (m['solo_vip'] == true)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text('Solo VIP',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.warning,
                                            fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _rule(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: AppColors.gray800, height: 1.3))),
        ],
      ),
    );
  }
}
