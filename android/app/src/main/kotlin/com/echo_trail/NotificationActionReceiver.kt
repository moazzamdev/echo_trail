// NotificationActionReceiver.kt

package com.echo_trail

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import androidx.core.app.NotificationManagerCompat

class NotificationActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val notificationManager = NotificationManagerCompat.from(context)
        when (intent?.action) {
            "com.echo_trail.ACTION_DISMISS" -> {
                Log.d("NotificationAction", "🛑 Dismiss tapped")
                try {
                    AlarmHelper.dismissAlarm(context)
                    notificationManager.cancel(101)
                } catch (e: Exception) {
                    Log.e("NotificationAction", "Error dismissing alarm", e)
                }
            }
            "com.echo_trail.ACTION_SNOOZE" -> {
                Log.d("NotificationAction", "😴 Snooze tapped")
                try {
                    AlarmHelper.snoozeAlarm(context)
                    notificationManager.cancel(101)
                } catch (e: Exception) {
                    Log.e("NotificationAction", "Error snoozing alarm", e)
                }
            }
            else -> Log.d("NotificationAction", "❓ Unknown action")
        }
    }
}