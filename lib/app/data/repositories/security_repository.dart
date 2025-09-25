import '../../export.dart';
class SecurityRepository {
  final StorageService storageService;
  final SecurityService securityService;

  SecurityRepository({
    required this.storageService,
    required this.securityService,
  });

  Future<bool> setPassword(String password) async {
    String hashedPassword = securityService.hashPassword(password);
    return await storageService.setString(
      AppConstants.passwordKey,
      hashedPassword,
    );
  }

  Future<String?> getPassword() async {
    return await storageService.getString(AppConstants.passwordKey);
  }

  Future<bool> verifyPassword(String inputPassword) async {
    String? storedPassword = await getPassword();
    if (storedPassword == null) return false;
    return securityService.verifyPassword(inputPassword, storedPassword);
  }

  Future<int> getFailedAttempts() async {
    return await storageService.getInt(AppConstants.failedAttemptsKey) ?? 0;
  }

  Future<bool> incrementFailedAttempts() async {
    int current = await getFailedAttempts();
    return await storageService.setInt(
      AppConstants.failedAttemptsKey,
      current + 1,
    );
  }

  Future<bool> resetFailedAttempts() async {
    return await storageService.setInt(AppConstants.failedAttemptsKey, 0);
  }

  Future<void> handleMaxFailedAttempts() async {
    await securityService.simulateFactoryReset();
    await storageService.clear();
  }
}