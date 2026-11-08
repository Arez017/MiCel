package com.cuotalock.bloqueo

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/** Se activa cuando la app pasa a ser Device Owner (dpm set-device-owner). */
class AdminReceiver : DeviceAdminReceiver() {
    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Policy.ensureSetup(context)
    }
}
