
import '../../export.dart';
class UserPreferences {
  final ThemeMode themeMode;
  final String language;
  final bool biometricEnabled;
  final int autoLockDuration;
  final bool notificationsEnabled;

  UserPreferences({
    this.themeMode = ThemeMode.light,
    this.language = 'en',
    this.biometricEnabled = false,
    this.autoLockDuration = 0,
    this.notificationsEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'biometricEnabled': biometricEnabled,
      'autoLockDuration': autoLockDuration,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      language: json['language'] ?? 'en',
      biometricEnabled: json['biometricEnabled'] ?? false,
      autoLockDuration: json['autoLockDuration'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  UserPreferences copyWith({
    ThemeMode? themeMode,
    String? language,
    bool? biometricEnabled,
    int? autoLockDuration,
    bool? notificationsEnabled,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}