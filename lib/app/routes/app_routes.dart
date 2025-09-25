part of 'app_pages.dart';
abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const PASSWORD_SETUP = _Paths.PASSWORD_SETUP;
  static const PASSWORD_VERIFY = _Paths.PASSWORD_VERIFY;
  static const SETTINGS = _Paths.SETTINGS;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/';
  static const PASSWORD_SETUP = '/password-setup';
  static const PASSWORD_VERIFY = '/password-verify';
  static const SETTINGS = '/settings';
}