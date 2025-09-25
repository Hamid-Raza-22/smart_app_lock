enum AppMode {
  normal,
  advanced,
}

extension AppModeExtension on AppMode {
  String get name {
    switch (this) {
      case AppMode.normal:
        return 'Normal Mode';
      case AppMode.advanced:
        return 'Advanced Mode';
    }
  }

  String get description {
    switch (this) {
      case AppMode.normal:
        return 'Control which apps can be uninstalled';
      case AppMode.advanced:
        return 'Password protect apps with security features';
    }
  }
}