package com.jippymart.customer

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Build
import android.util.Log
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val EVENT_CHANNEL = "deep_link_events"
    private val METHOD_CHANNEL = "deep_link_methods"

    // Stream sink for real-time deep link events
    private var events: EventChannel.EventSink? = null

    // Keep last initial deep link so Flutter can request it
    private var initialLink: String? = null

    // If events is null when link arrives, store here and flush when onListen occurs
    private var pendingLink: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle initial intent
        handleIntent(intent)
        
        // ✅ Modern edge-to-edge implementation for Android 15+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // Use new Android 15 APIs
            enableEdgeToEdgeModern()
        } else {
            // Use legacy approach for older versions
            enableEdgeToEdgeLegacy()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent) // update activity intent for future getIntent() calls
        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] onNewIntent called - app already running")
        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Intent data: ${intent.data}")
        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Intent action: ${intent.action}")
        
        // Ensure the app is brought to foreground
        if (intent.action == Intent.ACTION_VIEW) {
            Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Bringing app to foreground for deep link")
            // Bring the app to foreground
            val bringToFrontIntent = Intent(this, MainActivity::class.java)
            bringToFrontIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP
            startActivity(bringToFrontIntent)
        }
        
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        if (intent.action == Intent.ACTION_VIEW) {
            val data: Uri? = intent.data
            data?.let {
                val link = it.toString()
                Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Deep link detected: $link")
                // Set initialLink if not set (useful for cold start)
                if (initialLink == null) initialLink = link

                // If Flutter is listening, send immediately; otherwise store pending
                if (events != null) {
                    events?.success(link)
                } else {
                    pendingLink = link
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] configureFlutterEngine called")

        // EventChannel for streaming link events (real-time)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                    Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Event channel listener started")
                    events = eventSink
                    // If there is a pending link (sent before Flutter attached), flush it
                    pendingLink?.let {
                        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Flushing pending link: $it")
                        events?.success(it)
                        pendingLink = null
                    }
                }

                override fun onCancel(arguments: Any?) {
                    Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Event channel listener cancelled")
                    events = null
                }
            })

        // MethodChannel for getInitialLink (cold start request)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] Method call received: ${call.method}")
                when (call.method) {
                    "getInitialLink" -> {
                        Log.d("DEEP_LINK", "🔗 [MAIN ACTIVITY] getInitialLink called, returning: $initialLink")
                        // return the stored initial link (may be null)
                        result.success(initialLink)
                        // optional: clear initialLink after returning (so it's one-time)
                        initialLink = null
                    }
                    else -> result.notImplemented()
                }
            }
    }
    
    private fun enableEdgeToEdgeModern() {
        // ✅ Android 15+ modern edge-to-edge implementation
        // This avoids deprecated APIs
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Use WindowInsetsController for modern status/navigation bar control
        val windowInsetsController = WindowCompat.getInsetsController(window, window.decorView)
        windowInsetsController.isAppearanceLightStatusBars = true
        windowInsetsController.isAppearanceLightNavigationBars = true
    }
    
    private fun enableEdgeToEdgeLegacy() {
        // ✅ Legacy edge-to-edge for Android 14 and below
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
} 