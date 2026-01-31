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
        val rootNode = rootInActiveWindow ?: return

        val packageName = event.packageName?.toString() ?: ""
        val browserPackages = listOf(
            "com.android.chrome",
            "org.mozilla.firefox",
            "com.sec.android.app.sbrowser",
            "com.opera.browser",
            "com.microsoft.emmx"
        )

        if (browserPackages.contains(packageName)) {
            val url = findUrl(rootNode)
            if (url != null && url.isNotEmpty()) {
                Log.d("FunGuardAccessibility", "Detected URL: $url in $packageName")
                val intent = Intent("com.funguard.NOTIFICATION_RECEIVED")
                intent.putExtra("package", packageName)
                intent.putExtra("title", "Tarayıcı Tespiti")
                intent.putExtra("text", url)
                sendBroadcast(intent)
            }
        }
    }

    private fun findUrl(nodeInfo: AccessibilityNodeInfo): String? {
        val nodeQueue = mutableListOf<AccessibilityNodeInfo>()
        nodeQueue.add(nodeInfo)

        while (nodeQueue.isNotEmpty()) {
            val node = nodeQueue.removeAt(0)

            // Common ID names for address bars in various browsers
            val idName = node.viewIdResourceName ?: ""
            if (idName.contains("url_bar") || idName.contains("url_edit_text") || idName.contains("location_bar")) {
                val text = node.text?.toString()
                if (text != null && (text.startsWith("http") || text.contains("."))) {
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
