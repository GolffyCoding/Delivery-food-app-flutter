import 'dart:developer' as developer;

/// Application-wide logger.
final class AppLogger {
  const AppLogger._();

  static void debug(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'OpenDelivery', level: 500);
  }

  static void info(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'OpenDelivery', level: 800);
  }

  static void warning(String message, {String? tag}) {
    developer.log(message, name: tag ?? 'OpenDelivery', level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    developer.log(
      message,
      name: tag ?? 'OpenDelivery',
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
