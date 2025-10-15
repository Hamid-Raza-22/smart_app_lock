import '../../export.dart';
class AppRepository {
  final PlatformService _platformService = Get.find<PlatformService>();

  // Get real installed apps from device
  Future<List<AppInfoModel>> getInstalledApps() async {
    return await _platformService.getInstalledApps();
  }

  // Open app
  Future<bool> openApp(String packageName) async {
    return await _platformService.openApp(packageName);
  }

  // Check if app is installed
  Future<bool> isAppInstalled(String packageName) async {
    return await _platformService.isAppInstalled(packageName);
  }

  // Uninstall app
  Future<bool> uninstallApp(String packageName) async {
    await _platformService.allowUninstall(packageName);
    return true;
  }

  // Prevent uninstall
  Future<bool> preventUninstall(String packageName) async {
    await _platformService.preventUninstall(packageName);
    return true;
  }

  // Allow uninstall
  Future<bool> allowUninstall(String packageName) async {
    await _platformService.allowUninstall(packageName);
    return true;
  }

  // Lock app
  Future<bool> lockApp(String packageName) async {
    await _platformService.lockApp(packageName);
    return true;
  }

  // Unlock app
  Future<bool> unlockApp(String packageName) async {
    await _platformService.unlockApp(packageName);
    return true;
  }

  // Open app settings
  Future<bool> openAppSettings(String packageName) async {
    return await _platformService.openAppSettings(packageName);
  }
}