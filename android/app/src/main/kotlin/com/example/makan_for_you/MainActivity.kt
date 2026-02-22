package com.example.makan_for_you

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs.BackgroundMode

class MainActivity : FlutterActivity() {
    override fun getBackgroundMode(): BackgroundMode {
        return BackgroundMode.opaque
    }
}
