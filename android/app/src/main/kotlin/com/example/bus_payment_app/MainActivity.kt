package com.example.bus_payment_app

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.bus_payment_app/deviceinfo"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "getDeviceName") {
                // 🔧 ลองดึงชื่อเครื่อง ถ้า null ให้ fallback เป็น Build.MODEL
                val deviceName = Settings.Global.getString(contentResolver, "device_name")
                    ?: Build.MODEL
                result.success(deviceName)
            } else {
                result.notImplemented()
            }
        }
    }
}
