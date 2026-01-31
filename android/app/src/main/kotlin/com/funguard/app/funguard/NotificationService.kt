package com.funguard.app.funguard

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.content.Intent
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

class NotificationService : NotificationListenerService() {

    override fun onCreate() {
        super.onCreate()
        startForegroundService()
    }

    private fun startForegroundService() {
        val channelId = "funguard_foreground_service"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "FunGuard Arka Plan Koruması", NotificationManager.IMPORTANCE_LOW)
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("FunGuard Aktif")
            .setContentText("Cihazınız anlık olarak korunuyor.")
            .setSmallIcon(android.R.drawable.ic_lock_shield_lock)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        startForeground(1001, notification)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val packageName = sbn.packageName
        val extras = sbn.notification.extras
        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        Log.d("NotificationService", "Notification from $packageName: $title - $text")

        val targetPackages = listOf(
            "com.whatsapp",
            "org.telegram.messenger",
            "com.google.android.apps.messaging", // Google Messages (SMS)
            "com.samsung.android.messaging",     // Samsung Messages
            "com.android.mms",                    // Generic AOSP SMS
            "com.android.chrome",                 // Chrome
            "com.sec.android.app.sbrowser",      // Samsung Browser
            "org.mozilla.firefox",               // Firefox
            "com.android.phone",                 // Dialer
            "com.google.android.dialer"          // Google Dialer
        )

        if (targetPackages.contains(packageName)) {
            // Send to Flutter
            val intent = Intent("com.funguard.NOTIFICATION_RECEIVED")
            intent.putExtra("package", packageName)
            intent.putExtra("title", title)
            intent.putExtra("text", text)
            sendBroadcast(intent)

            // Simple native check for robustness when app is closed
            val dangerousKeywords = listOf("banka", "şifre", "sifre", "hesap", "güncelle", "doğrula", "tehlike", "gift", "win", "kazandınız")
            var isSuspicious = false
            text?.let {
                for (keyword in dangerousKeywords) {
                    if (it.contains(keyword, ignoreCase = true)) {
                        isSuspicious = true
                        break
                    }
                }
            }

            if (isSuspicious) {
                showNativeWarning(title ?: "Şüpheli Mesaj", "FunGuard: Bu mesaj şüpheli içerik barındırıyor olabilir!")
            }
        }
    }

    private fun showNativeWarning(title: String, body: String) {
        val channelId = "funguard_native_alerts"
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "FunGuard Native Alerts", NotificationManager.IMPORTANCE_HIGH)
            notificationManager.createNotificationChannel(channel)
        }

        val intent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        notificationManager.notify(1, notification)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {
        // Handle notification removal if needed
    }
}
