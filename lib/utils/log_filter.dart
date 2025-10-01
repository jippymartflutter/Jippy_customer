import 'package:flutter/foundation.dart';

class LogFilter {
  static const bool _enableDebugLogs = true;
  static const bool _enableSystemLogs = false;
  
  /// Filter and log only relevant messages
  static void log(String tag, String message, {String? level}) {
    if (!_enableDebugLogs) return;
    
    final timestamp = DateTime.now().toString().split('.')[0];
    final logLevel = level ?? 'INFO';
    
    // Only log app-specific messages, filter out system noise
    if (_shouldLog(message)) {
      print('[$timestamp] [$logLevel] [$tag] $message');
    }
  }
  
  /// Check if message should be logged (filter out system noise)
  static bool _shouldLog(String message) {
    // Always log app-specific messages
    if (message.contains('[MART') || 
        message.contains('[FLUTTER') ||
        message.contains('ERROR') ||
        message.contains('WARNING')) {
      return true;
    }
    
    // Filter out system noise
    if (message.contains('HWUI') ||
        message.contains('mapper.ranchu') ||
        message.contains('System.*failed to call close') ||
        message.contains('MPEG4Writer') ||
        message.contains('CCodec') ||
        message.contains('GraphicBufferSource') ||
        message.contains('SR_VideoCaptureHandler') ||
        message.contains('AssetManager2')) {
      return _enableSystemLogs;
    }
    
    return true;
  }
  
  /// Log error with stack trace
  static void logError(String tag, String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_enableDebugLogs) return;
    
    final timestamp = DateTime.now().toString().split('.')[0];
    print('[$timestamp] [ERROR] [$tag] $message');
    
    if (error != null) {
      print('[$timestamp] [ERROR] [$tag] Error: $error');
    }
    
    if (stackTrace != null) {
      print('[$timestamp] [ERROR] [$tag] Stack trace: $stackTrace');
    }
  }
  
  /// Log warning
  static void logWarning(String tag, String message) {
    log(tag, message, level: 'WARNING');
  }
  
  /// Log info
  static void logInfo(String tag, String message) {
    log(tag, message, level: 'INFO');
  }
  
  /// Log debug
  static void logDebug(String tag, String message) {
    if (kDebugMode) {
      log(tag, message, level: 'DEBUG');
    }
  }
}
