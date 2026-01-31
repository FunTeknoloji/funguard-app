package com.funguard.app.funguard

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import android.util.Log

class FunGuardAccessibilityService : AccessibilityService() {

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("FunGuardAccessibility", "Service Connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // We listen to window changes and content changes
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) {
            return
        }

        val source = event.source ?: rootInActiveWindow ?: return
        val packageName = event.packageName?.toString() ?: ""

        // Try to find URL in any package that might be a browser
        // We include many but also try to be generic
        val url = findUrl(source)
        if (url != null && url.isNotEmpty()) {
            Log.d("FunGuardAccessibility", "Detected URL: $url in $packageName")

            // Send broadcast for the app to process
            val intent = Intent("com.funguard.NOTIFICATION_RECEIVED")
            intent.putExtra("package", packageName)
            intent.putExtra("title", "Tarayıcı Tespiti")
            intent.putExtra("text", url)
            sendBroadcast(intent)
        }
    }

    private fun findUrl(nodeInfo: AccessibilityNodeInfo): String? {
        val nodeQueue = mutableListOf<AccessibilityNodeInfo>()
        nodeQueue.add(nodeInfo)

        var depth = 0
        while (nodeQueue.isNotEmpty() && depth < 1000) {
            val node = nodeQueue.removeAt(0)
            depth++

            val className = node.className?.toString() ?: ""
            val text = node.text?.toString()
            val contentDesc = node.contentDescription?.toString()
            val idName = node.viewIdResourceName ?: ""

            // Aggressive check for address bar
            if (className.contains("EditText") || className.contains("TextView") || idName.isNotEmpty()) {
                if (idName.contains("url", ignoreCase = true) ||
                    idName.contains("address", ignoreCase = true) ||
                    idName.contains("location", ignoreCase = true) ||
                    idName.contains("search", ignoreCase = true) ||
                    (contentDesc != null && (contentDesc.contains("Adres", ignoreCase = true) || contentDesc.contains("Address", ignoreCase = true)))) {

                    if (text != null && (text.startsWith("http") || text.contains("."))) {
                        // Basic validation: must contain a dot and not be just whitespace
                        if (text.contains(".") && !text.contains(" ") && text.length > 3) {
                            return text
                        }
                    }
                }
            }

            // Fallback: if it's an EditText and looks like a URL
            if (className.contains("EditText") && text != null) {
                if ((text.startsWith("http") || text.contains(".")) && !text.contains(" ") && text.contains(".")) {
                    return text
                }
            }

            for (i in 0 until node.childCount) {
                val child = node.getChild(i)
                if (child != null) {
                    nodeQueue.add(child)
                }
            }
        }
        return null
    }

    override fun onInterrupt() {}
}
