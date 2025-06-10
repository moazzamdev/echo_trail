// SmsTtsHandler.kt
package com.echo_trail

import android.content.Context
import android.speech.tts.TextToSpeech
import android.util.Log
import java.util.Locale
import java.util.LinkedList

class SmsTtsHandler(private val context: Context) {
    private var tts: TextToSpeech? = null
    private var isTtsInitialized = false
    private val messageQueue = LinkedList<Pair<String, Boolean>>()

    init {
        tts = TextToSpeech(context.applicationContext) { status ->
            if (status == TextToSpeech.SUCCESS) {
                synchronized(this) {
                    isTtsInitialized = true
                    tts?.language = Locale.US
                    // Process queued messages
                    while (messageQueue.isNotEmpty()) {
                        val (message, isUrdu) = messageQueue.removeFirst()
                        speakMessage(message, isUrdu)
                    }
                }
            } else {
                Log.e("SmsTtsHandler", "TTS Initialization failed: status=$status")
            }
        }
    }

    fun readMessage(message: String, isUrdu: Boolean = false) {
        synchronized(this) {
            if (isTtsInitialized) {
                speakMessage(message, isUrdu)
            } else {
                // Queue message if TTS is not initialized
                messageQueue.add(Pair(message, isUrdu))
                Log.d("SmsTtsHandler", "TTS not initialized, queuing message: $message")
            }
        }
    }

    private fun speakMessage(message: String, isUrdu: Boolean) {
        tts?.let {
            val locale = if (isUrdu) Locale("ur") else Locale.US
            if (isUrdu && it.isLanguageAvailable(locale) >= TextToSpeech.LANG_AVAILABLE) {
                it.language = locale
            } else {
                it.language = Locale.US
            }
            it.speak(message, TextToSpeech.QUEUE_ADD, null, null)
        } ?: Log.e("SmsTtsHandler", "TTS not initialized")
    }

    fun stop() {
        synchronized(this) {
            tts?.stop()
            tts?.shutdown()
            tts = null
            isTtsInitialized = false
            messageQueue.clear()
        }
    }
}