import '../../../export.dart';
class HomeController extends GetxController {
  // Make appRepository public so HomeView can access it
  final AppRepository appRepository = Get.find<AppRepository>();
  final SecurityRepository _securityRepository = Get.find<SecurityRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxList<AppInfoModel> installedApps = <AppInfoModel>[].obs;
  final RxList<AppInfoModel> filteredApps = <AppInfoModel>[].obs;
  final RxList<AppInfoModel> selectedApps = <AppInfoModel>[].obs;
  final Rx<AppMode> currentMode = AppMode.normal.obs;
  final RxBool isLoading = false.obs;
  final RxString password = ''.obs;
  final RxBool hasPassword = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissions();
    loadSettings();
  }

  // Check and request permissions
  Future<void> checkPermissions() async {
    // Request usage stats permission
    final status = await Permission.systemAlertWindow.status;
    if (!status.isGranted) {
      Get.dialog(
        AlertDialog(
          title: Text('Permission Required'),
          content: Text(
            'App Lock needs usage access permission to protect your apps. '
                'Please grant the permission in the next screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back();
                await Permission.systemAlertWindow.request();
                loadApps();
              },
              child: Text('Grant Permission'),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    } else {
      loadApps();
    }
  }

  // Load real installed apps
  Future<void> loadApps() async {
    isLoading.value = true;
    try {
      // Get real installed apps from device
      final apps = await appRepository.getInstalledApps();
      installedApps.value = apps;
      filteredApps.value = apps;

      // Load previously selected apps
      await loadSelectedApps();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load installed apps: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Search/filter apps
  void searchApps(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredApps.value = installedApps;
    } else {
      filteredApps.value = installedApps
          .where((app) =>
      app.name.toLowerCase().contains(query.toLowerCase()) ||
          app.packageName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // Load app settings
  Future<void> loadSettings() async {
    // Load current mode
    String? modeStr = await _storageService.getString(AppConstants.modeKey);
    if (modeStr != null) {
      currentMode.value = modeStr == 'advanced' ? AppMode.advanced : AppMode.normal;
    }

    // Check if password exists
    String? pwd = await _securityRepository.getPassword();
    hasPassword.value = pwd != null;
  }

  // Load selected apps
  Future<void> loadSelectedApps() async {
    List<String>? selectedPackages = await _storageService.getList(AppConstants.selectedAppsKey);
    if (selectedPackages != null) {
      selectedApps.value = installedApps
          .where((app) => selectedPackages.contains(app.packageName))
          .toList();

      // Apply locks/protections to selected apps
      for (var app in selectedApps) {
        if (currentMode.value == AppMode.normal) {
          await appRepository.preventUninstall(app.packageName);
        } else {
          await appRepository.lockApp(app.packageName);
        }
      }
    }
  }

  // Toggle app selection
  void toggleAppSelection(AppInfoModel app) async {
    if (selectedApps.any((a) => a.packageName == app.packageName)) {
      // Remove from selected
      selectedApps.removeWhere((a) => a.packageName == app.packageName);

      if (currentMode.value == AppMode.normal) {
        await appRepository.allowUninstall(app.packageName);
      } else {
        await appRepository.unlockApp(app.packageName);
      }
    } else {
      // Add to selected
      selectedApps.add(app);

      if (currentMode.value == AppMode.normal) {
        await appRepository.preventUninstall(app.packageName);
      } else {
        await appRepository.lockApp(app.packageName);
      }
    }

    await saveSelectedApps();
  }

  // Save selected apps
  Future<void> saveSelectedApps() async {
    List<String> packages = selectedApps.map((app) => app.packageName).toList();
    await _storageService.setList(AppConstants.selectedAppsKey, packages);
  }

  // Toggle protection mode
  Future<void> toggleMode(AppMode mode) async {
    if (mode == AppMode.advanced && !hasPassword.value) {
      // Navigate to password setup
      Get.toNamed(Routes.PASSWORD_SETUP);
      return;
    }

    // Switch protection type for all selected apps
    for (var app in selectedApps) {
      if (currentMode.value == AppMode.normal) {
        // Switching from normal to advanced
        await appRepository.allowUninstall(app.packageName);
        await appRepository.lockApp(app.packageName);
      } else {
        // Switching from advanced to normal
        await appRepository.unlockApp(app.packageName);
        await appRepository.preventUninstall(app.packageName);
      }
    }

    currentMode.value = mode;
    await _storageService.setString(
      AppConstants.modeKey,
      mode == AppMode.advanced ? 'advanced' : 'normal',
    );
  }

  // Open app or verify password
  void openApp(AppInfoModel app) async {
    if (currentMode.value == AppMode.advanced &&
        selectedApps.any((a) => a.packageName == app.packageName)) {
      // Navigate to password verification
      Get.toNamed(Routes.PASSWORD_VERIFY, arguments: app);
    } else {
      // Open app directly
      bool success = await appRepository.openApp(app.packageName);
      if (!success) {
        Get.snackbar(
          'Error',
          'Failed to open ${app.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  // Open app settings
  void openAppSettings(AppInfoModel app) async {
    await appRepository.openAppSettings(app.packageName);
  }

  // Refresh apps list
  Future<void> refreshApps() async {
    await loadApps();
  }

  // Set password
  Future<void> setPassword(String newPassword) async {
    await _securityRepository.setPassword(newPassword);
    password.value = newPassword;
    hasPassword.value = true;
  }
}
