// SmsReceiver
package com.echo_trail

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.ContactsContract
import android.telephony.SmsMessage
import androidx.core.content.ContextCompat
import android.content.pm.PackageManager
import android.util.Log

class SmsReceiver : BroadcastReceiver() {
    private lateinit var ttsHandler: SmsTtsHandler

    private fun convertNumberToWords(number: String): String {
        val digitMap = mapOf(
            '0' to "zero",
            '1' to "one",
            '2' to "two",
            '3' to "three",
            '4' to "four",
            '5' to "five",
            '6' to "six",
            '7' to "seven",
            '8' to "eight",
            '9' to "nine"
        )
        return number.map { digitMap[it] ?: it }.joinToString(" ")
    }


    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
            ttsHandler = SmsTtsHandler(context)
            val bundle = intent.extras
            if (bundle != null) {
                val pdus = bundle.get("pdus") as? Array<*>
                val format = bundle.getString("format")
                pdus?.let {
                    val messages = pdus.mapNotNull {
                        SmsMessage.createFromPdu(it as ByteArray, format)
                    }

                    val sms = messages.joinToString(separator = "") { it.messageBody }

                    val senderNumber = messages[0].originatingAddress ?: "Unknown"
                    val normalizedNumber = PhoneNumberUtils.normalizePhoneNumber(senderNumber)

                    val contactName = if (ContextCompat.checkSelfPermission(context, android.Manifest.permission.READ_CONTACTS)
                        == PackageManager.PERMISSION_GRANTED) {
                        getContactName(context, normalizedNumber)
                    } else {
                        null
                    }

                    val spokenSender = contactName ?: convertNumberToWords(senderNumber.filter { it.isDigit() })

                    val spokenTextEnglish = "SMS from $spokenSender. $sms"
                    val spokenTextUrdu = "پیغام $spokenSender سے آیا ہے۔ $sms"

                    val isUrdu = sms.contains(Regex("[\\p{InArabic}]"))
                    ttsHandler.readMessage(
                        if (isUrdu) spokenTextUrdu else spokenTextEnglish,
                        isUrdu
                    )
                }
            }
        }
    }

    private fun getContactName(context: Context, phoneNumber: String): String? {
        try {
            val contentResolver = context.contentResolver
            val uri = Uri.withAppendedPath(
                ContactsContract.PhoneLookup.CONTENT_FILTER_URI,
                Uri.encode(phoneNumber)
            )
            val cursor = contentResolver.query(
                uri,
                arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME),
                null,
                null,
                null
            )

            var contactName: String? = null
            cursor?.use {
                if (it.moveToFirst()) {
                    contactName =
                        it.getString(it.getColumnIndexOrThrow(ContactsContract.PhoneLookup.DISPLAY_NAME))
                }
            }
            return contactName
        } catch (e: Exception) {
            Log.e("SmsReceiver", "Error querying contact: ${e.message}")
            return null
        }
    }
}