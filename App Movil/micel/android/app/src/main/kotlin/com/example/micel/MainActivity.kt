package com.example.micel

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        crearCanalDeNotificaciones()
    }

    /** Canal "micel_ordenes": el servidor lo usa para el aviso de equipo listo. */
    private fun crearCanalDeNotificaciones() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val canal = NotificationChannel(
            "micel_ordenes",
            "Estado de tus reparaciones",
            NotificationManager.IMPORTANCE_HIGH,
        ).apply { description = "Avisos cuando tu equipo está listo para recoger" }
        getSystemService(NotificationManager::class.java).createNotificationChannel(canal)
    }
}
