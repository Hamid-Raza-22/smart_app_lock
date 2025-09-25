class ApiEndpoints {
  // Prevent instantiation
  ApiEndpoints._();

  static const String baseUrl = 'https://api.applock.com';
  static const String apiVersion = '/v1';

  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String logout = '$apiVersion/auth/logout';
  static const String refreshToken = '$apiVersion/auth/refresh';

  // User endpoints
  static const String userProfile = '$apiVersion/user/profile';
  static const String updateProfile = '$apiVersion/user/update';

  // App endpoints
  static const String appList = '$apiVersion/apps/list';
  static const String appDetails = '$apiVersion/apps/details';

  // Security endpoints
  static const String reportIncident = '$apiVersion/security/report';
  static const String getSecurityStatus = '$apiVersion/security/status';
}