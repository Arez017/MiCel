package com.cuotalock.bloqueo

import android.app.AlarmManager
import android.app.PendingIntent
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.PackageManager
import android.os.Build
import android.os.UserManager
import android.provider.Settings
import android.telecom.TelecomManager
import java.security.MessageDigest
import java.util.Calendar
import java.util.TimeZone
import java.util.concurrent.TimeUnit
import javax.crypto.Mac
import javax.crypto.spec.SecretKeySpec

/**
 * Toda la lógica de bloqueo vive aquí.
 *
 * Esquema de códigos (offline):
 *   código = DDDDD-MMMMMM
 *   DDDDD  = nuevo vencimiento, en días desde 1970-01-01 (fecha local)
 *   MMMMMM = 6 dígitos de HMAC-SHA256(SECRET, "<ID_EQUIPO>:<DDDDD>")
 *   DDDDD = 99999 -> cuotas liquidadas: libera el equipo
 */
object Policy {

    // ===================== CONFIGURACIÓN =====================
    // Debe ser IDÉNTICA a la de herramientas/generar_codigo.py y a la de Laravel.
    // Prototipo: la clave va dentro del APK. Ver "Limitaciones" en la guía.
    private const val SECRET = "CAMBIA-ESTA-CLAVE-SECRETA"
    // =========================================================

    const val ACTION_CHECK = "com.cuotalock.bloqueo.CHECK"

    private const val PREFS = "cuotalock"
    private const val KEY_DUE = "due_millis"
    private const val KEY_LOCKED = "locked"
    private const val DAY_MS = 86_400_000L
    private const val FOREVER = 99_999L

    // ---------- Acceso básico ----------

    private fun prefs(c: Context): SharedPreferences =
        c.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    private fun dpm(c: Context): DevicePolicyManager =
        c.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager

    private fun admin(c: Context) = ComponentName(c, AdminReceiver::class.java)

    private fun homeAlias(c: Context) = ComponentName(c.packageName, "${c.packageName}.LockHome")

    fun isOwner(c: Context): Boolean = dpm(c).isDeviceOwnerApp(c.packageName)

    private fun dueMillis(c: Context): Long = prefs(c).getLong(KEY_DUE, 0L)

    private fun isLocked(c: Context): Boolean = prefs(c).getBoolean(KEY_LOCKED, false)

    /** ID corto que el cliente le dicta al vendedor (8 caracteres). */
    private fun deviceId(c: Context): String {
        val raw = Settings.Secure.getString(c.contentResolver, Settings.Secure.ANDROID_ID) ?: "00000000"
        return raw.uppercase().padStart(8, '0').takeLast(8)
    }

    fun status(c: Context): Map<String, Any> = mapOf(
        "owner" to isOwner(c),
        "locked" to isLocked(c),
        "due" to dueMillis(c),
        "deviceId" to deviceId(c)
    )

    // ---------- Configuración inicial como Device Owner ----------

    @Suppress("DEPRECATION")
    fun ensureSetup(c: Context) {
        if (!isOwner(c)) return
        val d = dpm(c)
        val a = admin(c)

        // La app no se puede desinstalar
        d.setUninstallBlocked(a, c.packageName, true)

        // Restricciones
        val r = mutableListOf(UserManager.DISALLOW_FACTORY_RESET, UserManager.DISALLOW_ADD_USER)
        if (Build.VERSION.SDK_INT >= 23) r.add(UserManager.DISALLOW_SAFE_BOOT)
        if (Build.VERSION.SDK_INT >= 28) r.add(UserManager.DISALLOW_CONFIG_DATE_TIME)
        for (x in r) d.addUserRestriction(a, x)

        // Hora automática + no forzar detención / borrar datos de la app
        if (Build.VERSION.SDK_INT >= 30) {
            d.setAutoTimeEnabled(a, true)
            d.setUserControlDisabledPackages(a, listOf(c.packageName))
        } else if (Build.VERSION.SDK_INT >= 23) {
            d.setAutoTimeRequired(a, true)
        }
        schedule(c)
    }

    private fun removeRestrictions(c: Context) {
        val d = dpm(c)
        val a = admin(c)
        val r = mutableListOf(UserManager.DISALLOW_FACTORY_RESET, UserManager.DISALLOW_ADD_USER)
        if (Build.VERSION.SDK_INT >= 23) r.add(UserManager.DISALLOW_SAFE_BOOT)
        if (Build.VERSION.SDK_INT >= 28) r.add(UserManager.DISALLOW_CONFIG_DATE_TIME)
        for (x in r) d.clearUserRestriction(a, x)
        d.setUninstallBlocked(a, c.packageName, false)
        if (Build.VERSION.SDK_INT >= 30) d.setUserControlDisabledPackages(a, emptyList())
    }

    // ---------- Evaluación: ¿venció la cuota? ----------

    fun evaluar(c: Context, reforzar: Boolean) {
        if (!isOwner(c)) return
        val due = dueMillis(c)
        val vencida = due > 0 && System.currentTimeMillis() >= due
        if (vencida) {
            val primera = !isLocked(c)
            if (primera || reforzar) bloquear(c, primera)
        } else if (isLocked(c)) {
            desbloquear(c)
        }
    }

    fun setDue(c: Context, millis: Long) {
        prefs(c).edit().putLong(KEY_DUE, millis).apply()
        evaluar(c, false)
        schedule(c)
    }

    private fun bloquear(c: Context, primera: Boolean) {
        prefs(c).edit().putBoolean(KEY_LOCKED, true).apply()
        val d = dpm(c)
        val a = admin(c)

        // Apps permitidas dentro del bloqueo: la nuestra + el marcador (llamadas de emergencia)
        val paquetes = mutableListOf(c.packageName)
        dialerPackage(c)?.let { paquetes.add(it) }
        d.setLockTaskPackages(a, paquetes.toTypedArray())
        if (Build.VERSION.SDK_INT >= 28) d.setLockTaskFeatures(a, 0) // sin barra, home, recientes ni menú de apagado

        // Mientras esté bloqueado, nuestra app es el launcher (sobrevive reinicios)
        c.packageManager.setComponentEnabledSetting(
            homeAlias(c), PackageManager.COMPONENT_ENABLED_STATE_ENABLED, PackageManager.DONT_KILL_APP
        )
        val filtro = IntentFilter(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            addCategory(Intent.CATEGORY_DEFAULT)
        }
        d.addPersistentPreferredActivity(a, filtro, homeAlias(c))

        if (primera) {
            try { d.lockNow() } catch (_: Exception) {}
        }
        try {
            c.startActivity(
                Intent(c, MainActivity::class.java)
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
            )
        } catch (_: Exception) {}
    }

    private fun desbloquear(c: Context) {
        prefs(c).edit().putBoolean(KEY_LOCKED, false).apply()
        val d = dpm(c)
        val a = admin(c)
        d.clearPackagePersistentPreferredActivities(a, c.packageName)
        c.packageManager.setComponentEnabledSetting(
            homeAlias(c), PackageManager.COMPONENT_ENABLED_STATE_DISABLED, PackageManager.DONT_KILL_APP
        )
        d.setLockTaskPackages(a, arrayOf())
    }

    private fun dialerPackage(c: Context): String? {
        if (Build.VERSION.SDK_INT >= 23) {
            val tm = c.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val p: String? = tm.defaultDialerPackage
            if (p != null) return p
        }
        val ri = c.packageManager.resolveActivity(Intent(Intent.ACTION_DIAL), PackageManager.MATCH_DEFAULT_ONLY)
        return ri?.activityInfo?.packageName
    }

    // ---------- Liberar el equipo (cuotas liquidadas o salida de pruebas) ----------

    fun release(c: Context) {
        if (!isOwner(c)) return
        if (isLocked(c)) desbloquear(c)
        removeRestrictions(c)
        cancelAlarm(c)
        prefs(c).edit().clear().apply()
        dpm(c).clearDeviceOwnerApp(c.packageName)
    }

    // ---------- Códigos de pago / desbloqueo ----------

    private fun mac(deviceId: String, days: Long): String {
        val m = Mac.getInstance("HmacSHA256")
        m.init(SecretKeySpec(SECRET.toByteArray(Charsets.UTF_8), "HmacSHA256"))
        val h = m.doFinal("$deviceId:$days".toByteArray(Charsets.UTF_8))
        val n = ((h[0].toInt() and 0x7f) shl 24) or
                ((h[1].toInt() and 0xff) shl 16) or
                ((h[2].toInt() and 0xff) shl 8) or
                (h[3].toInt() and 0xff)
        return (n % 1_000_000).toString().padStart(6, '0')
    }

    fun submitCode(c: Context, raw: String): Pair<Boolean, String> {
        if (!isOwner(c)) return Pair(false, "El equipo no está configurado.")
        val partes = raw.trim().split("-")
        if (partes.size != 2) return Pair(false, "Formato inválido. Ejemplo: 20800-123456")
        val days = partes[0].toLongOrNull() ?: return Pair(false, "Formato inválido.")

        val esperado = mac(deviceId(c), days)
        if (!MessageDigest.isEqual(esperado.toByteArray(), partes[1].toByteArray())) {
            return Pair(false, "Código incorrecto para este equipo.")
        }

        if (days == FOREVER) {
            release(c)
            return Pair(true, "Cuotas liquidadas. El equipo fue liberado.")
        }

        val hoy = daysOf(System.currentTimeMillis())
        val vencimientoActual = if (dueMillis(c) > 0) daysOf(dueMillis(c)) else -1L
        if (days <= vencimientoActual) return Pair(false, "Este código ya fue usado o está vencido.")
        if (days < hoy) return Pair(false, "El código corresponde a una fecha pasada.")
        if (days > hoy + 400) return Pair(false, "Código fuera de rango.")

        val nuevo = endOfDayMillis(days)
        setDue(c, nuevo)
        return Pair(true, "Pago registrado. Nuevo vencimiento: ${fecha(nuevo)}")
    }

    // ---------- Fechas (calendario local) ----------

    private fun daysOf(millis: Long): Long {
        val local = Calendar.getInstance().apply { timeInMillis = millis }
        val utc = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
        utc.clear()
        utc.set(local.get(Calendar.YEAR), local.get(Calendar.MONTH), local.get(Calendar.DAY_OF_MONTH))
        return utc.timeInMillis / DAY_MS
    }

    private fun endOfDayMillis(days: Long): Long {
        val utc = Calendar.getInstance(TimeZone.getTimeZone("UTC"))
        utc.timeInMillis = days * DAY_MS
        val local = Calendar.getInstance()
        local.clear()
        local.set(
            utc.get(Calendar.YEAR), utc.get(Calendar.MONTH), utc.get(Calendar.DAY_OF_MONTH), 23, 59, 59
        )
        return local.timeInMillis
    }

    private fun fecha(millis: Long): String {
        val cal = Calendar.getInstance().apply { timeInMillis = millis }
        return String.format(
            "%02d/%02d/%04d",
            cal.get(Calendar.DAY_OF_MONTH), cal.get(Calendar.MONTH) + 1, cal.get(Calendar.YEAR)
        )
    }

    // ---------- Alarma de respaldo (revisa cada ~15 min o al vencimiento) ----------

    private fun alarmIntent(c: Context): PendingIntent {
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                (if (Build.VERSION.SDK_INT >= 23) PendingIntent.FLAG_IMMUTABLE else 0)
        val i = Intent(c, EventReceiver::class.java).setAction(ACTION_CHECK)
        return PendingIntent.getBroadcast(c, 1, i, flags)
    }

    fun schedule(c: Context) {
        val am = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val ahora = System.currentTimeMillis()
        val due = dueMillis(c)
        var proxima = ahora + TimeUnit.MINUTES.toMillis(15)
        if (due > ahora && due < proxima) proxima = due
        if (Build.VERSION.SDK_INT >= 23) {
            am.setAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, proxima, alarmIntent(c))
        } else {
            am.set(AlarmManager.RTC_WAKEUP, proxima, alarmIntent(c))
        }
    }

    private fun cancelAlarm(c: Context) {
        (c.getSystemService(Context.ALARM_SERVICE) as AlarmManager).cancel(alarmIntent(c))
    }
}
