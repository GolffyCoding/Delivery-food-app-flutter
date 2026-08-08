import 'package:flutter/foundation.dart';
import 'package:opendelivery_core/opendelivery_core.dart';

/// Crash reporting service.
/// NOTE: logs to [AppLogger] instead of Firebase Crashlytics, since that
/// requires a real Firebase project. Swap the body for `firebase_crashlytics`
/// calls once `google-services.json` is available.
class CrashlyticsService {
  const CrashlyticsService();

  void initialize() {
    FlutterError.onError = (errorDetails) {
      AppLogger.error(errorDetails.summary.toString(), error: errorDetails.exception, stackTrace: errorDetails.stack, tag: 'Crashlytics');
    };
  }

  void recordError(Object error, StackTrace? stack, {bool fatal = false}) {
    AppLogger.error('recordError (fatal=$fatal)', error: error, stackTrace: stack, tag: 'Crashlytics');
  }

  void setUserId(String id) {
    AppLogger.debug('crashlytics user: $id', tag: 'Crashlytics');
  }

  void log(String message) {
    AppLogger.debug(message, tag: 'Crashlytics');
  }
}
