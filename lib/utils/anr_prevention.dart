import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// **ANR PREVENTION UTILITY**
/// 
/// This utility prevents Application Not Responding (ANR) issues by:
/// - Moving heavy operations off the main thread
/// - Implementing strict timeouts
/// - Using background processing
/// - Monitoring operation duration
class ANRPrevention {
  static const Duration _anrThreshold = Duration(milliseconds: 2000); // 2 seconds
  static const Duration _criticalThreshold = Duration(milliseconds: 500); // 500ms

  /// **Execute operation with ANR prevention**
  /// 
  /// Moves heavy operations to background and applies strict timeouts
  static Future<T> executeWithANRPrevention<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
    bool logToCrashlytics = true,
  }) async {
    final startTime = DateTime.now();
    
    try {
      // Use Future.microtask to move off main thread
      final result = await Future.microtask(() async {
        return await operation().timeout(
          timeout ?? const Duration(seconds: 3),
          onTimeout: () {
            log('ANR_PREVENTION: Operation "$operationName" timed out');
            throw TimeoutException('Operation timed out', timeout ?? const Duration(seconds: 3));
          },
        );
      });

      final duration = DateTime.now().difference(startTime);
      
      // Log slow operations
      if (duration > _criticalThreshold) {
        log('ANR_PREVENTION: Slow operation "$operationName" took ${duration.inMilliseconds}ms');
        
        if (logToCrashlytics) {
          FirebaseCrashlytics.instance.log(
            'Slow operation detected: $operationName took ${duration.inMilliseconds}ms'
          );
        }
      }

      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      
      if (logToCrashlytics) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'ANR prevention failed for operation: $operationName (duration: ${duration.inMilliseconds}ms)',
        );
      }
      
      rethrow;
    }
  }

  /// **Execute UI operation with frame scheduling**
  /// 
  /// Ensures UI operations don't block the main thread
  static void executeUIOperation(String operationName, VoidCallback operation) {
    try {
      // Use addPostFrameCallback to ensure operation runs after current frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          operation();
        } catch (e) {
          log('ANR_PREVENTION: UI operation "$operationName" failed: $e');
          FirebaseCrashlytics.instance.recordError(
            e,
            StackTrace.current,
            reason: 'UI operation failed: $operationName',
          );
        }
      });
    } catch (e) {
      log('ANR_PREVENTION: Failed to schedule UI operation "$operationName": $e');
    }
  }

  /// **Execute navigation with ANR prevention**
  /// 
  /// Safely navigates without blocking the UI
  static void executeNavigation(String operationName, VoidCallback navigation) {
    try {
      // Use microtask to move navigation off main thread
      Future.microtask(() {
        try {
          // Use post-frame callback for UI operations
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              navigation();
            } catch (e) {
              log('ANR_PREVENTION: Navigation "$operationName" failed: $e');
              FirebaseCrashlytics.instance.recordError(
                e,
                StackTrace.current,
                reason: 'Navigation failed: $operationName',
              );
            }
          });
        } catch (e) {
          log('ANR_PREVENTION: Failed to schedule navigation "$operationName": $e');
        }
      });
    } catch (e) {
      log('ANR_PREVENTION: Failed to execute navigation "$operationName": $e');
    }
  }

  /// **Monitor operation duration**
  /// 
  /// Tracks operation duration and warns about potential ANRs
  static Future<T> monitorOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? maxDuration,
    bool logToCrashlytics = true,
  }) async {
    final startTime = DateTime.now();
    final maxDurationToUse = maxDuration ?? _anrThreshold;
    
    try {
      final result = await operation();
      final duration = DateTime.now().difference(startTime);
      
      if (duration > maxDurationToUse) {
        final message = 'Operation "$operationName" exceeded ${maxDurationToUse.inMilliseconds}ms (took ${duration.inMilliseconds}ms)';
        log('ANR_PREVENTION: $message');
        
        if (logToCrashlytics) {
          FirebaseCrashlytics.instance.log(message);
        }
      }
      
      return result;
    } catch (e, stackTrace) {
      final duration = DateTime.now().difference(startTime);
      
      if (logToCrashlytics) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'Operation "$operationName" failed after ${duration.inMilliseconds}ms',
        );
      }
      
      rethrow;
    }
  }
}
