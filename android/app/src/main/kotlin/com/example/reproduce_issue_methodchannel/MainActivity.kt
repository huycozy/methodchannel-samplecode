package com.example.reproduce_issue_methodchannel

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Point
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.util.DisplayMetrics
import android.view.Display
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.pow
import kotlin.math.sqrt


class MainActivity: FlutterActivity() {
    private val CHANNEL = "samples.flutter.dev/battery"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            if (call.method == "getBatteryLevel") {
                val batteryLevel = getBatteryLevel()

                if (batteryLevel != -1) {
                    result.success(batteryLevel)
                } else {
                    result.error("UNAVAILABLE", "Battery level not available.", null)
                }
            } else if (call.method == "getDeviceScreenSizeInInch")  {
                result.success(getDeviceScreenSizeInInch(this@MainActivity))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            batteryLevel = intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }

        return batteryLevel
    }

    private fun getDeviceScreenSizeInInch(activity: Activity): Double {
        val windowManager = activity.windowManager
        val display = windowManager.defaultDisplay
        val displayMetrics = DisplayMetrics()
        display.getMetrics(displayMetrics)

        var mWidthPixels = displayMetrics.widthPixels
        var mHeightPixels = displayMetrics.heightPixels

        if (VERSION.SDK_INT in 14..16) {
            try {
                mWidthPixels = Display::class.java.getMethod("getRawWidth").invoke(display) as Int
                mHeightPixels = Display::class.java.getMethod("getRawHeight").invoke(display) as Int
            } catch (ignored: Exception) {
            }
        }

        if (VERSION.SDK_INT >= 17) {
            try {
                val realSize = Point()
                Display::class.java.getMethod("getRealSize", Point::class.java)
                    .invoke(display, realSize)
                mWidthPixels = realSize.x
                mHeightPixels = realSize.y
            } catch (ignored: Exception) {
            }
        }
        val dm = DisplayMetrics()
        activity.windowManager.defaultDisplay.getMetrics(dm)
        val x = (mWidthPixels / dm.xdpi).toDouble().pow(2.0)
        val y = (mHeightPixels / dm.ydpi).toDouble().pow(2.0)
        return sqrt(x + y)
    }
}
