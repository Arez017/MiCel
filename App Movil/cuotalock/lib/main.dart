import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

// ================= CONFIGURACIÓN (edita estos 3 valores) =================
const String kComercio = 'MiCel';
const String kTelefono = '70000000';
const String kPinVendedor = '2468'; // PIN del panel de PRUEBAS (solo builds debug, ver abrirPanelVendedor)
// =========================================================================

const MethodChannel _canal = MethodChannel('cuotalock/native');

class Estado {
  final bool owner;
  final bool locked;
  final int due;
  final String deviceId;
  final String linkKey; // clave de vinculación: vacía cuando el equipo ya usó un código

  const Estado({
    required this.owner,
    required this.locked,
    required this.due,
    required this.deviceId,
    this.linkKey = '',
  });

  factory Estado.desde(Map<String, dynamic> m) => Estado(
        owner: m['owner'] == true,
        locked: m['locked'] == true,
        due: (m['due'] as num).toInt(),
        deviceId: m['deviceId'] as String,
        linkKey: (m['linkKey'] as String?) ?? '',
      );

  DateTime? get vence =>
      due > 0 ? DateTime.fromMillisecondsSinceEpoch(due) : null;
}

/// Puente hacia el código nativo (Kotlin).
class Nativo {
  static Future<Estado> estado() async {
    final m = await _canal.invokeMapMethod<String, dynamic>('status');
    return Estado.desde(m!);
  }

  static Future<void> init() => _canal.invokeMethod('init');

  static Future<void> fijarVencimiento(int millis) =>
      _canal.invokeMethod('setDue', {'millis': millis});

  static Future<Map<String, dynamic>> enviarCodigo(String code) async {
    final m = await _canal
        .invokeMapMethod<String, dynamic>('submitCode', {'code': code});
    return m ?? {'ok': false, 'message': 'Sin respuesta del sistema.'};
  }

  static Future<void> entrarBloqueo() => _canal.invokeMethod('enterLock');
  static Future<void> salirBloqueo() => _canal.invokeMethod('exitLock');
  static Future<void> marcar([String? numero]) =>
      _canal.invokeMethod('dial', {'number': numero});
  static Future<void> liberar() => _canal.invokeMethod('release');
}

String _dos(int n) => n.toString().padLeft(2, '0');

String fmtDia(DateTime d) => '${_dos(d.day)}/${_dos(d.month)}/${d.year}';

String fmtRestante(Duration d) {
  if (d.isNegative) return 'Vencido';
  if (d.inDays > 0) return '${d.inDays} día(s)';
  if (d.inHours > 0) return '${d.inHours} h ${d.inMinutes % 60} min';
  return '${d.inMinutes} min ${d.inSeconds % 60} s';
}

void main() => runApp(const CuotaLockApp());

class CuotaLockApp extends StatelessWidget {
  const CuotaLockApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CuotaLock',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const Principal(),
      );
}

// ---------------------------------------------------------------------------
// Piezas visuales comunes (mismo estilo del panel y la app MiCel)
// ---------------------------------------------------------------------------

/// Cuadro rojo con "MC", igual al de la app MiCel.
class MarcaMiCel extends StatelessWidget {
  final double size;
  const MarcaMiCel({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.26),
      ),
      child: Text(
        'MC',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

/// Fondo con degradado oscuro/rojizo de MiCel.
class FondoMiCel extends StatelessWidget {
  final Widget child;
  final Color arriba;
  const FondoMiCel({
    super.key,
    required this.child,
    this.arriba = const Color(0xFF2A0A12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [arriba, const Color(0xFF0D0D0F)],
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

class TarjetaMiCel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const TarjetaMiCel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class IconoEstado extends StatelessWidget {
  final IconData icono;
  final Color color;
  final double size;
  final bool brillo;
  const IconoEstado({
    super.key,
    required this.icono,
    required this.color,
    this.size = 80,
    this.brillo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
        boxShadow: brillo
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(icono, color: color, size: size * 0.5),
    );
  }
}

class _Dato extends StatelessWidget {
  final String titulo;
  final String valor;
  const _Dato({required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: AppColors.gray400, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: const TextStyle(
              color: AppColors.gray900,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla principal: decide qué mostrar según el estado del equipo
// ---------------------------------------------------------------------------
class Principal extends StatefulWidget {
  const Principal({super.key});

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> with WidgetsBindingObserver {
  Estado? _e;
  String? _error;
  Timer? _timer;
  bool _eraBloqueado = false;
  bool _inicializado = false;
  bool _ocupado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refrescar();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _refrescar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _eraBloqueado = false; // fuerza a re-entrar al modo bloqueo si corresponde
      _refrescar();
    }
  }

  Future<void> _refrescar() async {
    if (_ocupado) return;
    _ocupado = true;
    try {
      final e = await Nativo.estado();
      if (e.owner && !_inicializado) {
        await Nativo.init();
        _inicializado = true;
      }
      if (e.locked && !_eraBloqueado) await Nativo.entrarBloqueo();
      if (!e.locked && _eraBloqueado) await Nativo.salirBloqueo();
      _eraBloqueado = e.locked;
      if (mounted) {
        setState(() {
          _e = e;
          _error = null;
        });
      }
    } catch (err) {
      if (mounted) setState(() => _error = '$err');
    } finally {
      _ocupado = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;
    if (e == null) {
      return Scaffold(
        body: FondoMiCel(
          child: Center(
            child: _error != null
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Error: $_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.gray400),
                    ),
                  )
                : const CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }
    if (!e.owner) return PantallaNoConfigurada(estado: e);
    if (e.locked) {
      return PopScope(canPop: false, child: PantallaBloqueo(estado: e));
    }
    return PantallaInicio(estado: e);
  }
}

// ---------------------------------------------------------------------------
// Pantalla: la app todavía no es Device Owner
// ---------------------------------------------------------------------------
class PantallaNoConfigurada extends StatelessWidget {
  final Estado estado;
  const PantallaNoConfigurada({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FondoMiCel(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TarjetaMiCel(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
                child: Column(
                  children: [
                    const MarcaMiCel(size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Equipo sin configurar',
                      style: TextStyle(
                        color: AppColors.gray900,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta app necesita ser «Device Owner» para bloquear el equipo '
                      'y evitar que se desinstale. Con el celular conectado por USB '
                      '(y sin cuentas agregadas) ejecuta en la computadora:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.gray400,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const SelectableText(
                        'adb shell dpm set-device-owner com.cuotalock.bloqueo/.AdminReceiver',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: AppColors.gray800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'ID del equipo: ${estado.deviceId}',
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Esta pantalla se actualiza sola cuando el comando funcione.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.gray400, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pantalla: equipo al día
// ---------------------------------------------------------------------------
class PantallaInicio extends StatelessWidget {
  final Estado estado;
  const PantallaInicio({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final vence = estado.vence;
    final restante = vence?.difference(DateTime.now());

    final Color acento;
    final IconData icono;
    final String titulo;
    if (vence == null) {
      acento = AppColors.gray400;
      icono = Icons.hourglass_empty_rounded;
      titulo = 'Sin fecha configurada';
    } else if (restante!.inHours < 72) {
      acento = AppColors.warning;
      icono = Icons.schedule_rounded;
      titulo = 'Cuota por vencer';
    } else {
      acento = AppColors.success;
      icono = Icons.verified_user_rounded;
      titulo = 'Equipo al día';
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FondoMiCel(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // Encabezado con la marca (mantener pulsado = panel del vendedor)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Panel de pruebas: no existe en el APK de producción (el PIN está en el repo público)
              onLongPress: kReleaseMode ? null : () => abrirPanelVendedor(context),
              child: Row(
                children: [
                  const MarcaMiCel(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CuotaLock',
                          style: TextStyle(
                            color: AppColors.gray900,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Equipo financiado por $kComercio',
                          style: const TextStyle(
                            color: AppColors.gray400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Estado del equipo
            TarjetaMiCel(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 18),
              child: Column(
                children: [
                  IconoEstado(icono: icono, color: acento, size: 84),
                  const SizedBox(height: 14),
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: AppColors.gray900,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (vence != null) ...[
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _Dato(
                            titulo: 'Próximo vencimiento',
                            valor: fmtDia(vence),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _Dato(
                            titulo: 'Tiempo restante',
                            valor: fmtRestante(restante!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ID del equipo
            TarjetaMiCel(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  const Icon(Icons.phone_android_rounded, color: AppColors.gray400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ID del equipo',
                          style: TextStyle(color: AppColors.gray400, fontSize: 12),
                        ),
                        const SizedBox(height: 2),
                        SelectableText(
                          estado.deviceId,
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copiar ID',
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: estado.deviceId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID copiado')),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Clave de vinculación: solo aparece hasta que se usa el primer código
            if (estado.linkKey.isNotEmpty) ...[
              const SizedBox(height: 12),
              TarjetaMiCel(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clave de vinculación (solo para el vendedor)',
                      style: TextStyle(color: AppColors.gray400, fontSize: 12),
                    ),
                    const SizedBox(height: 2),
                    SelectableText(
                      estado.linkKey,
                      style: const TextStyle(
                        color: AppColors.gray900,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Escríbela en la web junto con el ID. Desaparece al ingresar el código de activación.',
                      style: TextStyle(color: AppColors.gray400, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payments_rounded),
                label: const Text('Ingresar código de pago'),
                onPressed: () => _dialogoCodigo(context),
              ),
            ),
            const SizedBox(height: 12),

            // Contacto del comercio
            TarjetaMiCel(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.storefront_rounded, color: AppColors.gray400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$kComercio · Tel. $kTelefono',
                      style: const TextStyle(color: AppColors.gray800, fontSize: 13),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => Nativo.marcar(kTelefono),
                    icon: const Icon(Icons.call_rounded, size: 18),
                    label: const Text('Llamar'),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dialogoCodigo(BuildContext context) async {
    final ctrl = TextEditingController();
    final enviar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Código de pago',
          style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
          style: const TextStyle(color: AppColors.gray900, letterSpacing: 1.5),
          decoration: const InputDecoration(hintText: '20800-0001-123456'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.gray400)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
    if (enviar != true) return;
    final r = await Nativo.enviarCodigo(ctrl.text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(r['message'] as String? ?? '')),
    );
  }
}

// ---------------------------------------------------------------------------
// Panel del vendedor (mantener pulsado el logo / título "CuotaLock")
// ---------------------------------------------------------------------------
Future<void> abrirPanelVendedor(BuildContext context) async {
  if (kReleaseMode) return; // sin atajos para liberar/fijar fecha en producción
  final pin = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text(
        'Panel del vendedor',
        style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.w800),
      ),
      content: TextField(
        controller: pin,
        obscureText: true,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: AppColors.gray900),
        decoration: const InputDecoration(
          labelText: 'PIN',
          prefixIcon: Icon(Icons.lock_outline_rounded),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.gray400)),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(c, pin.text == kPinVendedor),
          child: const Text('Entrar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (c) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.event_rounded, color: AppColors.primary),
              title: const Text('Fijar fecha de vencimiento'),
              onTap: () async {
                Navigator.pop(c);
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 730)),
                );
                if (d != null) {
                  await Nativo.fijarVencimiento(
                    DateTime(d.year, d.month, d.day, 23, 59, 59).millisecondsSinceEpoch,
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_rounded, color: AppColors.warning),
              title: const Text('PRUEBA: bloquear en 30 segundos'),
              onTap: () async {
                Navigator.pop(c);
                await Nativo.fijarVencimiento(
                  DateTime.now().millisecondsSinceEpoch + 30000,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_open_rounded, color: AppColors.danger),
              title: const Text('Liberar equipo (quitar Device Owner)'),
              onTap: () async {
                Navigator.pop(c);
                final seguro = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    title: const Text(
                      '¿Liberar equipo?',
                      style: TextStyle(color: AppColors.gray900, fontWeight: FontWeight.w800),
                    ),
                    content: const Text(
                      'Se quitan todas las restricciones y la app podrá desinstalarse.',
                      style: TextStyle(color: AppColors.gray400),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('No', style: TextStyle(color: AppColors.gray400)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Sí, liberar'),
                      ),
                    ],
                  ),
                );
                if (seguro == true) await Nativo.liberar();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Pantalla: equipo bloqueado
// ---------------------------------------------------------------------------
class PantallaBloqueo extends StatefulWidget {
  final Estado estado;
  const PantallaBloqueo({super.key, required this.estado});

  @override
  State<PantallaBloqueo> createState() => _PantallaBloqueoState();
}

class _PantallaBloqueoState extends State<PantallaBloqueo> {
  final _ctrl = TextEditingController();
  String? _msg;
  bool _ok = false;
  bool _enviando = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _desbloquear() async {
    setState(() {
      _enviando = true;
      _msg = null;
    });
    final r = await Nativo.enviarCodigo(_ctrl.text);
    if (!mounted) return;
    setState(() {
      _enviando = false;
      _ok = r['ok'] == true;
      _msg = r['message'] as String?;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: FondoMiCel(
        arriba: const Color(0xFF3A0A14),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const IconoEstado(
                    icono: Icons.lock_rounded,
                    color: AppColors.primary,
                    size: 104,
                    brillo: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'EQUIPO BLOQUEADO',
                    style: TextStyle(
                      color: AppColors.gray900,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu cuota está vencida. Regulariza tu pago en $kComercio '
                    'para desbloquear este equipo.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.gray400,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  TarjetaMiCel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.phone_android_rounded,
                                color: AppColors.gray400, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'ID del equipo',
                              style: TextStyle(color: AppColors.gray400, fontSize: 12),
                            ),
                            const Spacer(),
                            Text(
                              widget.estado.deviceId,
                              style: const TextStyle(
                                color: AppColors.gray900,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1),
                        ),
                        TextField(
                          controller: _ctrl,
                          keyboardType: TextInputType.phone,
                          textAlign: TextAlign.center,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9-]')),
                          ],
                          style: const TextStyle(
                            color: AppColors.gray900,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Código de desbloqueo',
                            hintText: '20800-0001-123456',
                            prefixIcon: Icon(Icons.vpn_key_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _enviando ? null : _desbloquear,
                          child: Text(_enviando ? 'Verificando...' : 'Desbloquear'),
                        ),
                        if (_msg != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _msg!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _ok ? AppColors.success : AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.call_rounded),
                      label: Text('Llamar a $kComercio'),
                      onPressed: () => Nativo.marcar(kTelefono),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: BorderSide(
                          color: AppColors.danger.withValues(alpha: 0.5),
                        ),
                      ),
                      icon: const Icon(Icons.emergency_rounded),
                      label: const Text('Llamada de emergencia'),
                      onPressed: () => Nativo.marcar(),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Protegido por MiCel · CuotaLock',
                    style: TextStyle(color: AppColors.gray400, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
