package com.smart_app_lock.smart_app_lock
import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast

class PasswordActivity : Activity() {

    private lateinit var passwordInput: EditText
    private lateinit var submitButton: Button
    private lateinit var appNameText: TextView
    private var lockedPackage: String? = null
    private var failedAttempts = 0

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Make this activity appear on lock screen
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
        )

        // Simple layout - in production, use proper XML layout
        setContentView(android.R.layout.simple_list_item_1)

        lockedPackage = intent.getStringExtra("locked_package")

        // Initialize views (simplified for example)
        setupViews()
    }

    private fun setupViews() {
        // In production, inflate proper XML layout
        // This is simplified example

        submitButton?.setOnClickListener {
            verifyPassword()
        }
    }

    private fun verifyPassword() {
        val enteredPassword = passwordInput.text.toString()
        val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
        val storedPassword = prefs.getString("app_password", "")

        if (enteredPassword == storedPassword) {
            // Password correct, allow access
            finish()
        } else {
            failedAttempts++

            if (failedAttempts >= 3) {
                // Trigger security action
                Toast.makeText(this, "Maximum attempts reached!", Toast.LENGTH_LONG).show()
                // In production, trigger factory reset or other security measure

                // Return to home
                val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                    addCategory(Intent.CATEGORY_HOME)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                }
                startActivity(homeIntent)
                finish()
            } else {
                Toast.makeText(
                    this,
                    "Wrong password. ${3 - failedAttempts} attempts remaining",
                    Toast.LENGTH_SHORT
                ).show()
                passwordInput.setText("")
            }
        }
    }

    override fun onBackPressed() {
        // Go to home screen instead of returning to locked app
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)
        super.onBackPressed()
    }
}