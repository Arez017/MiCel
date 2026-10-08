import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/api_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final _codeCtrl = TextEditingController();
  Map<String, dynamic>? _orden;
  bool _loading = false;
  String? _error;

  Future<void> _buscar() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Ingresa el código de tu orden (ej. OS-0041)');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _orden = null;
    });
    try {
      final data = await ApiService.seguimiento(code);
      if (!mounted) return;
      setState(() {
        _orden = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo consultar. Revisa tu conexión.';
        _loading = false;
      });
    }
  }

  String _label(String? s) {
    const m = {
      'recepcion': 'Recepción',
      'diagnostico': 'Diagnóstico',
      'en_proceso': 'En proceso',
      'listo': 'Listo para entrega',
    };
    return m[s] ?? (s ?? '—');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Seguimiento de equipo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Ingresa el código que te dieron al dejar tu celular.',
              style: TextStyle(fontSize: 13, color: AppColors.gray400)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'Ej: OS-0041',
                    prefixIcon: Icon(Icons.qr_code_2),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _loading ? null : _buscar,
                child: _loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Buscar'),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          ],
          if (_orden != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${_orden!['code'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 8),
                    _row('Equipo', '${_orden!['device'] ?? '—'}'),
                    _row('Servicio', '${_orden!['service'] ?? '—'}'),
                    _row('Estado', _label(_orden!['status']?.toString() ?? _orden!['status_label']?.toString())),
                    _row('Cliente', '${_orden!['client'] ?? '—'}'),
                    if (_orden!['tecnico'] != null)
                      _row('Técnico', '${_orden!['tecnico'] is Map ? (_orden!['tecnico']['name'] ?? '') : _orden!['tecnico']}'),
                    if (_orden!['monto'] != null) _row('Monto', 'Bs ${_orden!['monto']}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(k, style: const TextStyle(color: AppColors.gray400, fontSize: 13))),
          Expanded(child: Text(v, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
