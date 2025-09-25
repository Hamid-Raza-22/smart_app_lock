package com.smart_app_lock.smart_app_lock

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class AppLockAccessibilityService : AccessibilityService() {

    private var lastPackage = ""

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString() ?: return

            if (packageName != lastPackage && packageName != applicationContext.packageName) {
                lastPackage = packageName

                if (isAppLocked(packageName)) {
                    // Show lock screen
                    val intent = Intent(this, LockScreenActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                                Intent.FLAG_ACTIVITY_NO_HISTORY)
                        putExtra("locked_package", packageName)
                    }
                    startActivity(intent)
                }
            }
        }
    }

    override fun onInterrupt() {
        // Handle service interruption
    }

    private fun isAppLocked(packageName: String): Boolean {
        val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
        val lockedApps = prefs.getStringSet("locked_apps", emptySet()) ?: emptySet()
        return lockedApps.contains(packageName)
    }
}