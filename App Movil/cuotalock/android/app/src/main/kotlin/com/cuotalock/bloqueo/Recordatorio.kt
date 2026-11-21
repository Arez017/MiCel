package com.cuotalock.bloqueo

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

/**
 * Recordatorio de cuota sin internet: avisa "vence en 3 días" y "vence mañana"
 * antes de que el equipo se bloquee. Lo llama la misma revisión periódica que
 * controla el vencimiento (alarma de ~15 min, reinicio, cambio de hora o al abrir
 * la app). Cada aviso sale una sola vez por cada fecha de vencimiento.
 */
object Recordatorio {

    const val CANAL = "cuotalock_recordatorios"
    const val HORA_AVISO = 9 // desde las 9:00, para no avisar de madrugada

    private const val PREFS = "cuotalock"
    private const val KEY_DUE_AVISADO = "aviso_vencimiento"
    private const val KEY_NIVEL = "aviso_nivel"
    private const val ID_NOTIFICACION = 4201

    const val NINGUNO = 0
    const val POCOS_DIAS = 3 // "vence en 3 días" (o 2, si el celular estuvo apagado ese día)
    const val MANANA = 1     // "vence mañana"

    /**
     * Qué aviso corresponde ahora.
     * @param diasRestantes días de calendario hasta el vencimiento (1 = mañana)
     * @param hora hora local (0-23)
     * @param yaAvisado el aviso que ya se mostró para este vencimiento
     */
    fun avisoQueCorresponde(diasRestantes: Long, hora: Int, yaAvisado: Int): Int {
        if (hora < HORA_AVISO) return NINGUNO
        return when {
            diasRestantes == 1L && yaAvisado != MANANA -> MANANA
            diasRestantes in 2L..3L && yaAvisado == NINGUNO -> POCOS_DIAS
            else -> NINGUNO
        }
    }

    fun textos(diasRestantes: Long, fecha: String): Pair<String, String> =
        if (diasRestantes == 1L) {
            "Tu cuota vence mañana" to
                "Vence el $fecha. Paga en MiCel para que tu celular siga funcionando sin interrupciones."
        } else {
            "Tu cuota vence en $diasRestantes días" to
                "Vence el $fecha. Paga a tiempo en MiCel para que tu celular no se bloquee."
        }

    /** Revisa y, si toca, muestra el aviso. `due` = vencimiento en milisegundos. */
    fun revisar(c: Context, due: Long, ahora: Long = System.currentTimeMillis()) {
        if (due <= 0L || ahora >= due) return
        val p = c.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        val yaAvisado = if (p.getLong(KEY_DUE_AVISADO, 0L) == due) p.getInt(KEY_NIVEL, NINGUNO) else NINGUNO
        val dias = Policy.daysOf(due) - Policy.daysOf(ahora)
        val hora = Calendar.getInstance().apply { timeInMillis = ahora }.get(Calendar.HOUR_OF_DAY)

        val aviso = avisoQueCorresponde(dias, hora, yaAvisado)
        if (aviso == NINGUNO) return

        val (titulo, texto) = textos(dias, Policy.fecha(due))
        if (mostrar(c, titulo, texto)) {
            p.edit().putLong(KEY_DUE_AVISADO, due).putInt(KEY_NIVEL, aviso).apply()
        }
    }

    private fun mostrar(c: Context, titulo: String, texto: String): Boolean = try {
        val nm = c.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            nm.createNotificationChannel(
                NotificationChannel(CANAL, "Recordatorio de cuotas", NotificationManager.IMPORTANCE_HIGH)
                    .apply { description = "Avisa antes de que venza tu cuota" }
            )
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
            (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        val abrir = PendingIntent.getActivity(
            c, 2, Intent(c, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK), flags
        )
        @Suppress("DEPRECATION")
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(c, CANAL)
        } else {
            Notification.Builder(c).setPriority(Notification.PRIORITY_HIGH)
        }
        val notificacion = builder
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle(titulo)
            .setContentText(texto)
            .setStyle(Notification.BigTextStyle().bigText(texto))
            .setContentIntent(abrir)
            .setAutoCancel(true)
            .build()
        nm.notify(ID_NOTIFICACION, notificacion)
        true
    } catch (_: Exception) {
        false
    }
}
