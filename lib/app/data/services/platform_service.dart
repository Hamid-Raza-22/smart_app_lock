import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../export.dart';

class PlatformService {
  static const platform = MethodChannel('com.applock/platform');
  static bool _serviceRunning = false;

  // Initialize service on app start
  Future<void> initializeService() async {
    await _requestPermissions();
    await enableDeviceAdmin();
    await startMonitoringService();
  }

  // Start background monitoring service
  Future<void> startMonitoringService() async {
    if (_serviceRunning) return;

    try {
      // Start native background service
      await platform.invokeMethod('startLockService');
      _serviceRunning = true;

      // For overlay permission
      if (await FlutterOverlayWindow.isPermissionGranted() == false) {
        await FlutterOverlayWindow.requestPermission();
      }

      debugPrint('Background monitoring service started');
    } on PlatformException catch (e) {
      debugPrint('Failed to start monitoring service: ${e.message}');
    }
  }

  // Stop monitoring service
  Future<void> stopMonitoringService() async {
    try {
      await platform.invokeMethod('stopLockService');
      _serviceRunning = false;
      debugPrint('Background monitoring service stopped');
    } on PlatformException catch (e) {
      debugPrint('Failed to stop monitoring service: ${e.message}');
    }
  }

  // Check if service is running
  Future<bool> isServiceRunning() async {
    try {
      final result = await platform.invokeMethod('isServiceRunning');
      return result as bool;
    } on PlatformException catch (e) {
      debugPrint('Failed to check service status: ${e.message}');
      return false;
    }
  }

  // Get all installed apps
  Future<List<AppInfoModel>> getInstalledApps() async {
    try {
      await _requestPermissions();

      List<Application> apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true,
      );

      List<AppInfoModel> appList = [];
      for (Application app in apps) {
        Uint8List? iconData;
        if (app is ApplicationWithIcon) {
          iconData = app.icon;
        }

        appList.add(AppInfoModel(
          id: app.packageName,
          name: app.appName,
          packageName: app.packageName,
          iconData: iconData,
          versionName: app.versionName ?? '',
          versionCode: app.versionCode ?? 0,
          dataDir: app.dataDir ?? '',
          systemApp: app.systemApp,
          installTime: app.installTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(app.installTimeMillis!)
              : DateTime.now(),
          updateTime: app.updateTimeMillis != null
              ? DateTime.fromMillisecondsSinceEpoch(app.updateTimeMillis!)
              : DateTime.now(),
        ));
      }

      appList.sort((a, b) => a.name.compareTo(b.name));
      return appList;
    } catch (e) {
      debugPrint('Error getting installed apps: $e');
      return [];
    }
  }

  // Request all necessary permissions
  Future<void> _requestPermissions() async {
    // Basic permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.systemAlertWindow,
    ].request();

    // Usage stats permission (needs manual grant)
    final usageStatsGranted = await isUsageStatsPermissionGranted();
    if (!usageStatsGranted) {
      await requestUsageStatsPermission();
    }

    // Accessibility permission (needs manual grant)
    final accessibilityGranted = await isAccessibilityPermissionGranted();
    if (!accessibilityGranted) {
      await requestAccessibilityPermission();
    }
  }

  // Check usage stats permission
  Future<bool> isUsageStatsPermissionGranted() async {
    try {
      final result = await platform.invokeMethod('isUsageStatsGranted');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Request usage stats permission
  Future<void> requestUsageStatsPermission() async {
    try {
      await platform.invokeMethod('requestUsageStats');
   } on PlatformException catch (e) {
      debugPrint('Failed to request usage stats: ${e.message}');
    }
  }

  // Check accessibility permission
  Future<bool> isAccessibilityPermissionGranted() async {
    try {
      final result = await platform.invokeMethod('isAccessibilityGranted');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Request accessibility permission
  Future<void> requestAccessibilityPermission() async {
    try {
      await platform.invokeMethod('requestAccessibility');
    } on PlatformException catch (e) {
      debugPrint('Failed to request accessibility: ${e.message}');
    }
  }

  // Open specific app
  Future<bool> openApp(String packageName) async {
    try {
      return await DeviceApps.openApp(packageName);
    } catch (e) {
      debugPrint('Error opening app: $e');
      return false;
    }
  }

  // Check if app is installed
  Future<bool> isAppInstalled(String packageName) async {
    try {
      return await DeviceApps.isAppInstalled(packageName);
    } catch (e) {
      debugPrint('Error checking app installation: $e');
      return false;
    }
  }

  // Get app info
  Future<Application?> getAppInfo(String packageName) async {
    try {
      return await DeviceApps.getApp(packageName, true);
    } catch (e) {
      debugPrint('Error getting app info: $e');
      return null;
    }
  }

  // Uninstall app (opens system uninstall dialog)
  Future<bool> uninstallApp(String packageName) async {
    try {
      // For protected apps after 3 failed attempts
      await platform.invokeMethod('forceUninstall', {'package': packageName});
      return true;
    } catch (e) {
      // Fallback to normal uninstall
      return await DeviceApps.uninstallApp(packageName);
    }
  }

  // Open app settings
  Future<bool> openAppSettings(String packageName) async {
    try {
      return await DeviceApps.openAppSettings(packageName);
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  // Enable device admin
  Future<void> enableDeviceAdmin() async {
    try {
      final isAdmin = await platform.invokeMethod('isDeviceAdmin');
      if (!isAdmin) {
        await platform.invokeMethod('enableDeviceAdmin');
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to enable device admin: ${e.message}');
    }
  }

  // Lock app
  Future<void> lockApp(String packageName) async {
    try {
      await platform.invokeMethod('lockApp', {'package': packageName});
      // Ensure service is running
      await startMonitoringService();
    } on PlatformException catch (e) {
      debugPrint('Failed to lock app: ${e.message}');
    }
  }

  // Unlock app
  Future<void> unlockApp(String packageName) async {
    try {
      await platform.invokeMethod('unlockApp', {'package': packageName});
    } on PlatformException catch (e) {
      debugPrint('Failed to unlock app: ${e.message}');
    }
  }

  // Prevent uninstall
  Future<void> preventUninstall(String packageName) async {
    try {
      await platform.invokeMethod('preventUninstall', {'package': packageName});
    } on PlatformException catch (e) {
      debugPrint('Failed to prevent uninstall: ${e.message}');
    }
  }

  // Allow uninstall
  Future<void> allowUninstall(String packageName) async {
    try {
      await platform.invokeMethod('allowUninstall', {'package': packageName});
    } on PlatformException catch (e) {
      debugPrint('Failed to allow uninstall: ${e.message}');
    }
  }

  // Factory reset or uninstall locked app after failed attempts
  Future<void> handleSecurityBreach(String packageName) async {
    try {
      // First try to uninstall the specific app
      await platform.invokeMethod('securityBreach', {'package': packageName});
    } on PlatformException catch (e) {
      debugPrint('Failed to handle security breach: ${e.message}');
    }
  }
}