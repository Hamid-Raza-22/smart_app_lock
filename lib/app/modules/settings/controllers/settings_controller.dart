import '../../../export.dart';

class SettingsController extends GetxController {
  final SecurityRepository _securityRepository = Get.find<SecurityRepository>();
  final StorageService _storageService = Get.find<StorageService>();

  final RxBool hasPassword = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPasswordStatus();
  }

  Future<void> checkPasswordStatus() async {
    String? password = await _securityRepository.getPassword();
    hasPassword.value = password != null;
  }

  Future<void> changePassword() async {
    Get.toNamed('/password-setup');
  }

  Future<void> resetPassword() async {
    Get.dialog(
      AlertDialog(
        title: Text('Reset Password'),
        content: Text('Are you sure you want to reset the password? This will also reset all app settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.clear();
              Get.find<HomeController>().onInit();
              Get.back();
              Get.snackbar(
                'Success',
                'Password and settings have been reset',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            },
            child: Text('Reset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> clearAllData() async {
    Get.dialog(
      AlertDialog(
        title: Text('Clear All Data'),
        content: Text('This will remove all settings and protected apps. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _storageService.clear();
              Get.find<HomeController>().onInit();
              Get.offAllNamed('/');
            },
            child: Text('Clear'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}