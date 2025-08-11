class AppConstants {
  // App Info
  static const String appName = 'Stock Signal';
  static const String appTagline = 'AI Trading Alert';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.stocksignal.ai';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String storagePrefix = 'stock_signal_';
  static const String authTokenKey = '${storagePrefix}auth_token';
  static const String refreshTokenKey = '${storagePrefix}refresh_token';
  static const String userDataKey = '${storagePrefix}user_data';
  static const String onboardingCompletedKey = '${storagePrefix}onboarding_completed';
  static const String themeKey = '${storagePrefix}theme';
  static const String notificationsEnabledKey = '${storagePrefix}notifications_enabled';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 16.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Signal Configuration
  static const int maxFreeSignals = 3;
  static const int signalsPerPageBasic = 20;
  static const int signalsPerPagePremium = 50;
  static const Duration signalRefreshInterval = Duration(minutes: 5);
  
  // Subscription Limits
  static const Map<String, int> tierLimits = {
    'free_signals_per_day': 3,
    'basic_signals_per_day': 20,
    'premium_signals_per_day': 100,
    'pro_signals_per_day': -1, // Unlimited
  };
  
  // Watchlist Configuration
  static const int maxWatchlistItems = 50;
  static const Duration priceUpdateInterval = Duration(seconds: 30);
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authenticationError = 'Please log in to continue.';
  static const String subscriptionRequiredError = 'This feature requires a subscription.';
  
  // Success Messages
  static const String signalAddedToWatchlist = 'Added to watchlist successfully';
  static const String profileUpdated = 'Profile updated successfully';
  static const String passwordChanged = 'Password changed successfully';
  
  // URLs
  static const String privacyPolicyUrl = 'https://stocksignal.ai/privacy';
  static const String termsOfServiceUrl = 'https://stocksignal.ai/terms';
  static const String supportUrl = 'https://stocksignal.ai/support';
  
  // Firebase Configuration
  static const String firebaseProjectId = 'stock-signal-ai';
  static const String fcmTopicAllUsers = 'all_users';
  static const String fcmTopicSignalUpdates = 'signal_updates';
}