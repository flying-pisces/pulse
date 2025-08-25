import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration utility class
/// Provides access to environment variables with fallback defaults
class EnvConfig {
  // Private constructor to prevent instantiation
  EnvConfig._();

  // Alpaca API Configuration
  static String get alpacaApiKey => dotenv.env['ALPACA_API_KEY'] ?? '';
  static String get alpacaSecretKey => dotenv.env['ALPACA_SECRET_KEY'] ?? '';
  static String get alpacaBaseUrl => 
      dotenv.env['ALPACA_BASE_URL'] ?? 'https://paper-api.alpaca.markets';
  static String get alpacaWsUrl => 
      dotenv.env['ALPACA_WS_URL'] ?? 'wss://stream.data.alpaca.markets/v2/iex';

  // PocketBase Configuration
  static String get pocketbaseUrl => dotenv.env['POCKETBASE_URL'] ?? 'http://localhost:8090';
  static String get pocketbaseAdminEmail => dotenv.env['POCKETBASE_ADMIN_EMAIL'] ?? '';
  static String get pocketbaseAdminPassword => dotenv.env['POCKETBASE_ADMIN_PASSWORD'] ?? '';

  // Database Configuration - Using PocketBase only

  // Google OAuth Configuration
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleClientSecret => dotenv.env['GOOGLE_CLIENT_SECRET'] ?? '';

  // Apple OAuth Configuration
  static String get appleServiceId => dotenv.env['APPLE_SERVICE_ID'] ?? '';
  static String get appleTeamId => dotenv.env['APPLE_TEAM_ID'] ?? '';
  static String get appleKeyId => dotenv.env['APPLE_KEY_ID'] ?? '';

  // App Environment
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';
  static bool get isDevelopment => appEnv == 'development';
  static bool get isStaging => appEnv == 'staging';
  static bool get isProduction => appEnv == 'production';

  // Firebase Configuration
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  // Additional API Keys
  static String get alphaVantageApiKey => dotenv.env['ALPHA_VANTAGE_API_KEY'] ?? '';
  static String get polygonApiKey => dotenv.env['POLYGON_API_KEY'] ?? '';

  // Validation methods
  static bool get hasAlpacaCredentials => 
      alpacaApiKey.isNotEmpty && alpacaSecretKey.isNotEmpty;
  
  static bool get hasPocketbaseCredentials => 
      pocketbaseUrl.isNotEmpty;
  
  static bool get hasPocketbaseAdminCredentials => 
      pocketbaseAdminEmail.isNotEmpty && pocketbaseAdminPassword.isNotEmpty;
  
  // Using PocketBase for all database operations
  
  static bool get hasGoogleOAuthCredentials => 
      googleClientId.isNotEmpty;
  
  static bool get hasAppleOAuthCredentials => 
      appleServiceId.isNotEmpty && appleTeamId.isNotEmpty && appleKeyId.isNotEmpty;

  static bool get hasFirebaseCredentials => 
      firebaseProjectId.isNotEmpty && firebaseApiKey.isNotEmpty;

  // Debug helper to check configuration status
  static Map<String, bool> get configurationStatus => {
    'alpaca_credentials': hasAlpacaCredentials,
    'pocketbase_credentials': hasPocketbaseCredentials,
    'pocketbase_admin': hasPocketbaseAdminCredentials,
    'google_oauth': hasGoogleOAuthCredentials,
    'apple_oauth': hasAppleOAuthCredentials,
    'firebase': hasFirebaseCredentials,
  };

  // Get configuration summary (useful for debugging)
  static Map<String, dynamic> get configSummary => {
    'app_env': appEnv,
    'alpaca_base_url': alpacaBaseUrl,
    'alpaca_ws_url': alpacaWsUrl,
    'pocketbase_url': pocketbaseUrl,
    'has_alpaca_credentials': hasAlpacaCredentials,
    'has_pocketbase_credentials': hasPocketbaseCredentials,
    'has_pocketbase_admin': hasPocketbaseAdminCredentials,
    'has_google_oauth': hasGoogleOAuthCredentials,
    'has_apple_oauth': hasAppleOAuthCredentials,
    'has_firebase': hasFirebaseCredentials,
    'has_alpha_vantage': alphaVantageApiKey.isNotEmpty,
    'has_polygon': polygonApiKey.isNotEmpty,
  };

  /// Validate required environment variables for different features
  static List<String> validateRequiredConfig({
    bool requireAlpaca = false,
    bool requirePocketBase = false,
    bool requirePocketBaseAdmin = false,
    bool requireGoogleOAuth = false,
    bool requireAppleOAuth = false,
    bool requireFirebase = false,
  }) {
    final missing = <String>[];

    if (requireAlpaca && !hasAlpacaCredentials) {
      missing.addAll(['ALPACA_API_KEY', 'ALPACA_SECRET_KEY']);
    }

    if (requirePocketBase && !hasPocketbaseCredentials) {
      missing.add('POCKETBASE_URL');
    }

    if (requirePocketBaseAdmin && !hasPocketbaseAdminCredentials) {
      missing.addAll(['POCKETBASE_ADMIN_EMAIL', 'POCKETBASE_ADMIN_PASSWORD']);
    }

    if (requireGoogleOAuth && !hasGoogleOAuthCredentials) {
      missing.add('GOOGLE_CLIENT_ID');
    }

    if (requireAppleOAuth && !hasAppleOAuthCredentials) {
      missing.addAll(['APPLE_SERVICE_ID', 'APPLE_TEAM_ID', 'APPLE_KEY_ID']);
    }

    if (requireFirebase && !hasFirebaseCredentials) {
      missing.addAll(['FIREBASE_PROJECT_ID', 'FIREBASE_API_KEY']);
    }

    return missing;
  }

  /// Check if we should use real market data based on credentials
  static bool get shouldUseRealMarketData => hasAlpacaCredentials && !isDevelopment;

  /// Get the appropriate data source configuration
  static Map<String, dynamic> get marketDataConfig => {
    'use_real_data': shouldUseRealMarketData,
    'api_key': shouldUseRealMarketData ? alpacaApiKey : null,
    'secret_key': shouldUseRealMarketData ? alpacaSecretKey : null,
    'base_url': alpacaBaseUrl,
    'ws_url': alpacaWsUrl,
  };
}