
import '../../../export.dart';

class PasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PasswordSetupController>(() => PasswordSetupController(), fenix: true);
    Get.lazyPut<PasswordVerifyController>(() => PasswordVerifyController(), fenix: true);
  }
}