import '../../../export.dart';

class PasswordSetupController extends GetxController {
  final SecurityRepository _securityRepository = Get.find<SecurityRepository>();
  final SecurityService _securityService = Get.find<SecurityService>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxString passwordError = ''.obs;
  final RxBool isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  bool validatePasswords() {
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (password.isEmpty) {
      passwordError.value = 'Password cannot be empty';
      return false;
    }

    if (!_securityService.isValidPassword(password)) {
      passwordError.value = 'Password must be at least 4 characters';
      return false;
    }

    if (password != confirmPassword) {
      passwordError.value = 'Passwords do not match';
      return false;
    }

    passwordError.value = '';
    return true;
  }

  Future<void> setPassword() async {
    if (!validatePasswords()) return;

    isLoading.value = true;
    try {
      await _securityRepository.setPassword(passwordController.text);

      // Update home controller
      final homeController = Get.find<HomeController>();
      await homeController.setPassword(passwordController.text);

      Get.snackbar(
        'Success',
        'Password has been set successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to set password',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}