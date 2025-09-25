import '../../../export.dart';

class PasswordVerifyController extends GetxController {
  final SecurityRepository _securityRepository = Get.find<SecurityRepository>();

  final passwordController = TextEditingController();
  final RxBool isPasswordVisible = false.obs;
  final RxInt failedAttempts = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  late AppInfoModel app;

  @override
  void onInit() {
    super.onInit();
    app = Get.arguments as AppInfoModel;
    loadFailedAttempts();
  }

  Future<void> loadFailedAttempts() async {
    failedAttempts.value = await _securityRepository.getFailedAttempts();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> verifyPassword() async {
    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter password';
      return;
    }

    isLoading.value = true;
    try {
      bool isValid = await _securityRepository.verifyPassword(
        passwordController.text,
      );

      if (isValid) {
        // Reset failed attempts
        await _securityRepository.resetFailedAttempts();

        Get.back();
        Get.snackbar(
          'Access Granted',
          'Opening ${app.name}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Increment failed attempts
        await _securityRepository.incrementFailedAttempts();
        failedAttempts.value++;

        int remaining = AppConstants.maxFailedAttempts - failedAttempts.value;

        if (failedAttempts.value >= AppConstants.maxFailedAttempts) {
          // Trigger factory reset
          await showFactoryResetDialog();
        } else {
          errorMessage.value = 'Incorrect password. $remaining attempts remaining';
        }

        passwordController.clear();
      }
    } catch (e) {
      errorMessage.value = 'An error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> showFactoryResetDialog() async {
    Get.dialog(
      AlertDialog(
        title: Text(
          'SECURITY ALERT',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning, color: Colors.red, size: 50),
            SizedBox(height: 16),
            Text(
              'Maximum failed attempts reached!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Device will be factory reset in 5 seconds...',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    // Countdown before reset
    for (int i = 5; i > 0; i--) {
      await Future.delayed(Duration(seconds: 1));
    }

    // Trigger factory reset
    await _securityRepository.handleMaxFailedAttempts();

    Get.offAllNamed('/');
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}