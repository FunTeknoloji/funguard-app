package com.funguard.app.funguard

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.app.NotificationCompat

class BackgroundReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val packageName = intent.getStringExtra("package") ?: "Bilinmeyen"
        val title = intent.getStringExtra("title") ?: "FunGuard Tespiti"
        val text = intent.getStringExtra("text") ?: ""

        Log.d("BackgroundReceiver", "Received broadcast: $title - $text")

        if (title.contains("Tarayıcı")) {
            // Show a scanning notification
            showScanNotification(context, "Site Analiz Ediliyor", "$text taranıyor...")
        }
    }

    private fun showScanNotification(context: Context, title: String, body: String) {
        val channelId = "funguard_scan_alerts"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "FunGuard Tarama Bildirimleri", NotificationManager.IMPORTANCE_LOW)
            notificationManager.createNotificationChannel(channel)
        }

        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(body)
            .setSmallIcon(android.R.drawable.ic_menu_search)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(2, notification)
    }
}
