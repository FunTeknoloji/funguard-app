package com.funguard.app.funguard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BackgroundReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        Log.d("BackgroundReceiver", "Received notification broadcast in background")
        // Here we could start a background service or notify the user directly if we want
        // For now, we ensure the broadcast is at least logged and potentially we could
        // use it to wake up the app or show a notification directly from here if the app is dead.
    }
}
