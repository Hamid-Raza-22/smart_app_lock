import '../../export.dart';
class AppInfoModel {
  final String id;
  final String name;
  final String packageName;
  final Uint8List? iconData; // Changed from iconPath to iconData
  final String versionName;
  final int versionCode;
  final String dataDir;
  final bool systemApp;
  final DateTime installTime;
  final DateTime updateTime;
  bool isLocked;
  bool canUninstall;

  AppInfoModel({
    required this.id,
    required this.name,
    required this.packageName,
    this.iconData,
    this.versionName = '',
    this.versionCode = 0,
    this.dataDir = '',
    this.systemApp = false,
    DateTime? installTime,
    DateTime? updateTime,
    this.isLocked = false,
    this.canUninstall = true,
  }) : installTime = installTime ?? DateTime.now(),
        updateTime = updateTime ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'packageName': packageName,
      'versionName': versionName,
      'versionCode': versionCode,
      'systemApp': systemApp,
      'isLocked': isLocked,
      'canUninstall': canUninstall,
      'installTime': installTime.toIso8601String(),
      'updateTime': updateTime.toIso8601String(),
    };
  }

  factory AppInfoModel.fromJson(Map<String, dynamic> json) {
    return AppInfoModel(
      id: json['id'],
      name: json['name'],
      packageName: json['packageName'],
      versionName: json['versionName'] ?? '',
      versionCode: json['versionCode'] ?? 0,
      systemApp: json['systemApp'] ?? false,
      isLocked: json['isLocked'] ?? false,
      canUninstall: json['canUninstall'] ?? true,
      installTime: json['installTime'] != null
          ? DateTime.parse(json['installTime'])
          : DateTime.now(),
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : DateTime.now(),
    );
  }

  AppInfoModel copyWith({
    bool? isLocked,
    bool? canUninstall,
  }) {
    return AppInfoModel(
      id: id,
      name: name,
      packageName: packageName,
      iconData: iconData,
      versionName: versionName,
      versionCode: versionCode,
      dataDir: dataDir,
      systemApp: systemApp,
      installTime: installTime,
      updateTime: updateTime,
      isLocked: isLocked ?? this.isLocked,
      canUninstall: canUninstall ?? this.canUninstall,
    );
  }
}