package com.funguard.app.funguard

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.content.Intent
import android.util.Log

class FunGuardAccessibilityService : AccessibilityService() {

    companion object {
        var instance: FunGuardAccessibilityService? = null
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.d("FunGuardAccessibility", "Service Connected")
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
    }

    fun performBackAction() {
        performGlobalAction(GLOBAL_ACTION_BACK)
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        // We look for URL in all window content changed, state changed, or focused events
        val source = event.source ?: rootInActiveWindow ?: return
        val packageName = event.packageName?.toString() ?: ""

        // Try to find URL
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
        // Increase depth limit for more complex pages
        while (nodeQueue.isNotEmpty() && depth < 2000) {
            val node = nodeQueue.removeAt(0)
            depth++

            val className = node.className?.toString() ?: ""
            val text = node.text?.toString()
            val contentDesc = node.contentDescription?.toString()
            val idName = node.viewIdResourceName ?: ""

            // Comprehensive check for address bars and URL-like content
            // We look for specific ID patterns commonly used in browsers
            val isUrlBar = idName.contains("url", ignoreCase = true) ||
                           idName.contains("address", ignoreCase = true) ||
                           idName.contains("location", ignoreCase = true) ||
                           idName.contains("search", ignoreCase = true) ||
                           (contentDesc != null && (contentDesc.contains("Adres", ignoreCase = true) || contentDesc.contains("Address", ignoreCase = true)))

            if (isUrlBar || className.contains("EditText", ignoreCase = true)) {
                if (text != null && text.length > 3) {
                    val cleanText = text.trim()
                    // URL heuristic: starts with http, or contains a dot and no spaces
                    if (cleanText.startsWith("http") || (cleanText.contains(".") && !cleanText.contains(" "))) {
                        // Avoid common false positives like "google.com" appearing in search buttons
                        if (cleanText.contains(".") && cleanText.length > 4) {
                            return cleanText
                        }
                    }
                }
            }

            // General fallback: any node text that looks like a URL
            if (text != null && text.length > 5 && !text.contains(" ")) {
                if (text.startsWith("http://") || text.startsWith("https://") ||
                    (text.contains(".") && text.split(".").last().length in 2..6)) {
                    // Check if it's a valid-looking domain
                    val domainRegex = Regex("""^(https?://)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}(/.*)?$""")
                    if (domainRegex.matches(text)) {
                        return text
                    }
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

    override fun onInterrupt() {
        Log.d("FunGuardAccessibility", "Service Interrupted")
    }
}
