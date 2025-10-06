import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductionLogger {
  static const String _logFileName = 'production_logs.txt';
  static const int _maxLogSize = 1024 * 1024; // 1MB
  static const int _maxLogEntries = 1000;

  static final List<String> _logBuffer = [];
  static bool _isInitialized = false;
  static String? _deviceId;
  static String? _userId;

  /// **INITIALIZE PRODUCTION LOGGER**
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Get device ID
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString('device_id') ?? 'unknown_device';

      // Create log file
      await _createLogFile();

      // Start periodic log upload
      _startPeriodicUpload();

      _isInitialized = true;
      _log('PRODUCTION_LOGGER', 'Initialized successfully', 'INFO');
    } catch (e) {
      print('[PRODUCTION_LOGGER] Initialization failed: $e');
    }
  }

  /// **LOG WITH DIFFERENT LEVELS**
  static void log(String tag, String message, String level) {
    _log(tag, message, level);
  }

  static void info(String tag, String message) {
    _log(tag, message, 'INFO');
  }

  static void warning(String tag, String message) {
    _log(tag, message, 'WARNING');
  }

  static void error(String tag, String message, [dynamic error]) {
    _log(tag, '$message${error != null ? ' - Error: $error' : ''}', 'ERROR');
  }

  static void debug(String tag, String message) {
    if (kDebugMode) {
      _log(tag, message, 'DEBUG');
    }
  }

  /// **INTERNAL LOGGING METHOD**
  static void _log(String tag, String message, String level) {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] [$level] [$tag] $message';

      // Add to buffer
      _logBuffer.add(logEntry);

      // Keep buffer size manageable
      if (_logBuffer.length > _maxLogEntries) {
        _logBuffer.removeRange(0, _logBuffer.length - _maxLogEntries);
      }

      // Write to file
      _writeToFile(logEntry);

      // Also print to console for immediate visibility
      print(logEntry);
    } catch (e) {
      print('[PRODUCTION_LOGGER] Error logging: $e');
    }
  }

  /// **CREATE LOG FILE**
  static Future<void> _createLogFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      if (!await logFile.exists()) {
        await logFile.create();
        await logFile.writeAsString('=== PRODUCTION LOGS STARTED ===\n');
      }
    } catch (e) {
      print('[PRODUCTION_LOGGER] Error creating log file: $e');
    }
  }

  /// **WRITE TO LOG FILE**
  static Future<void> _writeToFile(String logEntry) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      // Check file size
      final exists = await logFile.exists();
      if (exists) {
        final fileSize = await logFile.length();
        if (fileSize > _maxLogSize) {
          // Rotate log file
          final backupFile =
              File('${directory.path}/production_logs_backup.txt');
          final backupExists = await backupFile.exists();
          if (backupExists) {
            await backupFile.delete();
          }
          await logFile.rename('${directory.path}/production_logs_backup.txt');
          await logFile.create();
          await logFile.writeAsString('=== LOG ROTATED ===\n');
        }
      }

      // Append log entry
      await logFile.writeAsString('$logEntry\n', mode: FileMode.append);
    } catch (e) {
      print('[PRODUCTION_LOGGER] Error writing to log file: $e');
    }
  }

  /// **UPLOAD LOGS TO REMOTE SERVICE**
  static Future<void> uploadLogs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      final exists = await logFile.exists();
      if (!exists) return;

      final logContent = await logFile.readAsString();
      if (logContent.isEmpty) return;

      // Upload to your backend or logging service
      final dio = Dio();
      await dio.post(
        'https://jippymart.in/api/logs/upload',
        data: {
          'device_id': _deviceId,
          'user_id': _userId,
          'app_version': '2.2.1',
          'platform': Platform.isAndroid ? 'android' : 'ios',
          'logs': logContent,
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      _log('PRODUCTION_LOGGER', 'Logs uploaded successfully', 'INFO');
    } catch (e) {
      _log('PRODUCTION_LOGGER', 'Failed to upload logs: $e', 'ERROR');
    }
  }

  /// **START PERIODIC UPLOAD**
  static void _startPeriodicUpload() {
    // Upload logs every 30 minutes
    Future.delayed(const Duration(minutes: 30), () {
      uploadLogs();
      _startPeriodicUpload(); // Schedule next upload
    });
  }

  /// **SET USER ID FOR LOGGING**
  static void setUserId(String userId) {
    _userId = userId;
    _log('PRODUCTION_LOGGER', 'User ID set: $userId', 'INFO');
  }

  /// **GET LOG FILE PATH**
  static Future<String?> getLogFilePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');
      final exists = await logFile.exists();
      return exists ? logFile.path : null;
    } catch (e) {
      return null;
    }
  }

  /// **CLEAR LOGS**
  static Future<void> clearLogs() async {
    try {
      _logBuffer.clear();
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');
      final exists = await logFile.exists();
      if (exists) {
        await logFile.delete();
      }
      await _createLogFile();
      _log('PRODUCTION_LOGGER', 'Logs cleared', 'INFO');
    } catch (e) {
      print('[PRODUCTION_LOGGER] Error clearing logs: $e');
    }
  }

  /// **GET LOG STATISTICS**
  static Future<Map<String, dynamic>> getLogStats() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/$_logFileName');

      final exists = await logFile.exists();
      if (!exists) {
        return {'error': 'Log file not found'};
      }

      final fileSize = await logFile.length();
      final logContent = await logFile.readAsString();
      final lines =
          logContent.split('\n').where((line) => line.isNotEmpty).length;

      return {
        'file_size_bytes': fileSize,
        'file_size_mb': (fileSize / (1024 * 1024)).toStringAsFixed(2),
        'log_entries': lines,
        'buffer_entries': _logBuffer.length,
        'device_id': _deviceId,
        'user_id': _userId,
        'is_initialized': _isInitialized,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
