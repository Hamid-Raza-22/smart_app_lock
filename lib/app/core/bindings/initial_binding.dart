
import '../../export.dart';
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<SecurityService>(() => SecurityService(), fenix: true);

    // Repositories
    Get.lazyPut<AppRepository>(() => AppRepository(), fenix: true);
    Get.lazyPut<SecurityRepository>(() => SecurityRepository(
      storageService: Get.find<StorageService>(),
      securityService: Get.find<SecurityService>(),
    ), fenix: true);
    Get.lazyPut(()=>PlatformService(), fenix: true);
  }
}