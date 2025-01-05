import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class Logger {
  static void log(String message, {LogLevel level = LogLevel.info, Object? error, StackTrace? stackTrace}) {
    if (!kReleaseMode) {
      final timestamp = DateTime.now().toIso8601String();
      final prefix = '[${level.name.toUpperCase()}] $timestamp:';
      
      switch (level) {
        case LogLevel.debug:
          debugPrint('$prefix $message');
          break;
        case LogLevel.info:
          debugPrint('$prefix $message');
          break;
        case LogLevel.warning:
          debugPrint('$prefix $message');
          if (error != null) debugPrint('Error: $error');
          if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
          break;
        case LogLevel.error:
          debugPrint('$prefix $message');
          if (error != null) debugPrint('Error: $error');
          if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
          // In production, you would send this to a crash reporting service
          break;
      }
    }
  }

  static void d(String message) => log(message, level: LogLevel.debug);
  static void i(String message) => log(message, level: LogLevel.info);
  static void w(String message, {Object? error, StackTrace? stackTrace}) => 
      log(message, level: LogLevel.warning, error: error, stackTrace: stackTrace);
  static void e(String message, {Object? error, StackTrace? stackTrace}) => 
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
}
