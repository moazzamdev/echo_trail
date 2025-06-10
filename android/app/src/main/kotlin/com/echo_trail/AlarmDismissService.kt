// AlarmDismissService.kt
package com.echo_trail

import android.app.Service
import android.content.Intent
import android.media.MediaPlayer
import android.os.IBinder
import android.os.Vibrator
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmDismissService : Service() {
    companion object {
        var mediaPlayer: MediaPlayer? = null
        var vibrator: Vibrator? = null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("AlarmDismissService", "Stopping alarm sound and vibration")

        // Start as foreground
        val channelId = "alarm_dismiss_channel"
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("Alarm Dismissing")
            .setContentText("Stopping alarm sound...")
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .build()
        startForeground(201, notification) // Mandatory within 5s

        try {
            mediaPlayer?.let {
                if (it.isPlaying) it.stop()
                it.release()
                mediaPlayer = null
            }
            vibrator?.cancel()
            vibrator = null
        } catch (e: Exception) {
            Log.e("AlarmDismissService", "Error stopping alarm", e)
        }

        stopSelf()
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?) = null
}

