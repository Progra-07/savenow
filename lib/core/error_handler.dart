import 'package:flutter/foundation.dart'; // For kDebugMode
import 'dart:developer' as developer; // For log

class ErrorHandler {
  static void recordError(Object error, StackTrace? stackTrace,
      {String? reason}) {
    // Log to console (useful for development)
    if (kDebugMode) {
      developer.log(
        'Caught error: $error',
        name: 'ErrorHandler',
        error: error,
        stackTrace: stackTrace,
      );
      if (reason != null) {
        developer.log('Reason: $reason', name: 'ErrorHandler');
      }
    }

    // In a production app, you would send this to a remote logging service
    // For example, Sentry, Firebase Crashlytics, etc.
    // Sentry.captureException(error, stackTrace: stackTrace);
  }

  static void logInfo(String message, {String name = 'Info'}) {
    if (kDebugMode) {
      developer.log(message, name: name);
    }
  }

  // You can also add a global error handler for Flutter errors
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      recordError(details.exception, details.stack,
          reason: 'FlutterError.onError');
    };

    // For errors that occur outside of the Flutter framework (e.g., in async functions)
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack, reason: 'PlatformDispatcher.instance.onError');
      return true; // Return true to indicate that the error has been handled
    };

    ErrorHandler.logInfo('Error handler initialized', name: 'ErrorHandler');
  }
}
