class SecuritySettings {
  final bool passwordEnabled;
  final bool biometricEnabled;
  final int maxFailedAttempts;
  final bool autoResetEnabled;
  final int autoLockDuration;
  final DateTime? lastPasswordChange;
  final List<String> trustedDevices;

  SecuritySettings({
    this.passwordEnabled = false,
    this.biometricEnabled = false,
    this.maxFailedAttempts = 3,
    this.autoResetEnabled = true,
    this.autoLockDuration = 0,
    this.lastPasswordChange,
    this.trustedDevices = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'passwordEnabled': passwordEnabled,
      'biometricEnabled': biometricEnabled,
      'maxFailedAttempts': maxFailedAttempts,
      'autoResetEnabled': autoResetEnabled,
      'autoLockDuration': autoLockDuration,
      'lastPasswordChange': lastPasswordChange?.toIso8601String(),
      'trustedDevices': trustedDevices,
    };
  }

  factory SecuritySettings.fromJson(Map<String, dynamic> json) {
    return SecuritySettings(
      passwordEnabled: json['passwordEnabled'] ?? false,
      biometricEnabled: json['biometricEnabled'] ?? false,
      maxFailedAttempts: json['maxFailedAttempts'] ?? 3,
      autoResetEnabled: json['autoResetEnabled'] ?? true,
      autoLockDuration: json['autoLockDuration'] ?? 0,
      lastPasswordChange: json['lastPasswordChange'] != null
          ? DateTime.parse(json['lastPasswordChange'])
          : null,
      trustedDevices: List<String>.from(json['trustedDevices'] ?? []),
    );
  }
}