/// Endpoint map for the real OpenDelivery backend.
/// See: OpenDelivery API Reference.
final class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'http://localhost:8080/api/v1';
  static const String wsBaseUrl = 'ws://localhost:8080';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  static const String idempotencyKeyHeader = 'Idempotency-Key';

  // --- Auth ---
  static const String authPrefix = '/auth';
  static const String register = '$authPrefix/register';
  static const String login = '$authPrefix/login';
  static const String refreshToken = '$authPrefix/refresh';
  static const String logout = '$authPrefix/logout';
  static const String me = '$authPrefix/me';
  static const String verifyEmail = '$authPrefix/verify-email';
  static const String forgotPassword = '$authPrefix/forgot-password';
  static const String resetPassword = '$authPrefix/reset-password';

  // --- Restaurants ---
  static const String restaurants = '/restaurants/';
  static const String restaurantsFeatured = '/restaurants/featured';
  static const String restaurantsNearby = '/restaurants/nearby';
  static const String restaurantsSearch = '/restaurants/search';
  static const String restaurantsMy = '/restaurants/my';
  static String restaurantById(String id) => '/restaurants/$id';
  static String restaurantReviews(String id) => '/restaurants/$id/reviews/';
  static String restaurantReviewSummary(String id) => '/restaurants/$id/reviews/summary';
  static String restaurantReviewReply(String restaurantId, String reviewId) => '/restaurants/$restaurantId/reviews/$reviewId/reply';

  // --- Menu ---
  static String menuCategories(String restaurantId) => '/restaurants/$restaurantId/menu/categories';
  static String menuItems(String restaurantId) => '/restaurants/$restaurantId/menu/items';
  static String menuItemById(String id) => '/menu-items/$id';
  static String menuItemVariants(String id) => '/menu-items/$id/variants';
  static String menuItemAddons(String id) => '/menu-items/$id/addons';

  // --- Orders ---
  static const String orders = '/orders/';
  static String orderById(String id) => '/orders/$id';
  static String orderByNumber(String number) => '/orders/number/$number';
  static String orderCancel(String id) => '/orders/$id/cancel';
  static String orderStatus(String id) => '/orders/$id/status';
  static String restaurantOrders(String restaurantId) => '/restaurants/$restaurantId/orders/';
  static String restaurantOrdersPending(String restaurantId) => '/restaurants/$restaurantId/orders/pending';
  static String restaurantOrdersCount(String restaurantId) => '/restaurants/$restaurantId/orders/count';
  static String adminOrderStatus(String id) => '/admin/orders/$id/status';

  // --- Driver orders ---
  static const String driverOrders = '/driver/orders/';
  static String driverOrderAccept(String id) => '/driver/orders/$id/accept';
  static String driverOrderStatus(String id) => '/driver/orders/$id/status';

  // --- Drivers ---
  static const String driverRegister = '/drivers/register';
  static const String driverMe = '/drivers/me';
  static const String driverOnline = '/drivers/online';
  static const String driverOffline = '/drivers/offline';
  static const String driverLocation = '/drivers/location';
  static const String driverEarnings = '/drivers/earnings';
  static const String driverNearest = '/drivers/nearest';

  // --- Tracking ---
  static const String trackingEta = '/tracking/eta';
  static const String trackingLocation = '/tracking/location';

  // --- Payments / Wallet / Coupons ---
  static const String payments = '/payments/';
  static String paymentByOrder(String orderId) => '/payments/order/$orderId';
  static const String wallet = '/wallet/';
  static const String walletTopup = '/wallet/topup';
  static const String walletTransactions = '/wallet/transactions';
  static const String adminCoupons = '/admin/coupons/';
  static const String coupons = '/coupons/';
  static const String couponsValidate = '/coupons/validate';

  // --- Reviews / Notifications ---
  static const String reviews = '/reviews/';
  static const String notifications = '/notifications/';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static String notificationRead(String id) => '/notifications/$id/read';

  // --- Admin ---
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminSystemHealth = '/admin/system/health';

  // --- Realtime ---
  static const String ws = '/ws';
}
