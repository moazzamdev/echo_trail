// BatteryReceiver.kt
package com.echo_trail

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.media.ToneGenerator
import android.os.BatteryManager
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.widget.Toast

class BatteryReceiver : BroadcastReceiver() {
    companion object {
        private var isWarningActive = false
        private var lastWarningTime = 0L
        private var warningHandler: Handler? = null
        private var warningRunnable: Runnable? = null
        private var toneGenerator: ToneGenerator? = null
        private const val WARNING_DURATION = 15000L // 15 seconds
        private const val WARNING_INTERVAL = 15 * 60 * 1000L // 15 minutes
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BATTERY_CHANGED) {
            val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
            val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
            val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)

            if (level != -1 && scale != -1) {
                val batteryPercentage = (level * 100) / scale
                val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                        status == BatteryManager.BATTERY_STATUS_FULL

                // Get stored threshold
                val sharedPref = context.getSharedPreferences("echo_prefs", Context.MODE_PRIVATE)
                val threshold = sharedPref.getInt("battery_threshold", -1)

                Log.d("BatteryReceiver", "Battery: $batteryPercentage%, Threshold: $threshold%, Charging: $isCharging")

                if (threshold > 0 && batteryPercentage <= threshold && !isCharging) {
                    handleLowBatteryWarning(context, batteryPercentage)
                } else if (isCharging && isWarningActive) {
                    // Stop warning if phone starts charging
                    stopWarning()
                    Toast.makeText(context, "Charging detected - Battery warning stopped", Toast.LENGTH_SHORT).show()
                }
            }
        }
    }

    private fun handleLowBatteryWarning(context: Context, batteryLevel: Int) {
        val currentTime = System.currentTimeMillis()

        // Check if we should trigger a new warning
        if (!isWarningActive && (lastWarningTime == 0L || currentTime - lastWarningTime >= WARNING_INTERVAL)) {
            startWarning(context, batteryLevel)
        }
    }

    private fun startWarning(context: Context, batteryLevel: Int) {
        Log.d("BatteryReceiver", "Starting battery warning for $batteryLevel%")

        isWarningActive = true
        lastWarningTime = System.currentTimeMillis()

        // Initialize tone generator for alarm sound
        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_ALARM, 100)
        } catch (e: Exception) {
            Log.e("BatteryReceiver", "Failed to initialize ToneGenerator: ${e.message}")
        }

        // Show toast
        Toast.makeText(context, "Low Battery Warning: $batteryLevel% - Please charge your device!", Toast.LENGTH_LONG).show()

        // Start repeating alarm sound
        warningHandler = Handler(Looper.getMainLooper())
        warningRunnable = object : Runnable {
            override fun run() {
                if (isWarningActive) {
                    try {
                        // Play alarm tone (beep)
                        toneGenerator?.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 500)

                        // Schedule next beep in 1 second
                        warningHandler?.postDelayed(this, 1000)
                    } catch (e: Exception) {
                        Log.e("BatteryReceiver", "Error playing alarm tone: ${e.message}")
                    }
                }
            }
        }

        // Start the warning sound
        warningRunnable?.let { warningHandler?.post(it) }

        // Stop warning after 15 seconds
        warningHandler?.postDelayed({
            stopWarning()
            Log.d("BatteryReceiver", "Battery warning stopped after 15 seconds")
        }, WARNING_DURATION)
    }

    private fun stopWarning() {
        isWarningActive = false
        warningHandler?.removeCallbacksAndMessages(null)
        warningHandler = null
        warningRunnable = null

        try {
            toneGenerator?.release()
            toneGenerator = null
        } catch (e: Exception) {
            Log.e("BatteryReceiver", "Error releasing ToneGenerator: ${e.message}")
        }
    }

    // Method to manually stop warning (can be called from MainActivity if needed)
    fun forceStopWarning() {
        stopWarning()
    }
}