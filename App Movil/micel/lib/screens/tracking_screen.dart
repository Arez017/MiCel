import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../app_theme.dart';
import '../services/api_service.dart';
import '../services/session.dart';

/// Seguimiento: al abrir la pestaña carga SOLO las órdenes del cliente logueado
/// (mismo teléfono). Sin tener que escribir código.
class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<Map<String, dynamic>> _ordenes = [];
  bool _loading = true;
  String? _error;
  String? _expandedCode;
  bool _mostrarBusquedaManual = false;

  final _codeCtrl = TextEditingController();
  Timer? _debounce;
  Map<String, dynamic>? _busquedaExtra;
  bool _loadingBusqueda = false;
  String? _errorBusqueda;

  @override
  void initState() {
    super.initState();
    _cargar();
    _codeCtrl.addListener(_onCodeChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _codeCtrl.removeListener(_onCodeChanged);
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (!ClientSession.isLoggedIn) {
      setState(() {
        _loading = false;
        _ordenes = [];
        _error = 'Inicia sesión para ver el seguimiento de tus equipos.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ApiService.misOrdenes();
      if (!mounted) return;
      final ordenes = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      // Abrir la primera por defecto (la más reciente)
      String? firstCode;
      if (ordenes.isNotEmpty) {
        firstCode = (ordenes.first['code'] ?? '').toString();
        if (firstCode.isEmpty) firstCode = null;
      }
      setState(() {
        _ordenes = ordenes;
        _loading = false;
        _expandedCode = firstCode;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onCodeChanged() {
    _debounce?.cancel();
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() {
        _busquedaExtra = null;
        _errorBusqueda = null;
      });
      return;
    }
    if (code.length < 4) return;
    _debounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      if (_codeCtrl.text.trim() == code) _buscarExtra(code);
    });
  }

  Future<void> _buscarExtra(String code) async {
    setState(() {
      _loadingBusqueda = true;
      _errorBusqueda = null;
      _busquedaExtra = null;
    });
    try {
      final data = await ApiService.seguimiento(code);
      if (!mounted) return;
      setState(() {
        _busquedaExtra = data;
        _loadingBusqueda = false;
        _expandedCode = (data['code'] ?? code).toString();
      });
    } on ApiException catch (e) {
      setState(() {
        _errorBusqueda = e.message;
        _loadingBusqueda = false;
      });
    } catch (_) {
      setState(() {
        _errorBusqueda = 'No se pudo consultar.';
        _loadingBusqueda = false;
      });
    }
  }

  String _statusLabel(String? s) {
    const m = {
      'recepcion': 'Recepción',
      'diagnostico': 'Diagnóstico',
      'en_proceso': 'En proceso',
      'listo': 'Listo para entrega',
    };
    return m[s] ?? (s ?? '—');
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

  String _qrPayload(Map<String, dynamic> o) {
    final code = (o['code'] ?? o['id'] ?? '').toString();
    return 'MICEL|$code|${o['device'] ?? ''}|${o['status'] ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _cargar,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seguimiento',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.gray900)),
                        SizedBox(height: 4),
                        Text('Tus equipos en taller — se actualiza solo',
                            style: TextStyle(fontSize: 13, color: AppColors.gray400)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Actualizar',
                    onPressed: _loading ? null : _cargar,
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.gray400),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // ===== LISTA AUTOMÁTICA =====
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                )
              else if (_error != null)
                _box(_error!, isError: true)
              else if (_ordenes.isEmpty)
                _box(
                  'Aún no hay órdenes con tu teléfono.\n'
                  'Cuando dejes un equipo en MiCel, el seguimiento saldrá aquí solo.\n\n'
                  'Teléfono de tu cuenta: ${ClientSession.phone.isEmpty ? "—" : ClientSession.phone}',
                )
              else ...[
                Text(
                  _ordenes.length == 1
                      ? '1 equipo en seguimiento'
                      : '${_ordenes.length} equipos en seguimiento',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.gray400, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                ..._ordenes.map((o) => _ordenCard(o)),
              ],

              const SizedBox(height: 28),

              // Búsqueda manual opcional (colapsada)
              TextButton.icon(
                onPressed: () => setState(() => _mostrarBusquedaManual = !_mostrarBusquedaManual),
                icon: Icon(
                  _mostrarBusquedaManual ? Icons.expand_less : Icons.search_rounded,
                  color: AppColors.gray400,
                  size: 20,
                ),
                label: Text(
                  _mostrarBusquedaManual
                      ? 'Ocultar búsqueda por código'
                      : 'Buscar otro código (opcional)',
                  style: const TextStyle(color: AppColors.gray400, fontSize: 13),
                ),
              ),
              if (_mostrarBusquedaManual) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                      color: AppColors.gray900, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'Ej: OS-0041 — busca al escribir',
                    prefixIcon: Icon(Icons.qr_code_2_rounded),
                  ),
                ),
                if (_loadingBusqueda)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                        child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary))),
                  ),
                if (_errorBusqueda != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_errorBusqueda!,
                        style: const TextStyle(color: Color(0xFFFF8A8A), fontSize: 13)),
                  ),
                if (_busquedaExtra != null) ...[
                  const SizedBox(height: 12),
                  _ordenCard(_busquedaExtra!),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(String text, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
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

  Widget _ordenCard(Map<String, dynamic> o) {
    final code = (o['code'] ?? '').toString();
    final st = o['status']?.toString();
    final expanded = _expandedCode == code;
    final tecnico = o['tecnico'];
    final tecnicoName = tecnico is Map
        ? (tecnico['name'] ?? '').toString()
        : (tecnico?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: expanded ? AppColors.primary.withValues(alpha: 0.45) : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            onTap: () => setState(() => _expandedCode = expanded ? null : code),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.phone_iphone_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(code.isEmpty ? 'Orden' : code,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.primary)),
                        const SizedBox(height: 2),
                        Text('${o['device'] ?? '—'} · ${o['service'] ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(st).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_statusLabel(st),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(st))),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Equipo', '${o['device'] ?? '—'}'),
                  _row('Servicio', '${o['service'] ?? '—'}'),
                  _row('Estado', _statusLabel(st)),
                  if ((o['client'] ?? '').toString().isNotEmpty)
                    _row('Cliente', '${o['client']}'),
                  if (tecnicoName.isNotEmpty) _row('Técnico', tecnicoName),
                  if (o['monto'] != null) _row('Monto', 'Bs ${o['monto']}'),
                  const SizedBox(height: 14),
                  const Text('Código QR',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray800)),
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: QrImageView(
                        data: _qrPayload(o),
                        version: QrVersions.auto,
                        size: 160,
                        gapless: true,
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Código $code copiado'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                      label: Text('Copiar $code',
                          style: const TextStyle(
                              color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90,
              child: Text(k, style: const TextStyle(color: AppColors.gray400, fontSize: 13))),
          Expanded(
              child: Text(v,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900))),
        ],
      ),
    );
  }
}
