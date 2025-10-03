import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';

/// **COMPREHENSIVE CRASH PREVENTION SYSTEM**
///
/// This utility prevents app crashes by:
/// - Managing memory pressure
/// - Preventing ANR (Application Not Responding)
/// - Rate limiting operations
/// - Graceful error handling
/// - Automatic recovery mechanisms
class CrashPrevention {
  static final CrashPrevention _instance = CrashPrevention._internal();
  factory CrashPrevention() => _instance;
  CrashPrevention._internal();

  // **MEMORY MANAGEMENT**
  static const int _maxMemoryOperations = 10;
  static const Duration _memoryCooldown = Duration(seconds: 2);
  int _currentMemoryOperations = 0;
  DateTime? _lastMemoryReset;

  // **RATE LIMITING**
  static const Duration _operationCooldown = Duration(milliseconds: 500);
  final Map<String, DateTime> _lastOperationTimes = {};

  // **ANR PREVENTION**
  static const Duration _anrThreshold = Duration(milliseconds: 300);
  final Map<String, Timer> _operationTimers = {};

  // **ERROR RECOVERY**
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 3;
  DateTime? _lastErrorTime;
  static const Duration _errorCooldown = Duration(seconds: 5);

  /// **SAFE OPERATION EXECUTOR**
  ///
  /// Executes operations with crash prevention measures
  static Future<T> safeExecute<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
    bool allowRetry = true,
  }) async {
    final instance = CrashPrevention();
    return instance._safeExecuteInternal(
      operationName,
      operation,
      timeout: timeout,
      allowRetry: allowRetry,
    );
  }

  /// **MEMORY-SAFE OPERATION**
  ///
  /// Ensures operations don't exceed memory limits
  static Future<T> memorySafeExecute<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    final instance = CrashPrevention();
    return instance._memorySafeExecuteInternal(
      operationName,
      operation,
      timeout: timeout,
    );
  }

  /// **RATE-LIMITED OPERATION**
  ///
  /// Prevents rapid successive operations
  static Future<T> rateLimitedExecute<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? cooldown,
  }) async {
    final instance = CrashPrevention();
    return instance._rateLimitedExecuteInternal(
      operationName,
      operation,
      cooldown: cooldown,
    );
  }

  /// **DEEP LINK SAFE PROCESSING**
  ///
  /// Special handling for deep link operations
  static Future<void> safeDeepLinkProcess(
    String deepLinkUrl,
    Future<void> Function() processFunction,
  ) async {
    final instance = CrashPrevention();
    await instance._safeDeepLinkProcessInternal(
      deepLinkUrl,
      processFunction,
    );
  }

  /// **CLEANUP RESOURCES**
  ///
  /// Call this when app is closing or memory is low
  static void cleanup() {
    final instance = CrashPrevention();
    instance._cleanup();
  }

  /// **GET SYSTEM STATUS**
  ///
  /// Returns current system health status
  static Map<String, dynamic> getSystemStatus() {
    final instance = CrashPrevention();
    return instance._getSystemStatus();
  }

  // **INTERNAL IMPLEMENTATION**

  Future<T> _safeExecuteInternal<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
    bool allowRetry = true,
  }) async {
    try {
      // Check if we're in error recovery mode
      if (_isInErrorRecoveryMode()) {
        log('CRASH_PREVENTION: In error recovery mode, skipping operation: $operationName');
        throw Exception('System in error recovery mode');
      }

      // Check memory pressure
      if (_isMemoryPressureHigh()) {
        log('CRASH_PREVENTION: Memory pressure high, delaying operation: $operationName');
        await Future.delayed(_memoryCooldown);
      }

      // Execute with timeout
      final result = await operation().timeout(
        timeout ?? const Duration(seconds: 10),
        onTimeout: () {
          log('CRASH_PREVENTION: Operation timeout: $operationName');
          throw TimeoutException('Operation timed out: $operationName');
        },
      );

      // Reset error count on success
      _consecutiveErrors = 0;
      return result;
    } catch (e) {
      _handleError(operationName, e);

      if (allowRetry && _consecutiveErrors < _maxConsecutiveErrors) {
        log('CRASH_PREVENTION: Retrying operation: $operationName');
        await Future.delayed(Duration(milliseconds: 500 * _consecutiveErrors));
        return _safeExecuteInternal(operationName, operation,
            timeout: timeout, allowRetry: false);
      }

      rethrow;
    }
  }

  Future<T> _memorySafeExecuteInternal<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    // Check memory limits
    if (_currentMemoryOperations >= _maxMemoryOperations) {
      log('CRASH_PREVENTION: Memory limit reached, waiting for cooldown');
      await _waitForMemoryCooldown();
    }

    _currentMemoryOperations++;
    try {
      final result = await operation().timeout(
        timeout ?? const Duration(seconds: 5),
      );
      return result;
    } finally {
      _currentMemoryOperations--;
    }
  }

  Future<T> _rateLimitedExecuteInternal<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? cooldown,
  }) async {
    final now = DateTime.now();
    final lastTime = _lastOperationTimes[operationName];
    final cooldownDuration = cooldown ?? _operationCooldown;

    if (lastTime != null && now.difference(lastTime) < cooldownDuration) {
      final waitTime = cooldownDuration - now.difference(lastTime);
      log('CRASH_PREVENTION: Rate limiting operation: $operationName, waiting ${waitTime.inMilliseconds}ms');
      await Future.delayed(waitTime);
    }

    _lastOperationTimes[operationName] = now;
    return await operation();
  }

  Future<void> _safeDeepLinkProcessInternal(
    String deepLinkUrl,
    Future<void> Function() processFunction,
  ) async {
    try {
      log('CRASH_PREVENTION: Processing deep link: $deepLinkUrl');

      // Rate limit deep link processing
      await _rateLimitedExecuteInternal(
        'deep_link_processing',
        processFunction,
        cooldown: const Duration(milliseconds: 1000),
      );

      log('CRASH_PREVENTION: Deep link processed successfully: $deepLinkUrl');
    } catch (e) {
      log('CRASH_PREVENTION: Deep link processing failed: $deepLinkUrl - $e');
      // Don't rethrow for deep links - they should fail gracefully
    }
  }

  bool _isInErrorRecoveryMode() {
    if (_consecutiveErrors >= _maxConsecutiveErrors) {
      final now = DateTime.now();
      if (_lastErrorTime != null &&
          now.difference(_lastErrorTime!) < _errorCooldown) {
        return true;
      } else {
        // Reset error recovery mode
        _consecutiveErrors = 0;
        _lastErrorTime = null;
      }
    }
    return false;
  }

  bool _isMemoryPressureHigh() {
    return _currentMemoryOperations >= (_maxMemoryOperations * 0.8).round();
  }

  Future<void> _waitForMemoryCooldown() async {
    final now = DateTime.now();
    if (_lastMemoryReset == null ||
        now.difference(_lastMemoryReset!) > _memoryCooldown) {
      _currentMemoryOperations = 0;
      _lastMemoryReset = now;
    } else {
      await Future.delayed(_memoryCooldown);
    }
  }

  void _handleError(String operationName, dynamic error) {
    _consecutiveErrors++;
    _lastErrorTime = DateTime.now();

    log('CRASH_PREVENTION: Error in operation: $operationName - $error');
    log('CRASH_PREVENTION: Consecutive errors: $_consecutiveErrors');

    if (kDebugMode) {
      print('CRASH_PREVENTION: Error details: $error');
    }
  }

  void _cleanup() {
    // Cancel all timers
    for (final timer in _operationTimers.values) {
      timer.cancel();
    }
    _operationTimers.clear();

    // Reset counters
    _currentMemoryOperations = 0;
    _consecutiveErrors = 0;
    _lastMemoryReset = null;
    _lastErrorTime = null;
    _lastOperationTimes.clear();

    log('CRASH_PREVENTION: Cleanup completed');
  }

  Map<String, dynamic> _getSystemStatus() {
    return {
      'memoryOperations': _currentMemoryOperations,
      'maxMemoryOperations': _maxMemoryOperations,
      'consecutiveErrors': _consecutiveErrors,
      'maxConsecutiveErrors': _maxConsecutiveErrors,
      'isInErrorRecovery': _isInErrorRecoveryMode(),
      'isMemoryPressureHigh': _isMemoryPressureHigh(),
      'lastErrorTime': _lastErrorTime?.toIso8601String(),
      'lastMemoryReset': _lastMemoryReset?.toIso8601String(),
    };
  }
}

/// **CRASH PREVENTION MIXIN**
///
/// Add this mixin to controllers that need crash prevention
mixin CrashPreventionMixin {
  final List<Timer> _crashPreventionTimers = [];
  final List<Completer<void>> _crashPreventionOperations = [];

  /// **SAFE CONTROLLER OPERATION**
  ///
  /// Wraps controller operations with crash prevention
  Future<T> safeControllerOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    return CrashPrevention.safeExecute(
      operationName,
      operation,
      timeout: timeout,
    );
  }

  /// **MEMORY-SAFE CONTROLLER OPERATION**
  ///
  /// For memory-intensive controller operations
  Future<T> memorySafeControllerOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    return CrashPrevention.memorySafeExecute(
      operationName,
      operation,
      timeout: timeout,
    );
  }

  /// **RATE-LIMITED CONTROLLER OPERATION**
  ///
  /// For operations that should be rate-limited
  Future<T> rateLimitedControllerOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? cooldown,
  }) async {
    return CrashPrevention.rateLimitedExecute(
      operationName,
      operation,
      cooldown: cooldown,
    );
  }

  /// **CLEANUP**
  ///
  /// Call this in onClose()
  void cleanupCrashPrevention() {
    for (final timer in _crashPreventionTimers) {
      timer.cancel();
    }
    _crashPreventionTimers.clear();

    for (final completer in _crashPreventionOperations) {
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled during cleanup');
      }
    }
    _crashPreventionOperations.clear();
  }
}

/// **DEEP LINK CRASH PREVENTION**
///
/// Special handling for deep link operations
class DeepLinkCrashPrevention {
  static final Map<String, DateTime> _lastDeepLinkTimes = {};
  static const Duration _deepLinkCooldown = Duration(milliseconds: 800);
  static int _consecutiveDeepLinkErrors = 0;
  static const int _maxConsecutiveDeepLinkErrors = 5;

  /// **SAFE DEEP LINK PROCESSING**
  ///
  /// Processes deep links with crash prevention
  static Future<void> safeProcessDeepLink(
    String deepLinkUrl,
    Future<void> Function() processFunction,
  ) async {
    try {
      // Check rate limiting
      final now = DateTime.now();
      final lastTime = _lastDeepLinkTimes[deepLinkUrl];

      if (lastTime != null && now.difference(lastTime) < _deepLinkCooldown) {
        log('DEEP_LINK_CRASH_PREVENTION: Rate limiting deep link: $deepLinkUrl');
        return;
      }

      // Check error recovery
      if (_consecutiveDeepLinkErrors >= _maxConsecutiveDeepLinkErrors) {
        log('DEEP_LINK_CRASH_PREVENTION: Too many consecutive errors, skipping: $deepLinkUrl');
        return;
      }

      _lastDeepLinkTimes[deepLinkUrl] = now;

      // Process with timeout
      await processFunction().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          log('DEEP_LINK_CRASH_PREVENTION: Deep link timeout: $deepLinkUrl');
          throw TimeoutException('Deep link processing timeout');
        },
      );

      // Reset error count on success
      _consecutiveDeepLinkErrors = 0;
      log('DEEP_LINK_CRASH_PREVENTION: Deep link processed successfully: $deepLinkUrl');
    } catch (e) {
      _consecutiveDeepLinkErrors++;
      log('DEEP_LINK_CRASH_PREVENTION: Deep link error: $deepLinkUrl - $e');

      // Don't rethrow - deep links should fail gracefully
    }
  }

  /// **CLEANUP DEEP LINK PREVENTION**
  ///
  /// Call this when app is closing
  static void cleanup() {
    _lastDeepLinkTimes.clear();
    _consecutiveDeepLinkErrors = 0;
    log('DEEP_LINK_CRASH_PREVENTION: Cleanup completed');
  }
}
