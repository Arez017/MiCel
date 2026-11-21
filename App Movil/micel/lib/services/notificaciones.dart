import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'api_service.dart';

/// Con la app cerrada o en segundo plano, Android muestra la notificación solo
/// (viene con título y texto). Esta función solo deja Firebase listo.
@pragma('vm:entry-point')
Future<void> _mensajeEnSegundoPlano(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Notificaciones push de la app MiCel (Firebase Cloud Messaging).
///
/// Si el proyecto no tiene `android/app/google-services.json`, Firebase no
/// arranca y la app funciona igual que antes, solo que sin notificaciones.
class Notificaciones {
  Notificaciones._();

  static bool _disponible = false;
  static StreamSubscription<String>? _renovacion;

  /// Para mostrar el aviso dentro de la app cuando llega con la app abierta.
  static final GlobalKey<ScaffoldMessengerState> mensajero =
      GlobalKey<ScaffoldMessengerState>();

  static bool get disponible => _disponible;

  /// Llamar una vez al arrancar, antes de `runApp`.
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_mensajeEnSegundoPlano);
      FirebaseMessaging.onMessage.listen(_avisoConAppAbierta);
      _disponible = true;
    } catch (e) {
      debugPrint('Notificaciones desactivadas (falta configurar Firebase): $e');
    }
  }

  /// Pide permiso y registra este celular en el servidor. Llamar tras iniciar
  /// sesión y al abrir la app con una sesión guardada.
  static Future<void> activarParaSesion() async {
    if (!_disponible) return;
    try {
      final fm = FirebaseMessaging.instance;
      await fm.requestPermission();
      final token = await fm.getToken();
      if (token != null) {
        await ApiService.registrarTokenNotificaciones(token);
      }
      _renovacion ??= fm.onTokenRefresh.listen((nuevo) {
        ApiService.registrarTokenNotificaciones(nuevo).catchError((_) {});
      });
    } catch (e) {
      debugPrint('No se pudo activar las notificaciones: $e');
    }
  }

  /// Al cerrar sesión: este celular deja de recibir avisos de esa cuenta.
  static Future<void> desactivar() async {
    await _renovacion?.cancel();
    _renovacion = null;
    if (!_disponible) return;
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }

  static void _avisoConAppAbierta(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;
    mensajero.currentState?.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title ?? 'MiCel',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  if ((n.body ?? '').isNotEmpty) Text(n.body!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
