class StorageKeys {
  // Prevent instantiation
  StorageKeys._();

  // User preferences
  static const String theme = 'theme_mode';
  static const String language = 'app_language';
  static const String firstLaunch = 'first_launch';

  // Security
  static const String password = 'app_password';
  static const String biometricEnabled = 'biometric_enabled';
  static const String lastLogin = 'last_login';
  static const String failedAttempts = 'failed_attempts';

  // App settings
  static const String appMode = 'app_mode';
  static const String selectedApps = 'selected_apps';
  static const String lockedApps = 'locked_apps';
  static const String autoLockDuration = 'auto_lock_duration';

  // Statistics
  static const String totalUnlocks = 'total_unlocks';
  static const String totalBlocks = 'total_blocks';
  static const String lastResetDate = 'last_reset_date';
}