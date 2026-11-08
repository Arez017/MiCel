import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ================= CONFIGURACIÓN (edita estos 3 valores) =================
const String kComercio = 'Tu Tienda de Celulares';
const String kTelefono = '70000000';
const String kPinVendedor = '2468'; // PIN del panel del vendedor (mantener pulsado el título)
// =========================================================================

const MethodChannel _canal = MethodChannel('cuotalock/native');

class Estado {
  final bool owner;
  final bool locked;
  final int due;
  final String deviceId;

  const Estado({
    required this.owner,
    required this.locked,
    required this.due,
    required this.deviceId,
  });

  factory Estado.desde(Map<String, dynamic> m) => Estado(
        owner: m['owner'] == true,
        locked: m['locked'] == true,
        due: (m['due'] as num).toInt(),
        deviceId: m['deviceId'] as String,
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

String fmtFecha(DateTime d) =>
    '${_dos(d.day)}/${_dos(d.month)}/${d.year} ${_dos(d.hour)}:${_dos(d.minute)}';

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
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
        ),
        home: const Principal(),
      );
}

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
        body: Center(
          child: _error != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $_error'),
                )
              : const CircularProgressIndicator(),
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
      appBar: AppBar(title: const Text('CuotaLock')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.settings_suggest, size: 72, color: Colors.amber),
          const SizedBox(height: 12),
          const Text(
            'Equipo sin configurar',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Esta app necesita ser "Device Owner" para poder bloquear el equipo '
            'y evitar que se desinstale. Con el celular conectado por USB (y sin '
            'cuentas de Google agregadas) ejecuta en la computadora:',
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: SelectableText(
                'adb shell dpm set-device-owner com.cuotalock.bloqueo/.AdminReceiver',
                style: TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('ID del equipo: ${estado.deviceId}'),
          const SizedBox(height: 8),
          const Text('Esta pantalla se actualiza sola cuando el comando funcione.'),
        ],
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
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () => abrirPanelVendedor(context),
          child: const Text('CuotaLock'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.verified_user, size: 64, color: Colors.greenAccent),
                  const SizedBox(height: 8),
                  Text(
                    vence == null ? 'Sin fecha configurada' : 'Equipo al día',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (vence != null) ...[
                    Text('Próximo vencimiento: ${fmtFecha(vence)}'),
                    const SizedBox(height: 4),
                    Text('Tiempo restante: ${fmtRestante(restante!)}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('ID del equipo'),
              subtitle: SelectableText(
                estado.deviceId,
                style: const TextStyle(fontSize: 20, letterSpacing: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.payments),
            label: const Text('Ingresar código de pago'),
            onPressed: () => _dialogoCodigo(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Comercio: $kComercio · Tel. $kTelefono',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60),
          ),
        ],
      ),
    );
  }

  Future<void> _dialogoCodigo(BuildContext context) async {
    final ctrl = TextEditingController();
    final enviar = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Código de pago'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
          decoration: const InputDecoration(hintText: '20800-123456'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Aplicar')),
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
// Panel del vendedor (mantener pulsado el título "CuotaLock")
// ---------------------------------------------------------------------------
Future<void> abrirPanelVendedor(BuildContext context) async {
  final pin = TextEditingController();
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Panel del vendedor'),
      content: TextField(
        controller: pin,
        obscureText: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'PIN'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () => Navigator.pop(c, pin.text == kPinVendedor),
          child: const Text('Entrar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  showModalBottomSheet<void>(
    context: context,
    builder: (c) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.event),
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
            leading: const Icon(Icons.timer),
            title: const Text('PRUEBA: bloquear en 30 segundos'),
            onTap: () async {
              Navigator.pop(c);
              await Nativo.fijarVencimiento(
                DateTime.now().millisecondsSinceEpoch + 30000,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock_open, color: Colors.redAccent),
            title: const Text('Liberar equipo (quitar Device Owner)'),
            onTap: () async {
              Navigator.pop(c);
              final seguro = await showDialog<bool>(
                context: context,
                builder: (d) => AlertDialog(
                  title: const Text('¿Liberar equipo?'),
                  content: const Text(
                    'Se quitan todas las restricciones y la app podrá desinstalarse.',
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('No')),
                    FilledButton(onPressed: () => Navigator.pop(d, true), child: const Text('Sí, liberar')),
                  ],
                ),
              );
              if (seguro == true) await Nativo.liberar();
            },
          ),
        ],
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
      backgroundColor: const Color(0xFF2B0A0A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const Icon(Icons.lock, size: 88, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    'EQUIPO BLOQUEADO',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu cuota está vencida. Regulariza tu pago en $kComercio '
                    'para desbloquear este equipo.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text('ID del equipo: ${widget.estado.deviceId}',
                      style: const TextStyle(fontSize: 18, letterSpacing: 2)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _ctrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))],
                    decoration: const InputDecoration(
                      labelText: 'Código de desbloqueo',
                      hintText: '20800-123456',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _enviando ? null : _desbloquear,
                      child: Text(_enviando ? 'Verificando...' : 'Desbloquear'),
                    ),
                  ),
                  if (_msg != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _msg!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _ok ? Colors.greenAccent : Colors.orangeAccent),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.call),
                      label: Text('Llamar a $kComercio'),
                      onPressed: () => Nativo.marcar(kTelefono),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.emergency),
                      label: const Text('Llamada de emergencia'),
                      onPressed: () => Nativo.marcar(),
                    ),
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
