import '../export.dart';
part 'app_routes.dart';
class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PASSWORD_SETUP,
      page: () => PasswordSetupView(),
      binding: PasswordBinding(),
    ),
    GetPage(
      name: _Paths.PASSWORD_VERIFY,
      page: () => PasswordVerifyView(),
      binding: PasswordBinding(),
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}