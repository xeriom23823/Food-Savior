package com.example.food_savior

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import androidx.multidex.MultiDex
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    override fun attachBaseContext(base: Context) {
        super.attachBaseContext(base)
        MultiDex.install(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // 相機權限被永久拒絕後，只有系統設定能改回來（einvoice-import 規格）。
        // 為此引入 permission_handler 之類的套件並不划算，一個 channel 就夠。
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_SETTINGS_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "openAppSettings") {
                    val intent = Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", packageName, null)
                    ).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(true)
                } else {
                    result.notImplemented()
                }
            }
    }

    private companion object {
        const val APP_SETTINGS_CHANNEL = "food_savior/app_settings"
    }
}
