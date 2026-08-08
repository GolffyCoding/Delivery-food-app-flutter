import 'package:opendelivery_core/opendelivery_core.dart';

/// Analytics event tracking service.
/// NOTE: logs to [AppLogger] instead of Firebase Analytics, since that
/// requires a real Firebase project. Swap the body of each method for a
/// `firebase_analytics` call once `google-services.json` is available.
class AnalyticsService {
  const AnalyticsService();

  Future<void> logScreenView({required String screenName, String? screenClass}) async {
    AppLogger.debug('screen_view: $screenName', tag: 'Analytics');
  }

  Future<void> logLogin({required String method}) async {
    AppLogger.debug('login: $method', tag: 'Analytics');
  }

  Future<void> logSignUp({required String method}) async {
    AppLogger.debug('sign_up: $method', tag: 'Analytics');
  }

  Future<void> logSearch({required String term}) async {
    AppLogger.debug('search: $term', tag: 'Analytics');
  }

  Future<void> logAddToCart({required String itemId, required String itemName, double? price, int quantity = 1}) async {
    AppLogger.debug('add_to_cart: $itemName x$quantity', tag: 'Analytics');
  }

  Future<void> logBeginCheckout({required double total, required int itemCount}) async {
    AppLogger.debug('begin_checkout: $total ($itemCount items)', tag: 'Analytics');
  }

  Future<void> logPurchase({required String orderId, required double total}) async {
    AppLogger.debug('purchase: $orderId \$$total', tag: 'Analytics');
  }

  Future<void> logCustomEvent({required String name, Map<String, Object>? parameters}) async {
    AppLogger.debug('$name: $parameters', tag: 'Analytics');
  }

  Future<void> setUserId({required String id}) async {
    AppLogger.debug('user_id: $id', tag: 'Analytics');
  }
}
