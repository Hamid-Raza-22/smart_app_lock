package com.smart_app_lock.smart_app_lock

import android.app.AppOpsManager
import android.app.PendingIntent
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.DataOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.applock/platform"
    private lateinit var devicePolicyManager: DevicePolicyManager
    private lateinit var componentName: ComponentName

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        devicePolicyManager = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        componentName = ComponentName(this, DeviceAdminReceiver::class.java)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startLockService" -> {
                    startLockService()
                    result.success(true)
                }
                "stopLockService" -> {
                    stopLockService()
                    result.success(true)
                }
                "isServiceRunning" -> {
                    result.success(isServiceRunning())
                }
                "isUsageStatsGranted" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsageStats" -> {
                    requestUsageStatsPermission()
                    result.success(null)
                }
                "isAccessibilityGranted" -> {
                    result.success(isAccessibilityServiceEnabled())
                }
                "requestAccessibility" -> {
                    requestAccessibilityPermission()
                    result.success(null)
                }
                "isDeviceAdmin" -> {
                    result.success(devicePolicyManager.isAdminActive(componentName))
                }
                "isDeviceOwner" -> {
                    result.success(devicePolicyManager.isDeviceOwnerApp(packageName))
                }
                "enableDeviceAdmin" -> {
                    enableDeviceAdmin()
                    result.success(null)
                }
                "enableDeviceOwner" -> {
                    enableDeviceOwner()
                    result.success(null)
                }
                "lockApp" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        lockApp(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "unlockApp" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        unlockApp(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "hideApp" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        hideApp(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "preventUninstall" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        preventUninstall(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "allowUninstall" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        allowUninstall(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "silentUninstall" -> {
                    val packageName = call.argument<String>("package")
                    if (packageName != null) {
                        silentUninstall(packageName)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                "savePassword" -> {
                    val password = call.argument<String>("password")
                    if (password != null) {
                        savePassword(password)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Password is required", null)
                    }
                }
                "checkRoot" -> {
                    result.success(isRootAvailable())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Auto-start service
        startLockService()
    }

    private fun startLockService() {
        val intent = Intent(this, AppLockService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopLockService() {
        val intent = Intent(this, AppLockService::class.java)
        stopService(intent)
    }

    private fun isServiceRunning(): Boolean {
        val manager = getSystemService(Context.ACTIVITY_SERVICE) as android.app.ActivityManager
        for (service in manager.getRunningServices(Integer.MAX_VALUE)) {
            if (AppLockService::class.java.name == service.service.className) {
                return true
            }
        }
        return false
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val accessibilityEnabled = Settings.Secure.getInt(
            contentResolver,
            Settings.Secure.ACCESSIBILITY_ENABLED, 0
        )
        if (accessibilityEnabled == 1) {
            val services = Settings.Secure.getString(
                contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
            )
            return services?.contains(packageName) ?: false
        }
        return false
    }

    private fun requestAccessibilityPermission() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
    }

    private fun enableDeviceAdmin() {
        if (!devicePolicyManager.isAdminActive(componentName)) {
            val intent = Intent(DevicePolicyManager.ACTION_ADD_DEVICE_ADMIN)
            intent.putExtra(DevicePolicyManager.EXTRA_DEVICE_ADMIN, componentName)
            intent.putExtra(DevicePolicyManager.EXTRA_ADD_EXPLANATION,
                "App Lock needs device admin permission to protect your apps")
            startActivityForResult(intent, 1)
        }
    }

    private fun enableDeviceOwner() {
        // This requires ADB command:
        // adb shell dpm set-device-owner com.example.app_lock/.DeviceAdminReceiver
        try {
            if (!devicePolicyManager.isDeviceOwnerApp(packageName)) {
                // Show instructions to user
                val instructions = """
                    To enable full control:
                    1. Enable Developer Options
                    2. Enable USB Debugging
                    3. Connect to PC and run:
                    adb shell dpm set-device-owner ${applicationContext.packageName}/.DeviceAdminReceiver
                """.trimIndent()

                Toast.makeText(this, instructions, Toast.LENGTH_LONG).show()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun lockApp(packageName: String) {
        val prefs = getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf()) ?: mutableSetOf()
        lockedApps.add(packageName)
        prefs.edit().putStringSet("locked_apps", lockedApps).apply()

        startLockService()
    }

    private fun unlockApp(packageName: String) {
        val prefs = getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        val lockedApps = prefs.getStringSet("locked_apps", mutableSetOf()) ?: mutableSetOf()
        lockedApps.remove(packageName)
        prefs.edit().putStringSet("locked_apps", lockedApps).apply()
    }

    private fun hideApp(packageName: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
                devicePolicyManager.isDeviceOwnerApp(getPackageName())) {
                devicePolicyManager.setApplicationHidden(componentName, packageName, true)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun preventUninstall(packageName: String) {
        if (devicePolicyManager.isAdminActive(componentName)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                try {
                    devicePolicyManager.setUninstallBlocked(componentName, packageName, true)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun allowUninstall(packageName: String) {
        if (devicePolicyManager.isAdminActive(componentName)) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                try {
                    devicePolicyManager.setUninstallBlocked(componentName, packageName, false)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
        }
    }

    private fun silentUninstall(packageName: String) {
        when {
            isRootAvailable() -> uninstallWithRoot(packageName)
            devicePolicyManager.isDeviceOwnerApp(getPackageName()) -> uninstallAsDeviceOwner(packageName)
            else -> {
                // Fallback to uninstall dialog
                val intent = Intent(Intent.ACTION_DELETE)
                intent.data = Uri.parse("package:$packageName")
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivity(intent)
            }
        }
    }

    private fun isRootAvailable(): Boolean {
        return try {
            val process = Runtime.getRuntime().exec("su")
            process.destroy()
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun uninstallWithRoot(packageName: String) {
        try {
            val process = Runtime.getRuntime().exec("su")
            val os = DataOutputStream(process.outputStream)
            os.writeBytes("pm uninstall $packageName\n")
            os.writeBytes("exit\n")
            os.flush()
            os.close()
            process.waitFor()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun uninstallAsDeviceOwner(packageName: String) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                val packageInstaller = packageManager.packageInstaller
                // Create a PendingIntent for the uninstall callback
                val intent = Intent("${applicationContext.packageName}.ACTION_UNINSTALL_STATUS")
                val pendingIntent = PendingIntent.getBroadcast(
                    applicationContext, 
                    0, 
                    intent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                packageInstaller.uninstall(packageName, pendingIntent.intentSender)
            } else {
                 // For older versions, this method might not be available or might behave differently.
                 // Consider falling back to showUninstallDialog or another method.
                Toast.makeText(this, "Silent uninstall as device owner is not fully supported on this Android version. Please uninstall manually if needed.", Toast.LENGTH_LONG).show()
                 val uninstallIntent = Intent(Intent.ACTION_DELETE)
                 uninstallIntent.data = Uri.parse("package:$packageName")
                 uninstallIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                 startActivity(uninstallIntent)
            }
        } catch (e: SecurityException) {
            e.printStackTrace()
            Toast.makeText(this, "Uninstall permission denied for $packageName", Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            e.printStackTrace()
            Toast.makeText(this, "Failed to uninstall $packageName as device owner", Toast.LENGTH_SHORT).show()
        }
    }

    private fun savePassword(password: String) {
        val prefs = getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        prefs.edit().putString("app_password", password).apply()
    }
}
