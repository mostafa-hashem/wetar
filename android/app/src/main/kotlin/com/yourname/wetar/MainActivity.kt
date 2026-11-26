package com.yourname.wetar

import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Hosts Wetar's single shared FlutterEngine via AudioServiceFragmentActivity so background
 * playback survives UI lifecycle changes and incoming intents route directly to Dart.
 */
class MainActivity : AudioServiceFragmentActivity() {
    private var platformBridge: WetarPlatformPlugin? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)
        platformBridge?.handleIncomingIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val bridge = WetarPlatformPlugin(this, flutterEngine)
        platformBridge = bridge
        bridge.handleIncomingIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        platformBridge?.handleIncomingIntent(intent)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (platformBridge?.handleActivityResult(requestCode, resultCode, data) == true) {
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        if (platformBridge?.handlePermissionResult(requestCode, permissions, grantResults) == true) {
            return
        }
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    override fun onDestroy() {
        platformBridge?.dispose()
        platformBridge = null
        super.onDestroy()
    }
}
