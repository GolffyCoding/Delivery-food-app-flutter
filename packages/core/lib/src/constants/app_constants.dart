final class AppConstants {
  const AppConstants._();

  static const String appName = 'OpenDelivery';
  static const String appVersion = '1.0.0';

  static const int maxCartItemQuantity = 99;
  static const int minSearchQueryLength = 2;
  static const int searchDebounceMs = 300;
  static const int paginationPageSize = 20;
  static const int otpLength = 6;
  static const int otpResendCooldownSeconds = 60;
  static const int maxAddressLength = 200;
  static const double defaultDeliveryRadiusKm = 10.0;
  static const double minimumOrderAmount = 10.0;
  static const double freeDeliveryThreshold = 25.0;
  static const double deliveryFee = 3.99;
  static const double serviceFee = 1.99;
  static const List<double> driverTipOptions = [1.0, 2.0, 3.0, 5.0];
}
