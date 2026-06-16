package com.funmaster.mailnest

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private var callbackSink: EventChannel.EventSink? = null
    private var pendingCallback: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.funmaster.mailnest/oauth_callbacks"
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    callbackSink = events
                    pendingCallback?.let {
                        events?.success(it)
                        pendingCallback = null
                    }
                }

                override fun onCancel(arguments: Any?) {
                    callbackSink = null
                }
            }
        )
        handleOAuthIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleOAuthIntent(intent)
    }

    private fun handleOAuthIntent(intent: Intent?) {
        val uri = intent?.data?.toString() ?: return
        if (!uri.startsWith("com.funmaster.mailnest://oauth/outlook")) {
            return
        }
        callbackSink?.success(uri) ?: run {
            pendingCallback = uri
        }
    }
}
