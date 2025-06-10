package com.echo_trail

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.net.Uri
import android.os.Vibrator
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val channelId = "alarm_channel"

        // Dismiss and Snooze actions
        val dismissIntent = Intent("com.echo_trail.ACTION_DISMISS").setClass(context, NotificationActionReceiver::class.java)
        val snoozeIntent = Intent("com.echo_trail.ACTION_SNOOZE").setClass(context, NotificationActionReceiver::class.java)

        val dismissPendingIntent = PendingIntent.getBroadcast(
            context, 0, dismissIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context, 1, snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Play sound and vibrate
        val customSoundUri: Uri = Uri.parse("android.resource://${context.packageName}/${R.raw.alarm_sound}")
        if (AlarmDismissService.mediaPlayer?.isPlaying != true) {
            AlarmDismissService.mediaPlayer = MediaPlayer.create(context, customSoundUri).apply {
                isLooping = true
                start()
            }
        }

        AlarmDismissService.vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        AlarmDismissService.vibrator?.vibrate(longArrayOf(0, 500, 200, 500, 200, 500), 0)

        // Notification without full-screen intent
        val notification = NotificationCompat.Builder(context, channelId)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("⏰ Alarm!")
            .setContentText("Tap to dismiss or snooze.")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVibrate(longArrayOf(0, 500, 200, 500, 200, 500))
            .setSound(customSoundUri)
            .setAutoCancel(true)
            .addAction(android.R.drawable.ic_delete, "Dismiss", dismissPendingIntent)
            .addAction(android.R.drawable.ic_lock_idle_alarm, "Snooze", snoozePendingIntent)
            .build()

        NotificationManagerCompat.from(context).notify(101, notification)

        Log.d("AlarmReceiver", "✅ Alarm triggered and notification shown")
    }
}
