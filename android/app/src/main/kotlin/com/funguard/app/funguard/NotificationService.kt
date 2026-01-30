package com.funguard.app.funguard

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log

class NotificationService : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        Log.d("NotificationService", "Notification from $packageName: $title - $text")

        if (packageName == "com.whatsapp" || packageName == "org.telegram.messenger") {
            // Send to Flutter
            val intent = Intent("com.funguard.NOTIFICATION_RECEIVED")
            intent.putExtra("package", packageName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            sendBroadcast(intent)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // Handle notification removal if needed
    }
}
