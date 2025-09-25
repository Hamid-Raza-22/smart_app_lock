package com.smart_app_lock.smart_app_lock
import android.app.*
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat

class AppLockService : Service() {

    private lateinit var handler: Handler
    private lateinit var usageStatsManager: UsageStatsManager
    private lateinit var prefs: SharedPreferences
    private var lastPackageName = ""
    private val checkInterval = 100L // Check every 100ms for better response

    private val checkRunnable = object : Runnable {
        override fun run() {
            checkRunningApp()
            handler.postDelayed(this, checkInterval)
        }
    }

    override fun onCreate() {
        super.onCreate()
        handler = Handler(Looper.getMainLooper())
        usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        prefs = getSharedPreferences("app_lock_prefs", Context.MODE_PRIVATE)
        startForeground(1, createNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        handler.removeCallbacks(checkRunnable)
        handler.post(checkRunnable)
        return START_STICKY // Service will restart if killed
    }

    override fun onDestroy() {
        super.onDestroy()
        handler.removeCallbacks(checkRunnable)

        // Restart service if it gets killed
        val restartServiceIntent = Intent(applicationContext, AppLockService::class.java)
        val restartServicePendingIntent = PendingIntent.getService(
            this, 1, restartServiceIntent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_ONE_SHOT
            }
        )
        val alarmService = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmService.set(
            AlarmManager.ELAPSED_REALTIME,
            System.currentTimeMillis() + 1000,
            restartServicePendingIntent
        )
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotification(): Notification {
        val channelId = "app_lock_service"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "App Lock Protection",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Protecting your locked apps"
                setShowBadge(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }

        val intent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        )

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("App Lock Active")
            .setContentText("Your apps are protected")
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }

    private fun checkRunningApp() {
        val currentTime = System.currentTimeMillis()
        val beginTime = currentTime - 10000 // Check last 10 seconds

        try {
            val usageEvents = usageStatsManager.queryEvents(beginTime, currentTime)
            val event = UsageEvents.Event()
            var recentPackage = ""

            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)

                if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND ||
                    event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                    recentPackage = event.packageName
                }
            }

            if (recentPackage.isNotEmpty() && recentPackage != lastPackageName &&
                recentPackage != packageName) {
                lastPackageName = recentPackage

                if (isAppLocked(recentPackage)) {
                    // App is locked, show password screen
                    showLockScreen(recentPackage)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun isAppLocked(packageName: String): Boolean {
        val lockedApps = prefs.getStringSet("locked_apps", emptySet()) ?: emptySet()
        return lockedApps.contains(packageName)
    }

    private fun showLockScreen(lockedPackage: String) {
        // Return to home first
        val homeIntent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(homeIntent)

        // Then show lock screen
        val intent = Intent(this, LockScreenActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_NO_HISTORY or
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
            putExtra("locked_package", lockedPackage)
        }
        startActivity(intent)
    }
}