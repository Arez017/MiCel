package com.cuotalock.bloqueo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Se ejecuta con: alarma periódica, reinicio del equipo, cambio de hora
 * y actualización de la app. Revisa si la cuota venció y reprograma la alarma.
 */
class EventReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (!Policy.isOwner(context)) return
        val reforzar = intent.action != Policy.ACTION_CHECK
        if (reforzar) Policy.ensureSetup(context)
        Policy.evaluar(context, reforzar)
        Policy.schedule(context)
    }
}
