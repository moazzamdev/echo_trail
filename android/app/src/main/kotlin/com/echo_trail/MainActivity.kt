// android/app/src/main/kotlin/com/echo_trail/MainActivity.kt
package com.echo_trail

import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.BroadcastReceiver
import android.content.pm.PackageManager
import android.media.RingtoneManager
import android.os.Build
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.appcompat.app.AppCompatActivity
import android.net.Uri
import android.speech.tts.TextToSpeech
import android.telephony.SmsMessage
import java.util.Locale
import com.echo_trail.SmsTtsHandler


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.echo_trail/voice_service"
    private val ALARM_CHANNEL = "com.echo_trail/alarm"
    private var voiceWakeReceiver: BroadcastReceiver? = null
    private var smsTtsHandler: SmsTtsHandler? = null
    private var batteryReceiver: BatteryReceiver? = null



    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Request permissions
        requestPermissions()

        // Initialize SMS and TTS handler
        smsTtsHandler = SmsTtsHandler(this)

        // Voice method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVoiceRecognition" -> startVoiceService("com.echo_trail.START_VOICE_RECOGNITION", result)
                "startCommandListener" -> startVoiceService("com.echo_trail.START_COMMAND_LISTENER", result)
                "stopVoiceRecognition" -> startVoiceService("com.echo_trail.STOP_VOICE_RECOGNITION", result)
                "readMessage" -> {
                    val message = call.argument<String>("message") ?: ""
                    smsTtsHandler?.readMessage(message)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Alarm method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ALARM_CHANNEL).setMethodCallHandler { call, result ->
            val sharedPref = getSharedPreferences("echo_prefs", Context.MODE_PRIVATE)
            when (call.method) {
                "setAlarm" -> {
                    val hour = call.argument<Int>("hour") ?: 0
                    val minute = call.argument<Int>("minute") ?: 0
                    val isNew = call.argument<Boolean>("new") ?: false
                    val success = AlarmHelper.setAlarm(this, hour, minute, isNew)
                    if (success) {
                        Toast.makeText(applicationContext, "Alarm set for $hour:${minute.toString().padStart(2, '0')}", Toast.LENGTH_SHORT).show()
                        result.success(true)
                    } else {
                        result.error("ALARM_ERROR", "Failed to set alarm", null)
                    }
                }
                "showToast" -> {
                    val message = call.argument<String>("message") ?: "Notification"
                    Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
                    result.success(true)
                }
                "deleteAlarm" -> {
                    AlarmHelper.cancelAlarm(this)
                    result.success(true)
                }
                "snoozeAlarm" -> {
                    val minutes = call.argument<Int>("minutes") ?: 5
                    AlarmHelper.snoozeAlarm(this, minutes)
                    result.success(true)
                }
                "dismissAlarm" -> {
                    AlarmHelper.dismissAlarm(this)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Battery threshold channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.echo_trail/battery")
            .setMethodCallHandler { call, result ->
                val sharedPref = getSharedPreferences("echo_prefs", Context.MODE_PRIVATE)
                when (call.method) {
                    "setThreshold" -> {
                        val threshold = call.argument<Int>("threshold")
                        if (threshold != null) {
                            sharedPref.edit().putInt("battery_threshold", threshold).apply()
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGUMENT", "Missing or invalid threshold", null)
                        }
                    }
                    "getThreshold" -> {
                        val threshold = sharedPref.getInt("battery_threshold", -1)
                        result.success(threshold)
                    }
                    else -> result.notImplemented()
                }
            }

        // Register battery receiver
        batteryReceiver = BatteryReceiver()
        registerReceiver(batteryReceiver, IntentFilter(Intent.ACTION_BATTERY_CHANGED))

        // Wake word event stream
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.echo_trail/voice_stream")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                voiceWakeReceiver = object : BroadcastReceiver() {
                    private var lastTriggerTime = 0L

                    override fun onReceive(context: Context?, intent: Intent?) {
                        val currentTime = System.currentTimeMillis()
                        if (currentTime - lastTriggerTime > 1000) {
                            lastTriggerTime = currentTime
                            val message = intent?.getStringExtra("text") ?: ""
                            events?.success(message)
                        }
                    }
                }
                val filter = IntentFilter("com.echo_trail.WAKE_WORD")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(voiceWakeReceiver, filter, RECEIVER_NOT_EXPORTED)
                } else {
                    registerReceiver(voiceWakeReceiver, filter)
                }
            }

            override fun onCancel(arguments: Any?) {
                voiceWakeReceiver?.let {
                    unregisterReceiver(it)
                    voiceWakeReceiver = null
                }
            }
        })

        createNotificationChannel()
    }

    private fun requestPermissions() {
        val permissions = listOf(
            android.Manifest.permission.RECORD_AUDIO,
            android.Manifest.permission.SCHEDULE_EXACT_ALARM,
            android.Manifest.permission.RECEIVE_SMS,
            android.Manifest.permission.READ_CONTACTS
        )
        permissions.forEachIndexed { index, perm ->
            if (ContextCompat.checkSelfPermission(this, perm) != PackageManager.PERMISSION_GRANTED) {
                ActivityCompat.requestPermissions(this, arrayOf(perm), 100 + index)
            }
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode in 100..103) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                Toast.makeText(this, "All required permissions granted", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "Some permissions denied", Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun startVoiceService(action: String, result: MethodChannel.Result) {
        try {
            val intent = Intent(this, VoiceRecognitionService::class.java).apply {
                this.action = action
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.error("VOICE_ERROR", "Failed to start service: ${e.message}", null)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

            val alarmChannel = NotificationChannel(
                "alarm_channel",
                "Alarm Notifications",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Channel for alarm notifications"
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 500, 200, 500, 200, 500)
                setSound(
                    Uri.parse("android.resource://${packageName}/${R.raw.alarm_sound}"),
                    android.media.AudioAttributes.Builder()
                        .setUsage(android.media.AudioAttributes.USAGE_ALARM)
                        .setContentType(android.media.AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .build()
                )
                setBypassDnd(true)
                enableLights(true)
            }

            val dismissChannel = NotificationChannel(
                "alarm_dismiss_channel",
                "Alarm Dismiss Channel",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Used when dismissing an alarm"
                setSound(null, null)
                enableVibration(false)
            }

            manager.createNotificationChannel(alarmChannel)
            manager.createNotificationChannel(dismissChannel)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        voiceWakeReceiver?.let {
            unregisterReceiver(it)
            voiceWakeReceiver = null
        }
        batteryReceiver?.let {
            unregisterReceiver(it)
            batteryReceiver = null
        }
        smsTtsHandler?.stop()
        smsTtsHandler = null
    }
}