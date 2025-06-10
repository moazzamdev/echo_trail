// AlarmSoundManager.kt

package com.echo_trail

import android.content.Context
import android.media.MediaPlayer
import android.net.Uri
import android.util.Log

object AlarmSoundManager {
    private var mediaPlayer: MediaPlayer? = null

    fun setMediaPlayer(player: MediaPlayer?) {
        mediaPlayer = player
        Log.d("AlarmSoundManager", "Media player set: ${player != null}")
    }

    fun playAlarmSound(context: Context?, alarmUri: Uri? = null) {
        if (context == null) {
            Log.e("AlarmSoundManager", "Context is null")
            return
        }

        stopAlarmSound()

        try {
            mediaPlayer = if (alarmUri != null) {
                MediaPlayer.create(context, alarmUri)
            } else {
                MediaPlayer.create(context, R.raw.alarm_sound)
            }

            mediaPlayer?.let { mp ->
                mp.isLooping = true
                mp.start()
                Log.d("AlarmSoundManager", "🔊 Alarm sound started")
            } ?: run {
                Log.e("AlarmSoundManager", "Failed to create MediaPlayer")
            }
        } catch (e: Exception) {
            Log.e("AlarmSoundManager", "Failed to start alarm sound", e)
            mediaPlayer?.release()
            mediaPlayer = null
        }
    }

    fun stopAlarmSound() {
        mediaPlayer?.let { mp ->
            try {
                if (mp.isPlaying) {
                    mp.stop()
                }
                mp.reset() // Reset before release to avoid IllegalStateException
                mp.release()
                Log.d("AlarmSoundManager", "✅ Alarm sound stopped and released")
            } catch (e: Exception) {
                Log.e("AlarmSoundManager", "Error stopping alarm sound", e)
            } finally {
                mediaPlayer = null
            }
        }
    }

    fun isAlarmPlaying(): Boolean {
        return mediaPlayer?.isPlaying == true
    }
}