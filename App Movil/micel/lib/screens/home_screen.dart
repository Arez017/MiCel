import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<dynamic> _ordenes = [];
  bool _loading = true;
  String? _error;
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _load();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
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
      _anim.forward(from: 0);
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

  Color _statusColor(String? s) {
    switch (s) {
      case 'listo':
        return AppColors.success;
      case 'en_proceso':
        return AppColors.warning;
      case 'diagnostico':
        return const Color(0xFF3B82F6);
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = ClientSession.nombre.split(' ').first;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.2,
            colors: [Color(0x28FF1440), Color(0xFF0A0A0B)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
              children: [
                // Header animado
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _saludo(),
                                style: const TextStyle(fontSize: 13, color: AppColors.gray400),
                              ),
                              const SizedBox(height: 4),
                              Text('Hola, $nombre 👋',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.gray900,
                                      letterSpacing: -0.3)),
                            ],
                          ),
                        ),
                        if (ClientSession.esVip)
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.elasticOut,
                            builder: (_, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                                ),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text('⭐ VIP',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Banner coins — más vivo
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: _CoinsBanner(
                      coins: ClientSession.coins,
                      bs: ClientSession.coinsValorBs,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Métricas
                FadeTransition(
                  opacity: _fade,
                  child: Row(
                    children: [
                      Expanded(
                        child: _PulseCard(
                          delay: 80,
                          child: _MiniCard(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Visitas',
                            value: '${ClientSession.visits}',
                            accent: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PulseCard(
                          delay: 140,
                          child: _MiniCard(
                            icon: Icons.badge_outlined,
                            label: 'Código',
                            value: ClientSession.code.isNotEmpty ? ClientSession.code : '—',
                            accent: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                const Text('Mis órdenes',
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.gray900)),
                const SizedBox(height: 4),
                const Text('Desliza hacia abajo para actualizar',
                    style: TextStyle(fontSize: 12, color: AppColors.gray400)),
                const SizedBox(height: 12),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  )
                else if (_error != null)
                  _EmptyBox(text: _error!, isError: true)
                else if (_ordenes.isEmpty)
                  const _EmptyBox(
                      text:
                          'Aún no tienes órdenes vinculadas.\nCuando dejes un equipo, aparecerán aquí con su estado.')
                else
                  ...List.generate(_ordenes.length, (i) {
                    final m = Map<String, dynamic>.from(_ordenes[i] as Map);
                    final st = m['status']?.toString();
                    return _PulseCard(
                      delay: 60 + i * 70,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _statusColor(st).withValues(alpha: 0.25),
                                    _statusColor(st).withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.phone_iphone_rounded,
                                  color: _statusColor(st), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${m['code'] ?? ''} · ${m['device'] ?? ''}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: AppColors.gray900)),
                                  const SizedBox(height: 3),
                                  Text('${m['service'] ?? '—'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.gray400)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(st).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(_statusLabel(st),
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _statusColor(st))),
                                  ),
                                ],
                              ),
                            ),
                            if (m['monto'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Bs ${m['monto']}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppColors.gray900)),
                                  const Text('monto',
                                      style: TextStyle(
                                          fontSize: 10, color: AppColors.gray400)),
                                ],
                              ),
                          ],
                        ),
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

  String _saludo() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }
}

class _CoinsBanner extends StatelessWidget {
  final int coins;
  final double bs;
  const _CoinsBanner({required this.coins, required this.bs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF1440), Color(0xFFBE123C), Color(0xFF7F1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            top: -8,
            child: Icon(Icons.monetization_on_rounded,
                size: 88, color: Colors.white.withValues(alpha: 0.08)),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MiCel Coins',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: coins),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Text('$v',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.05)),
                    ),
                    const SizedBox(height: 4),
                    Text('≈ Bs ${bs.toStringAsFixed(0)} de descuento · 1 coin = Bs 1',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  final int delay;
  final Widget child;
  const _PulseCard({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color accent;
  const _MiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.gray900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  final bool isError;
  const _EmptyBox({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: isError ? AppColors.danger : AppColors.gray400,
              fontSize: 13,
              height: 1.45)),
    );
  }
}
