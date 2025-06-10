// Path: android/app/src/main/kotlin/com/echo_trail/VoiceRecognitionService.kt

package com.echo_trail

import android.app.*
import android.content.Intent
import android.speech.tts.UtteranceProgressListener
import android.os.*
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.speech.tts.TextToSpeech
import android.util.Log
import java.util.*

class VoiceRecognitionService : Service() {
    private lateinit var speechRecognizer: SpeechRecognizer
    private lateinit var tts: TextToSpeech
    private var isListening = false
    private var isCommandMode = false
    private val TAG = "VoiceService"
    private val handler = Handler(Looper.getMainLooper())

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
        initTTS()
    }

    private fun startForegroundService() {
        val channelId = "voice_recognition_channel"
        val channelName = "Voice Recognition Service"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val chan = NotificationChannel(channelId, channelName, NotificationManager.IMPORTANCE_LOW)
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(chan)
        }

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE
        )

        val notification = Notification.Builder(this, channelId)
            .setContentTitle("Voice recognition active")
            .setContentText("Listening for wake word...")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)
    }

    private fun initTTS() {
        tts = TextToSpeech(this) { status ->
            if (status == TextToSpeech.SUCCESS) {
                tts.language = Locale.US
                tts.setSpeechRate(1.0f)
                tts.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                    override fun onStart(utteranceId: String?) {
                        Log.d(TAG, "TTS started")
                    }

                    override fun onDone(utteranceId: String?) {
                        Log.d(TAG, "TTS completed, checking for restart...")
                        if (!isListening && !isCommandMode) {
                            handler.postDelayed({
                                startListening()
                            }, 800)
                        }
                    }

                    override fun onError(utteranceId: String?) {
                        Log.e(TAG, "TTS error for utterance: $utteranceId")
                    }
                })
                initSpeechRecognizer()
                startListening()
            } else {
                Log.e(TAG, "TTS initialization failed: $status")
            }
        }
    }

    private fun initSpeechRecognizer() {
        if (SpeechRecognizer.isRecognitionAvailable(this)) {
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
            speechRecognizer.setRecognitionListener(object : RecognitionListener {
                override fun onReadyForSpeech(params: Bundle?) {
                    Log.d(TAG, "Ready for speech, isListening=$isListening, isCommandMode=$isCommandMode")
                }

                override fun onResults(results: Bundle?) {
                    isListening = false
                    val matches = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                    val spokenText = matches?.firstOrNull()?.lowercase(Locale.getDefault()) ?: ""
                    Log.d(TAG, "Heard: $spokenText")

                    val intent = Intent("com.echo_trail.WAKE_WORD")
                    intent.putExtra("text", spokenText)
                    sendBroadcast(intent)

                    if (!isCommandMode && (spokenText.contains("echo") || spokenText.contains("eco") || spokenText.contains("aqua"))) {
                        isCommandMode = true
                        val wakeIntent = Intent("com.echo_trail.WAKE_WORD")
                        wakeIntent.putExtra("text", "wake_word")
                        sendBroadcast(wakeIntent)
                    } else if (isCommandMode) {
                        isCommandMode = false
                        val commandIntent = Intent("com.echo_trail.WAKE_WORD")
                        commandIntent.putExtra("text", spokenText)
                        sendBroadcast(commandIntent)
                        handler.postDelayed({
                            startListening()
                        }, 1000)
                    } else {
                        restartListening()
                    }
                }

                override fun onError(error: Int) {
                    isListening = false
                    Log.d(TAG, "Speech error: $error")
                    when (error) {
                        SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> {
                            Log.d(TAG, "Recognizer busy, attempting to restart...")
                            handler.postDelayed({
                                restartListening()
                            }, 3000) // Longer delay for busy errors
                        }
                        SpeechRecognizer.ERROR_CLIENT,
                        SpeechRecognizer.ERROR_AUDIO,
                        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> {
                            restartListening()
                        }
                        else -> {
                            handler.postDelayed({
                                if (!isListening && !isCommandMode) {
                                    startListening()
                                }
                            }, 1500)
                        }
                    }
                }

                override fun onBeginningOfSpeech() {}
                override fun onBufferReceived(buffer: ByteArray?) {}
                override fun onEndOfSpeech() {}
                override fun onEvent(eventType: Int, params: Bundle?) {}
                override fun onPartialResults(partialResults: Bundle?) {}
                override fun onRmsChanged(rmsdB: Float) {}
            })
        } else {
            Log.e(TAG, "Speech recognition not available on this device")
        }
    }

    private fun startListening() {
        if (isListening) {
            Log.d(TAG, "Already listening. Skipping startListening.")
            return
        }
        if (::tts.isInitialized && tts.isSpeaking) {
            Log.d(TAG, "TTS is speaking, delaying startListening...")
            handler.postDelayed({
                startListening()
            }, 1000)
            return
        }
        if (::speechRecognizer.isInitialized) {
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            }
            speechRecognizer.startListening(intent)
            isListening = true
        } else {
            Log.e(TAG, "SpeechRecognizer not initialized, reinitializing...")
            initSpeechRecognizer()
            handler.postDelayed({
                startListening()
            }, 1000)
        }
    }

    private fun startCommandListener() {
        if (isListening) {
            Log.d(TAG, "Already listening for command. Skipping.")
            return
        }
        if (::tts.isInitialized && tts.isSpeaking) {
            Log.d(TAG, "TTS is speaking, delaying command listener...")
            handler.postDelayed({
                startCommandListener()
            }, 1000)
            return
        }
        if (::speechRecognizer.isInitialized) {
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-US")
                putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 1)
            }
            speechRecognizer.startListening(intent)
            isListening = true
            isCommandMode = true
        } else {
            Log.e(TAG, "SpeechRecognizer not initialized, reinitializing...")
            initSpeechRecognizer()
            handler.postDelayed({
                startCommandListener()
            }, 1000)
        }
    }

    private fun stopListening() {
        if (::speechRecognizer.isInitialized) {
            speechRecognizer.stopListening()
            speechRecognizer.cancel()
            isListening = false
            isCommandMode = false
        }
    }

    private fun restartListening() {
        if (::speechRecognizer.isInitialized) {
            try {
                speechRecognizer.stopListening()
                speechRecognizer.cancel()
                speechRecognizer.destroy()
                isListening = false
                isCommandMode = false
            } catch (e: Exception) {
                Log.e(TAG, "Failed to destroy recognizer: ${e.message}")
            }
        }
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        initSpeechRecognizer()
        handler.postDelayed({
            if (!isListening && !isCommandMode) {
                startListening()
            }
        }, 2000) // Increased delay for safer resource release
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            "com.echo_trail.START_VOICE_RECOGNITION" -> startListening()
            "com.echo_trail.START_COMMAND_LISTENER" -> startCommandListener()
            "com.echo_trail.STOP_VOICE_RECOGNITION" -> stopListening()
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        if (::speechRecognizer.isInitialized) {
            speechRecognizer.stopListening()
            speechRecognizer.cancel()
            speechRecognizer.destroy()
        }
        if (::tts.isInitialized) {
            tts.stop()
            tts.shutdown()
        }
        handler.removeCallbacksAndMessages(null)
    }
}