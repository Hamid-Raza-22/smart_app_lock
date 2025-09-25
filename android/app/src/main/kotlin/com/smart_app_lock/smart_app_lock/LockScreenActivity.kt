package com.smart_app_lock.smart_app_lock

import android.app.Activity

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.view.WindowManager
import android.widget.*

class LockScreenActivity : Activity() {

    private var lockedPackage: String? = null
    private var failedAttempts = 0
    private val maxAttempts = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make this activity appear above everything
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
        )

        // Create simple UI programmatically
        createUI()

        lockedPackage = intent.getStringExtra("locked_package")

        // Load failed attempts
        val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
        failedAttempts = prefs.getInt("failed_attempts_$lockedPackage", 0)
    }

    private fun createUI() {
        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(50, 100, 50, 50)
        }

        val titleText = TextView(this).apply {
            text = "App Locked"
            textSize = 24f
            setPadding(0, 0, 0, 30)
        }

        val passwordInput = EditText(this).apply {
            hint = "Enter Password"
            inputType = android.text.InputType.TYPE_CLASS_TEXT or
                    android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD
        }

        val unlockButton = Button(this).apply {
            text = "Unlock"
            setOnClickListener {
                verifyPassword(passwordInput.text.toString())
            }
        }

        val cancelButton = Button(this).apply {
            text = "Cancel"
            setOnClickListener {
                goToHome()
            }
        }

        layout.addView(titleText)
        layout.addView(passwordInput)
        layout.addView(unlockButton)
        layout.addView(cancelButton)

        setContentView(layout)
    }

    private fun verifyPassword(enteredPassword: String) {
        val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
        val storedPassword = prefs.getString("app_password", "1234") // Default password

        if (enteredPassword == storedPassword) {
            // Password correct
            prefs.edit().putInt("failed_attempts_$lockedPackage", 0).apply()

            // Open the app
            lockedPackage?.let {
                val intent = packageManager.getLaunchIntentForPackage(it)
                intent?.let { launchIntent ->
                    startActivity(launchIntent)
                }
            }
            finish()
        } else {
            // Wrong password
            failedAttempts++
            prefs.edit().putInt("failed_attempts_$lockedPackage", failedAttempts).apply()

            if (failedAttempts >= maxAttempts) {
                // Uninstall the app after 3 failed attempts
                Toast.makeText(this, "Maximum attempts reached! Uninstalling app...",
                    Toast.LENGTH_LONG).show()

                uninstallApp()
            } else {
                Toast.makeText(this,
                    "Wrong password! ${maxAttempts - failedAttempts} attempts remaining",
                    Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun uninstallApp() {
        lockedPackage?.let { packageName ->
            try {
                // Reset failed attempts
                val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
                prefs.edit().putInt("failed_attempts_$packageName", 0).apply()

                // Remove from locked apps
                val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf()) ?: mutableSetOf()
                lockedApps.remove(packageName)
                prefs.edit().putStringSet("locked_apps", lockedApps).apply()

                // Open uninstall dialog
                val intent = Intent(Intent.ACTION_DELETE)
                intent.data = Uri.parse("package:$packageName")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)

                finish()
            } catch (e: Exception) {
                e.printStackTrace()
                Toast.makeText(this, "Failed to uninstall app", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun goToHome() {
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        finish()
    }

    override fun onBackPressed() {
        // Don't allow back press, go to home instead
        goToHome()
    }
}