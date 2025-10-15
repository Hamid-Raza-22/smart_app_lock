package com.smart_app_lock.smart_app_lock

import android.app.Activity
import android.app.PendingIntent
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.view.inputmethod.InputMethodManager
import android.widget.*
import java.io.DataOutputStream
// IOException is implicitly handled by catch (e: Exception)

class LockScreenActivity : Activity() {

    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var componentName: ComponentName
    private var lockedPackage: String? = null
    private var failedAttempts = 0
    private val maxAttempts = 3

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize Device Policy Manager
        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        componentName = ComponentName(this, DeviceAdminReceiver::class.java)

        // Make this activity appear above everything
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                    WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.TYPE_SYSTEM_ERROR
        )

        // Create UI
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
            setBackgroundColor(android.graphics.Color.WHITE)
        }

        val titleText = TextView(this).apply {
            text = "🔒 App Locked"
            textSize = 24f
            setPadding(0, 0, 0, 30)
        }

        val warningText = TextView(this).apply {
            text = "⚠️ Warning: 3 wrong attempts will DELETE this app!"
            textSize = 14f
            setTextColor(android.graphics.Color.RED)
            setPadding(0, 0, 0, 20)
        }

        val passwordInput = EditText(this).apply {
            hint = "Enter Password"
            inputType = android.text.InputType.TYPE_CLASS_TEXT or
                    android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD
            requestFocus() // Request focus for the password input
        }

        val attemptsText = TextView(this).apply {
            text = "Attempts: $failedAttempts / $maxAttempts"
            textSize = 16f
            setPadding(0, 20, 0, 20)
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
        layout.addView(warningText)
        layout.addView(passwordInput)
        layout.addView(attemptsText)
        layout.addView(unlockButton)
        layout.addView(cancelButton)

        setContentView(layout)

        // Show keyboard for password input
        passwordInput.post {
            val imm = getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
            imm.toggleSoftInput(InputMethodManager.SHOW_FORCED, 0)
        }
    }

    private fun verifyPassword(enteredPassword: String) {
        val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
        val storedPassword = prefs.getString("app_password", "1234") // Default password

        if (enteredPassword == storedPassword) {
            // Password correct - Reset attempts and open app
            prefs.edit().putInt("failed_attempts_$lockedPackage", 0).apply()

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
                // Maximum attempts reached - Delete app
                Toast.makeText(this,
                    "Maximum attempts reached! Deleting app...",
                    Toast.LENGTH_LONG).show()

                // Trigger app deletion
                deleteApp()
            } else {
                Toast.makeText(this,
                    "Wrong password! ${maxAttempts - failedAttempts} attempts remaining",
                    Toast.LENGTH_SHORT).show()

                // Update UI
                recreate()
            }
        }
    }

    private fun deleteApp() {
        lockedPackage?.let { packageName ->
            // Reset failed attempts
            val prefs = getSharedPreferences("app_lock_prefs", MODE_PRIVATE)
            prefs.edit().putInt("failed_attempts_$packageName", 0).apply()

            // Remove from locked apps
            val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf()) ?: mutableSetOf()
            lockedApps.remove(packageName)
            prefs.edit().putStringSet("locked_apps", lockedApps).apply()

            // Try different uninstall methods
            when {
                // Method 1: Silent uninstall with root (if available)
                isRootAvailable() -> uninstallWithRoot(packageName)

                // Method 2: Device Owner silent uninstall (if device owner)
                isDeviceOwner() -> uninstallAsDeviceOwner(packageName)

                // Method 3: System app privileges (if system app)
                isSystemApp() -> uninstallAsSystemApp(packageName)

                // Method 4: Hide the app (disable it)
                canDisableApp() -> disableApp(packageName)

                // Method 5: Last resort - Show uninstall dialog
                else -> showUninstallDialog(packageName)
            }

            finish()
        }
    }

    // Check if device is rooted
    private fun isRootAvailable(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("su")
            process.destroy()
            true
        } catch (e: Exception) {
            false
        }
    }

    // Uninstall with root access
    private fun uninstallWithRoot(packageName: String) {
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)

            // Silent uninstall command
            os.writeBytes("pm uninstall $packageName\n")
            os.writeBytes("exit\n")
            os.flush()
            os.close()

            process.waitFor()

            Toast.makeText(this, "App deleted successfully!", Toast.LENGTH_SHORT).show()
            goToHome()
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback to dialog
            showUninstallDialog(packageName)
        }
    }

    // Check if app is device owner
    private fun isDeviceOwner(): Boolean {
        return devicePolicyManager.isDeviceOwnerApp(packageName)
    }

    // Uninstall as device owner
    private fun uninstallAsDeviceOwner(packageName: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                // For Android 9+ with device owner
                val packageInstaller = packageManager.packageInstaller
                val intent = Intent("${applicationContext.packageName}.ACTION_UNINSTALL_STATUS")
                val pendingIntent = PendingIntent.getBroadcast(
                    applicationContext,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                packageInstaller.uninstall(packageName, pendingIntent.intentSender)

                Toast.makeText(this, "App deletion initiated.", Toast.LENGTH_SHORT).show()
                goToHome()
            } else {
                // For older versions, use device policy manager
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    // First remove from protected apps
                    devicePolicyManager.setUninstallBlocked(componentName, packageName, false)
                }
                showUninstallDialog(packageName) // Fallback for older versions
            }
        } catch (e: SecurityException) {
            e.printStackTrace()
            Toast.makeText(this, "Uninstall permission denied.", Toast.LENGTH_SHORT).show()
            showUninstallDialog(packageName) // Fallback
        } catch (e: Exception) {
            e.printStackTrace()
            showUninstallDialog(packageName)
        }
    }

    // Check if app has system privileges
    private fun isSystemApp(): Boolean {
        return try {
            val appInfo = packageManager.getApplicationInfo(packageName, 0)
            (appInfo.flags and android.content.pm.ApplicationInfo.FLAG_SYSTEM) != 0
        } catch (e: Exception) {
            false
        }
    }

    // Uninstall as system app
    private fun uninstallAsSystemApp(packageName: String) {
        // The reflection method using IPackageDeleteObserver is unreliable and
        // causes compilation errors due to IPackageDeleteObserver being a hidden API.
        Toast.makeText(this, "System app uninstallation via reflection is not supported. Showing dialog.", Toast.LENGTH_LONG).show()
        showUninstallDialog(packageName)
    }

    // Check if we can disable the app
    private fun canDisableApp(): Boolean {
        return devicePolicyManager.isAdminActive(componentName)
    }

    // Disable app instead of uninstalling
    private fun disableApp(packageName: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                // Hide the app using device admin
                devicePolicyManager.setApplicationHidden(componentName, packageName, true)

                Toast.makeText(this, "App has been disabled and hidden!", Toast.LENGTH_LONG).show()

                // Also try to disable the package
                val pm = packageManager
                pm.setApplicationEnabledSetting(
                    packageName,
                    PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                    PackageManager.DONT_KILL_APP
                )

                goToHome()
            } else {
                showUninstallDialog(packageName)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Try alternative method
            try {
                // Disable all components of the app
                val pm = packageManager
                val components = pm.getPackageInfo(packageName, PackageManager.GET_ACTIVITIES).activities

                components?.forEach { component ->
                    pm.setComponentEnabledSetting(
                        ComponentName(packageName, component.name),
                        PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                        PackageManager.DONT_KILL_APP
                    )
                }

                Toast.makeText(this, "App components disabled!", Toast.LENGTH_SHORT).show()
                goToHome()
            } catch (ex: Exception) {
                showUninstallDialog(packageName)
            }
        }
    }

    // Last resort - show uninstall dialog
    private fun showUninstallDialog(packageName: String) {
        try {
            val intent = Intent(Intent.ACTION_DELETE)
            intent.data = Uri.parse("package:$packageName")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(intent)

            Toast.makeText(this,
                "Please confirm uninstall to complete security action",
                Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Failed to uninstall app", Toast.LENGTH_SHORT).show()
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
        // Don't allow back press
        goToHome()
    }
}
