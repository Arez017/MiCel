package com.cuotalock.bloqueo

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val canal = "cuotalock/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "init" -> {
                            Policy.ensureSetup(this)
                            result.success(null)
                        }
                        "status" -> {
                            Policy.evaluar(this, false)
                            result.success(Policy.status(this))
                        }
                        "setDue" -> {
                            val millis = (call.argument<Number>("millis") ?: 0).toLong()
                            Policy.setDue(this, millis)
                            result.success(null)
                        }
                        "submitCode" -> {
                            val r = Policy.submitCode(this, call.argument<String>("code") ?: "")
                            result.success(mapOf("ok" to r.first, "message" to r.second))
                        }
                        "enterLock" -> {
                            try { startLockTask() } catch (_: Exception) {}
                            result.success(null)
                        }
                        "exitLock" -> {
                            try { stopLockTask() } catch (_: Exception) {}
                            result.success(null)
                        }
                        "dial" -> {
                            val numero = call.argument<String>("number")
                            val uri = if (numero.isNullOrBlank()) Uri.parse("tel:")
                                      else Uri.fromParts("tel", numero, null)
                            startActivity(Intent(Intent.ACTION_DIAL, uri))
                            result.success(null)
                        }
                        "release" -> {
                            Policy.release(this)
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("ERR", e.message, null)
                }
            }
    }
}
