package com.smart_app_lock.smart_app_lock

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent
import android.widget.Toast

class DeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
        Toast.makeText(context, "App Lock: Device admin enabled", Toast.LENGTH_SHORT).show()
    }

    override fun onDisabled(context: Context, intent: Intent) {
        super.onDisabled(context, intent)
        Toast.makeText(context, "App Lock: Device admin disabled", Toast.LENGTH_SHORT).show()
    }

    override fun onPasswordFailed(context: Context, intent: Intent) {
        super.onPasswordFailed(context, intent)

        val prefs = context.getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        val failedAttempts = prefs.getInt("failed_attempts", 0) + 1
        prefs.edit().putInt("failed_attempts", failedAttempts).apply()

        if (failedAttempts >= 3) {
            Toast.makeText(context, "Maximum attempts reached!", Toast.LENGTH_LONG).show()
            // Trigger factory reset or other security action
        }
    }

    override fun onPasswordSucceeded(context: Context, intent: Intent) {
        super.onPasswordSucceeded(context, intent)

        // Reset failed attempts
        val prefs = context.getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        prefs.edit().putInt("failed_attempts", 0).apply()
    }
}