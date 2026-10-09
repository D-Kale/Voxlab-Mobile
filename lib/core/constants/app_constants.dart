class AppConstants {
  AppConstants._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://tvoxlab.tech/api/v1',
  );

  static const int defaultPageSize = 20;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String secureStorageKeyToken = 'voxlab_token';
  static const String secureStorageKeyLocalProgress = 'voxlab_local_progress';

  static const String appName = 'Voxlab';
  static const String appTagline = 'Domina el arte de hablar en público';
}
