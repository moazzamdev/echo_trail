// AlarmHelper
package com.echo_trail

import android.app.*
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import java.util.*

object AlarmHelper {
    private const val REQUEST_CODE = 1234
    private val alarmCodes = mutableListOf<Int>()
    private var lastRequestCode: Int = 0


    fun setAlarm(context: Context, hour: Int, minute: Int, isNew: Boolean): Boolean {
        val requestCode = if (isNew) {
            lastRequestCode += 1
            alarmCodes.add(lastRequestCode)
            lastRequestCode
        } else {
            if (alarmCodes.isEmpty()) {
                alarmCodes.add(lastRequestCode)
            }
            alarmCodes.first()
        }

        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, requestCode, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            if (before(Calendar.getInstance())) {
                add(Calendar.DAY_OF_MONTH, 1)
            }
        }

        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, calendar.timeInMillis, pendingIntent)
        Log.d("AlarmHelper", "Alarm set: requestCode=$requestCode at $hour:$minute (new=$isNew)")
        return true
    }

    fun cancelAlarm(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, AlarmReceiver::class.java)
        val pi = PendingIntent.getBroadcast(
            context, 1234, intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
        alarmManager.cancel(pi)
        Log.d("AlarmHelper", "✅ Alarm cancelled")
    }

    fun dismissAlarm(context: Context) {
        val intent = Intent(context, AlarmDismissService::class.java)
        context.startService(intent) // ✅ Not foreground, no crash, no channel needed

        Log.d("AlarmHelper", "✅ Alarm dismissed without deleting")
    }

    fun snoozeAlarm(context: Context, minutes: Int = 5) {
        val calendar = Calendar.getInstance().apply {
            add(Calendar.MINUTE, minutes)
        }
        val hour = calendar.get(Calendar.HOUR_OF_DAY)
        val minute = calendar.get(Calendar.MINUTE)
        setAlarm(context, hour, minute, true)
        Log.d("AlarmHelper", "✅ Alarm snoozed for $minutes minutes")
    }

}

