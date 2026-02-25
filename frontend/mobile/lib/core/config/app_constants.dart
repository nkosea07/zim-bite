class AppConstants {
  AppConstants._();

  static const String appName = 'ZimBite';
  static const Duration httpTimeout = Duration(seconds: 15);
  static const Duration deliveryPollInterval = Duration(seconds: 15);
  static const int otpLength = 6;
  static const String defaultCurrency = 'USD';
  static const String currencySymbol = '\$';
}
