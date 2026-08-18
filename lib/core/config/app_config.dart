/// Application configuration handling environment variables and API endpoints.
class AppConfig {
  AppConfig._();

  static const String appName = 'Movie Scout';

  /// Base URL for TVMaze API (100% Free & Open, no API key required)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.tvmaze.com',
  );

  /// Default timeout durations
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Always true since TVMaze API does not require authentication
  static bool get isApiKeyConfigured => true;
}
