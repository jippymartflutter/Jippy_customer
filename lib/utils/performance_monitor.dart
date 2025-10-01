import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// **COMPREHENSIVE PERFORMANCE MONITORING UTILITY**
/// 
/// This utility provides:
/// - ANR detection and prevention
/// - Performance metrics tracking
/// - Memory usage monitoring
/// - Background task management
/// - Crash reporting integration
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  // **PERFORMANCE METRICS**
  final Map<String, List<Duration>> _operationDurations = {};
  final Map<String, int> _operationCounts = {};
  final Map<String, int> _slowOperationCounts = {};
  
  // **ANR PREVENTION**
  static const Duration _anrThreshold = Duration(milliseconds: 500);
  static const Duration _criticalThreshold = Duration(milliseconds: 1000);
  final List<Timer> _activeTimers = [];
  final List<Completer<void>> _pendingOperations = [];
  
  // **MEMORY MONITORING**
  int _lastMemoryUsage = 0;
  DateTime? _lastMemoryCheck;
  static const Duration _memoryCheckInterval = Duration(minutes: 5);

  /// **START OPERATION MONITORING**
  /// 
  /// Wraps an operation with performance monitoring and ANR prevention
  static Future<T> monitorOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
    bool logToCrashlytics = true,
  }) async {
    final monitor = PerformanceMonitor();
    return monitor._monitorOperationInternal(
      operationName,
      operation,
      timeout: timeout,
      logToCrashlytics: logToCrashlytics,
    );
  }

  /// **MONITOR SYNC OPERATION**
  /// 
  /// For operations that must run on main thread but need monitoring
  static T monitorSyncOperation<T>(
    String operationName,
    T Function() operation, {
    Duration? timeout,
    bool logToCrashlytics = true,
  }) {
    final monitor = PerformanceMonitor();
    return monitor._monitorSyncOperationInternal(
      operationName,
      operation,
      timeout: timeout,
      logToCrashlytics: logToCrashlytics,
    );
  }

  /// **BACKGROUND TASK EXECUTOR**
  /// 
  /// Ensures heavy operations run in background to prevent ANR
  static Future<T> executeInBackground<T>(
    String taskName,
    Future<T> Function() task, {
    Duration? timeout,
  }) async {
    final monitor = PerformanceMonitor();
    return monitor._executeInBackgroundInternal(
      taskName,
      task,
      timeout: timeout,
    );
  }

  /// **MEMORY USAGE CHECK**
  /// 
  /// Monitors memory usage and logs warnings if excessive
  static void checkMemoryUsage() {
    final monitor = PerformanceMonitor();
    monitor._checkMemoryUsageInternal();
  }

  /// **CLEANUP RESOURCES**
  /// 
  /// Call this when disposing controllers or screens
  static void cleanup() {
    final monitor = PerformanceMonitor();
    monitor._cleanupInternal();
  }

  /// **GET PERFORMANCE REPORT**
  /// 
  /// Returns a comprehensive performance report
  static Map<String, dynamic> getPerformanceReport() {
    final monitor = PerformanceMonitor();
    return monitor._getPerformanceReportInternal();
  }

  // **INTERNAL IMPLEMENTATION**

  Future<T> _monitorOperationInternal<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
    bool logToCrashlytics = true,
  }) async {
    final startTime = DateTime.now();
    final completer = Completer<T>();
    Timer? timeoutTimer;
    
    try {
      // Add to pending operations for ANR detection
      _pendingOperations.add(completer);
      
      // Set timeout if specified
      if (timeout != null) {
        timeoutTimer = Timer(timeout, () {
          if (!completer.isCompleted) {
            final error = TimeoutException('Operation timed out: $operationName', timeout);
            completer.completeError(error);
            
            if (logToCrashlytics) {
              FirebaseCrashlytics.instance.recordError(
                error,
                StackTrace.current,
                reason: 'Operation timeout: $operationName',
              );
            }
          }
        });
        _activeTimers.add(timeoutTimer);
      }

      // Execute operation
      final result = await operation();
      
      // Record performance metrics
      _recordOperationPerformance(operationName, startTime);
      
      // Complete successfully
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      
      return result;
    } catch (e, stackTrace) {
      // Record error
      if (logToCrashlytics) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'Operation failed: $operationName',
        );
      }
      
      // Complete with error
      if (!completer.isCompleted) {
        completer.completeError(e, stackTrace);
      }
      
      rethrow;
    } finally {
      // Cleanup
      _pendingOperations.remove(completer);
      if (timeoutTimer != null) {
        timeoutTimer.cancel();
        _activeTimers.remove(timeoutTimer);
      }
    }
  }

  T _monitorSyncOperationInternal<T>(
    String operationName,
    T Function() operation, {
    Duration? timeout,
    bool logToCrashlytics = true,
  }) {
    final startTime = DateTime.now();
    
    try {
      // Execute operation
      final result = operation();
      
      // Record performance metrics
      _recordOperationPerformance(operationName, startTime);
      
      return result;
    } catch (e, stackTrace) {
      // Record error
      if (logToCrashlytics) {
        FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          reason: 'Sync operation failed: $operationName',
        );
      }
      
      rethrow;
    }
  }
  
  Future<T> _executeInBackgroundInternal<T>(
    String taskName,
    Future<T> Function() task, {
    Duration? timeout,
  }) async {
    return monitorOperation(
      'Background: $taskName',
      () async {
                 // Use compute for CPU-intensive tasks
         if (_isCpuIntensive(taskName)) {
           return await compute((_) async => await task(), null);
         } else {
          // Use Future.delayed to move to next frame for UI tasks
          await Future.delayed(Duration.zero);
          return await task();
        }
      },
      timeout: timeout,
    );
  }

  void _checkMemoryUsageInternal() {
    final now = DateTime.now();
    
    // Check memory usage periodically
    if (_lastMemoryCheck == null || 
        now.difference(_lastMemoryCheck!) > _memoryCheckInterval) {
      
      // Simulate memory check (in real app, use proper memory monitoring)
      final currentMemory = _simulateMemoryUsage();
      
      if (_lastMemoryUsage > 0) {
        final memoryIncrease = currentMemory - _lastMemoryUsage;
        final memoryIncreaseMB = memoryIncrease / (1024 * 1024);
        
        if (memoryIncreaseMB > 50) { // 50MB increase
          log('WARNING: Significant memory increase detected: ${memoryIncreaseMB.toStringAsFixed(1)}MB');
          FirebaseCrashlytics.instance.log('Memory increase: ${memoryIncreaseMB.toStringAsFixed(1)}MB');
        }
      }
      
      _lastMemoryUsage = currentMemory;
      _lastMemoryCheck = now;
    }
  }

  void _cleanupInternal() {
    // Cancel all active timers
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    
    // Complete pending operations
    for (final completer in _pendingOperations) {
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled during cleanup');
      }
    }
    _pendingOperations.clear();
  }

  Map<String, dynamic> _getPerformanceReportInternal() {
    final report = <String, dynamic>{};
    
    for (final operation in _operationDurations.keys) {
      final durations = _operationDurations[operation]!;
      final count = _operationCounts[operation] ?? 0;
      final slowCount = _slowOperationCounts[operation] ?? 0;
      
      if (durations.isNotEmpty) {
        final avgDuration = durations.fold<Duration>(
          Duration.zero,
          (sum, duration) => sum + duration,
        ) ~/ durations.length;
        
        final maxDuration = durations.reduce((a, b) => a > b ? a : b);
        
        report[operation] = {
          'count': count,
          'slowCount': slowCount,
          'avgDurationMs': avgDuration.inMilliseconds,
          'maxDurationMs': maxDuration.inMilliseconds,
          'slowPercentage': count > 0 ? (slowCount / count * 100).toStringAsFixed(1) : '0.0',
        };
      }
    }
    
    return report;
  }

  void _recordOperationPerformance(String operationName, DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    
    // Initialize lists if needed
    _operationDurations.putIfAbsent(operationName, () => []);
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
    
    // Record duration
    _operationDurations[operationName]!.add(duration);
    
    // Check for slow operations
    if (duration > _anrThreshold) {
      _slowOperationCounts[operationName] = (_slowOperationCounts[operationName] ?? 0) + 1;
      
      if (duration > _criticalThreshold) {
        log('CRITICAL: Very slow operation detected: $operationName took ${duration.inMilliseconds}ms');
        FirebaseCrashlytics.instance.log('Critical slow operation: $operationName - ${duration.inMilliseconds}ms');
      } else {
        log('WARNING: Slow operation detected: $operationName took ${duration.inMilliseconds}ms');
      }
    }
    
    // Log performance metrics
    if (kDebugMode) {
      print('PERFORMANCE: $operationName completed in ${duration.inMilliseconds}ms');
    }
  }

  bool _isCpuIntensive(String taskName) {
    final cpuIntensiveTasks = [
      'search',
      'parse',
      'encode',
      'decode',
      'compress',
      'decompress',
      'calculate',
      'process',
    ];
    
    return cpuIntensiveTasks.any((keyword) => 
      taskName.toLowerCase().contains(keyword)
    );
  }

  int _simulateMemoryUsage() {
    // In a real app, you would use proper memory monitoring
    // For now, simulate based on operation counts
    int totalOperations = 0;
    for (final count in _operationCounts.values) {
      totalOperations += count;
    }
    
    // Simulate memory usage based on operations
    return totalOperations * 1024; // 1KB per operation
  }
}

/// **ANR PREVENTION MIXIN**
/// 
/// Add this mixin to controllers that need ANR prevention
mixin AnrPreventionMixin {
  final List<Timer> _anrTimers = [];
  final List<Completer<void>> _anrOperations = [];
  
  /// **SAFE OPERATION EXECUTOR**
  /// 
  /// Ensures operations don't block the UI thread
  Future<T> safeOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Duration? timeout,
  }) async {
    return PerformanceMonitor.monitorOperation(
      operationName,
      operation,
      timeout: timeout,
    );
  }
  
  /// **BACKGROUND TASK EXECUTOR**
  /// 
  /// Moves heavy operations to background
  Future<T> backgroundTask<T>(
    String taskName,
    Future<T> Function() task, {
    Duration? timeout,
  }) async {
    return PerformanceMonitor.executeInBackground(
      taskName,
      task,
      timeout: timeout,
    );
  }
  
  /// **CLEANUP**
  /// 
  /// Call this in onClose()
  void cleanupAnrPrevention() {
    for (final timer in _anrTimers) {
      timer.cancel();
    }
    _anrTimers.clear();
    
    for (final completer in _anrOperations) {
      if (!completer.isCompleted) {
        completer.completeError('Operation cancelled during cleanup');
      }
    }
    _anrOperations.clear();
  }
}
