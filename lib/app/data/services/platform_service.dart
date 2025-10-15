import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../export.dart';

class PlatformService {
  static const platform = MethodChannel('com.applock/platform');
  static bool _serviceRunning = false;

  // Initialize service
  Future<void> initializeService() async {
    await _requestPermissions();
    await enableDeviceAdmin();
    await checkAndRequestRoot();
    await startMonitoringService();
  }

  // Check and request root access
  Future<bool> checkAndRequestRoot() async {
    try {
      final hasRoot = await platform.invokeMethod('checkRoot');
      if (hasRoot) {
        print('✓ Root access available - Silent uninstall enabled');
        return true;
      } else {
        print('✗ No root access - Will use alternative methods');
        return false;
      }
    } catch (e) {
      print('Error checking root: $e');
      return false;
    }
  }

  // Check if device owner
  Future<bool> isDeviceOwner() async {
    try {
      final result = await platform.invokeMethod('isDeviceOwner');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Enable device owner (requires ADB)
  Future<void> enableDeviceOwner() async {
    try {
      await platform.invokeMethod('enableDeviceOwner');
    } catch (e) {
      print('Device owner setup requires ADB: $e');
    }
  }

  // Start background monitoring service
  Future<void> startMonitoringService() async {
    if (_serviceRunning) return;

    try {
      await platform.invokeMethod('startLockService');
      _serviceRunning = true;
      print('✓ Background monitoring service started');
    } on PlatformException catch (e) {
      print('Failed to start monitoring service: ${e.message}');
    }
  }

  // Stop monitoring service
  Future<void> stopMonitoringService() async {
    try {
      await platform.invokeMethod('stopLockService');
      _serviceRunning = false;
      print('Background monitoring service stopped');
    } on PlatformException catch (e) {
      print('Failed to stop monitoring service: ${e.message}');
    }
  }

  // Check if service is running
  Future<bool> isServiceRunning() async {
    try {
      final result = await platform.invokeMethod('isServiceRunning');
      return result as bool;
    } on PlatformException catch (e) {
      print('Failed to check service status: ${e.message}');
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
      print('Error getting installed apps: $e');
      return [];
    }
  }

  // Request all necessary permissions
  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.systemAlertWindow,
    ].request();

    final usageStatsGranted = await isUsageStatsPermissionGranted();
    if (!usageStatsGranted) {
      await requestUsageStatsPermission();
    }

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
    }on PlatformException catch (e) {
      print('Failed to request usage stats: ${e.message}');
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
    }on PlatformException catch (e) {
      print('Failed to request accessibility: ${e.message}');
    }
  }

  // Open specific app
  Future<bool> openApp(String packageName) async {
    try {
      return await DeviceApps.openApp(packageName);
    } catch (e) {
      print('Error opening app: $e');
      return false;
    }
  }

  // Silent uninstall (tries multiple methods)
  Future<bool> silentUninstall(String packageName) async {
    try {
      await platform.invokeMethod('silentUninstall', {'package': packageName});
      return true;
    } catch (e) {
      print('Silent uninstall failed, trying alternative: $e');
      return await hideApp(packageName);
    }
  }

  // Hide app (alternative to uninstall)
  Future<bool> hideApp(String packageName) async {
    try {
      await platform.invokeMethod('hideApp', {'package': packageName});
      return true;
    } catch (e) {
      print('Failed to hide app: $e');
      // Last resort - show uninstall dialog
      return await DeviceApps.uninstallApp(packageName);
    }
  }

  // Check if app is installed
  Future<bool> isAppInstalled(String packageName) async {
    try {
      return await DeviceApps.isAppInstalled(packageName);
    } catch (e) {
      print('Error checking app installation: $e');
      return false;
    }
  }

  // Get app info
  Future<Application?> getAppInfo(String packageName) async {
    try {
      return await DeviceApps.getApp(packageName, true);
    } catch (e) {
      print('Error getting app info: $e');
      return null;
    }
  }

  // Open app settings
  Future<bool> openAppSettings(String packageName) async {
    try {
      return await DeviceApps.openAppSettings(packageName);
    } catch (e) {
      print('Error opening app settings: $e');
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
      print('Failed to enable device admin: ${e.message}');
    }
  }

  // Lock app
  Future<void> lockApp(String packageName) async {
    try {
      await platform.invokeMethod('lockApp', {'package': packageName});
      await startMonitoringService();
    } on PlatformException catch (e) {
      print('Failed to lock app: ${e.message}');
    }
  }

  // Unlock app
  Future<void> unlockApp(String packageName) async {
    try {
      await platform.invokeMethod('unlockApp', {'package': packageName});
    } on PlatformException catch (e) {
      print('Failed to unlock app: ${e.message}');
    }
  }

  // Prevent uninstall
  Future<void> preventUninstall(String packageName) async {
    try {
      await platform.invokeMethod('preventUninstall', {'package': packageName});
    } on PlatformException catch (e) {
      print('Failed to prevent uninstall: ${e.message}');
    }
  }

  // Allow uninstall
  Future<void> allowUninstall(String packageName) async {
    try {
      await platform.invokeMethod('allowUninstall', {'package': packageName});
    } on PlatformException catch (e) {
      print('Failed to allow uninstall: ${e.message}');
    }
  }

  // Save password to native
  Future<void> savePassword(String password) async {
    try {
      await platform.invokeMethod('savePassword', {'password': password});
    } on PlatformException catch (e) {
      print('Failed to save password: ${e.message}');
    }
  }

  // Handle security breach (after 3 failed attempts)
  Future<void> handleSecurityBreach(String packageName) async {
    try {
      // Try silent uninstall first
      bool success = await silentUninstall(packageName);
      if (!success) {
        // If silent uninstall fails, at least hide the app
        await hideApp(packageName);
      }
    } on PlatformException catch (e) {
      print('Failed to handle security breach: ${e.message}');
    }
  }
}