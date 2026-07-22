import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  // Placeholder de ubicación — reemplaza estas coordenadas por la sucursal real
  static const double _lat = -16.5000;
  static const double _lng = -68.1193;
  static const String _direccion = 'MiCel · Sucursal Central, Av. Ejemplo #123, La Paz';

  Future<void> _abrirEnGoogleMaps() async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // Número del técnico a cargo — reemplázalo si cambia de responsable
  static const String _whatsappTecnico = '59161154806'; // 591 = código de Bolivia

  Future<void> _contactarWhatsapp() async {
    final mensaje = Uri.encodeComponent(
      'Hola! Soy Juan Quispe, cliente de MiCel. Quisiera consultar sobre mi orden ORD-2291.',
    );
    final uri = Uri.parse('https://wa.me/$_whatsappTecnico?text=$mensaje');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          const Text('Seguimiento de mi equipo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.gray900)),
          const SizedBox(height: 4),
          const Text('Orden ORD-2291', style: TextStyle(fontSize: 12.5, color: AppColors.gray500)),
          const SizedBox(height: 18),

          // ---- Card del equipo ----
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        child: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('iPhone 13 Pro', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                            Text('Cambio de pantalla', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                          ],
                        ),
                      ),
                      const MiCelBadge(text: 'En proceso', type: MiCelBadgeType.warning),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _ProgressSteps(current: 2),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),
          const Text('Pagar con banca móvil',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 4),
          const Text('Escanea el código QR desde tu app bancaria para adelantar el pago de esta reparación.',
              style: TextStyle(fontSize: 12, color: AppColors.gray500)),
          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                      border: Border.all(color: AppColors.gray200, width: 2),
                    ),
                    child: QrImageView(
                      data: 'https://micel.app/pagar?orden=ORD-2291&monto=350.00',
                      version: QrVersions.auto,
                      size: 170,
                      gapless: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Monto pendiente: Bs 350.00',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                  const SizedBox(height: 2),
                  const Text('Ref: ORD-2291', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _contactarWhatsapp,
              icon: const Icon(Icons.chat_rounded, size: 18, color: AppColors.success),
              label: const Text('Contactar al técnico por WhatsApp', style: TextStyle(color: AppColors.success)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.success)),
            ),
          ),

          const SizedBox(height: 22),
          const Text('Ubicación de la sucursal',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.gray800)),
          const SizedBox(height: 12),

          Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _abrirEnGoogleMaps,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vista previa tipo "mapa" (placeholder, sin necesitar API key)
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: AppColors.gray100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(size: const Size(double.infinity, 140), painter: _FakeMapPainter()),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: AppColors.glowRed,
                          ),
                          child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(_direccion, style: TextStyle(fontSize: 12.5, color: AppColors.gray700)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: _abrirEnGoogleMaps,
                          icon: const Icon(Icons.map_rounded, size: 16),
                          label: const Text('Abrir mapa'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  final int current; // 0=recibido 1=diagnostico 2=reparando 3=listo
  const _ProgressSteps({required this.current});

  static const _labels = ['Recibido', 'Diagnóstico', 'Reparando', 'Listo'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length, (i) {
        final done = i < current;
        final active = i == current;
        Color bg, fg, border;
        if (done) {
          bg = AppColors.successLight; fg = AppColors.success; border = AppColors.success;
        } else if (active) {
          bg = AppColors.primaryLight; fg = AppColors.accent; border = AppColors.primary;
        } else {
          bg = AppColors.surfaceAlt; fg = AppColors.gray400; border = AppColors.gray200;
        }
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i == _labels.length - 1 ? 0 : 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(_labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: fg, fontWeight: active || done ? FontWeight.w700 : FontWeight.w500)),
          ),
        );
      }),
    );
  }
}

/// Dibuja un "mapa falso" minimalista (líneas tipo calles) para no depender
/// de ningún API key. Al tocar la card, se abre la ubicación real en Google Maps.
class _FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.gray300
      ..strokeWidth = 1.2;

    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}