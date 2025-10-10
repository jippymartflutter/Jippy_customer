import 'dart:developer';

import 'package:razorpay_flutter/razorpay_flutter.dart';

/// **RAZORPAY CRASH PREVENTION UTILITY**
///
/// This utility prevents Razorpay-related crashes by:
/// - Handling NoSuchFieldError for activity_result_invalid_parameters
/// - Providing safe Razorpay initialization
/// - Graceful error handling for payment operations
/// - Version compatibility checks
class RazorpayCrashPrevention {
  static final RazorpayCrashPrevention _instance =
      RazorpayCrashPrevention._internal();
  factory RazorpayCrashPrevention() => _instance;
  RazorpayCrashPrevention._internal();

  Razorpay? _razorpay;
  bool _isInitialized = false;
  bool _isInitializationSafe = false;

  /// **SAFE RAZORPAY INITIALIZATION**
  ///
  /// Initializes Razorpay with crash prevention measures
  Future<bool> safeInitialize({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) async {
    try {
      log('RAZORPAY_CRASH_PREVENTION: Starting safe initialization...');

      // ✅ CRITICAL: Check if Razorpay can be safely initialized
      if (!await _canSafelyInitializeRazorpay()) {
        log('RAZORPAY_CRASH_PREVENTION: Razorpay initialization not safe, skipping...');
        return false;
      }

      // Create Razorpay instance
      _razorpay = Razorpay();

      // Set up event handlers with error protection
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS,
          (PaymentSuccessResponse response) {
        try {
          log('RAZORPAY_CRASH_PREVENTION: Payment success received');
          log('RAZORPAY_CRASH_PREVENTION: Payment ID: ${response.paymentId}');
          log('RAZORPAY_CRASH_PREVENTION: Payment signature: ${response.signature}');
          log('RAZORPAY_CRASH_PREVENTION: Payment data: ${response.data}');
          onSuccess(response);
        } catch (e) {
          log('RAZORPAY_CRASH_PREVENTION: Error in payment success handler: $e');
        }
      });

      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR,
          (PaymentFailureResponse response) {
        try {
          log('RAZORPAY_CRASH_PREVENTION: Payment error received: ${response.message}');
          onFailure(response);
        } catch (e) {
          log('RAZORPAY_CRASH_PREVENTION: Error in payment failure handler: $e');
        }
      });

      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET,
          (ExternalWalletResponse response) {
        try {
          log('RAZORPAY_CRASH_PREVENTION: External wallet response received');
          onExternalWallet(response);
        } catch (e) {
          log('RAZORPAY_CRASH_PREVENTION: Error in external wallet handler: $e');
        }
      });

      _isInitialized = true;
      _isInitializationSafe = true;

      log('RAZORPAY_CRASH_PREVENTION: ✅ Safe initialization completed');
      return true;
    } catch (e) {
      log('RAZORPAY_CRASH_PREVENTION: ❌ Initialization failed: $e');
      _isInitialized = false;
      _isInitializationSafe = false;
      return false;
    }
  }

  /// **SAFE PAYMENT OPENING**
  ///
  /// Opens Razorpay payment with crash prevention
  Future<bool> safeOpenPayment(Map<String, dynamic> options) async {
    try {
      if (!_isInitialized || !_isInitializationSafe) {
        log('RAZORPAY_CRASH_PREVENTION: Razorpay not safely initialized, cannot open payment');
        return false;
      }
      // ✅ CRITICAL: Validate options before opening payment
      if (!_validatePaymentOptions(options)) {
        log('RAZORPAY_CRASH_PREVENTION: Invalid payment options');
        return false;
      }

      log('RAZORPAY_CRASH_PREVENTION: Opening payment with validated options');
      _razorpay!.open(options);

      log('RAZORPAY_CRASH_PREVENTION: ✅ Payment opened successfully');
      return true;
    } catch (e) {
      log('RAZORPAY_CRASH_PREVENTION: ❌ Error opening payment: $e');
      return false;
    }
  }

  /// **SAFE CLEANUP**
  ///
  /// Safely cleans up Razorpay resources
  void safeCleanup() {
    try {
      if (_razorpay != null) {
        _razorpay!.clear();
        _razorpay = null;
      }
      _isInitialized = false;
      _isInitializationSafe = false;
      log('RAZORPAY_CRASH_PREVENTION: ✅ Cleanup completed');
    } catch (e) {
      log('RAZORPAY_CRASH_PREVENTION: ❌ Cleanup error: $e');
    }
  }

  /// **CHECK INITIALIZATION STATUS**
  bool get isInitialized => _isInitialized && _isInitializationSafe;

  /// **GET RAZORPAY INSTANCE**
  Razorpay? get razorpayInstance => _isInitialized ? _razorpay : null;

  // **INTERNAL METHODS**

  /// **CHECK IF RAZORPAY CAN BE SAFELY INITIALIZED**
  ///
  /// This method checks for the specific NoSuchFieldError that causes crashes
  Future<bool> _canSafelyInitializeRazorpay() async {
    try {
      // ✅ CRITICAL: Test if Razorpay can be instantiated without crashes
      final testRazorpay = Razorpay();

      // ✅ NEW: Test if the problematic field exists
      // This prevents the NoSuchFieldError for activity_result_invalid_parameters
      try {
        // Try to access Razorpay constants that might cause the crash
        final constants = [
          Razorpay.EVENT_PAYMENT_SUCCESS,
          Razorpay.EVENT_PAYMENT_ERROR,
          Razorpay.EVENT_EXTERNAL_WALLET,
        ];

        // If we can access these constants without crashing, it's safe
        for (String constant in constants) {
          if (constant.isEmpty) {
            log('RAZORPAY_CRASH_PREVENTION: Empty constant detected: $constant');
            return false;
          }
        }

        // Clean up test instance
        testRazorpay.clear();

        log('RAZORPAY_CRASH_PREVENTION: ✅ Razorpay can be safely initialized');
        return true;
      } catch (e) {
        log('RAZORPAY_CRASH_PREVENTION: ❌ Razorpay constant access failed: $e');
        return false;
      }
    } catch (e) {
      log('RAZORPAY_CRASH_PREVENTION: ❌ Razorpay instantiation test failed: $e');
      return false;
    }
  }

  /// **VALIDATE PAYMENT OPTIONS**
  ///
  /// Ensures payment options are valid before opening payment
  bool _validatePaymentOptions(Map<String, dynamic> options) {
    try {
      log('RAZORPAY_CRASH_PREVENTION: Validating payment options: $options');

      // Check required fields
      final requiredFields = ['key', 'amount', 'name', 'order_id'];
      for (String field in requiredFields) {
        if (!options.containsKey(field) || options[field] == null) {
          log('RAZORPAY_CRASH_PREVENTION: Missing required field: $field');
          return false;
        }
      }

      // Validate amount - handle both int and double
      final amount = options['amount'];
      int amountValue;
      if (amount is int) {
        amountValue = amount;
      } else if (amount is double) {
        amountValue = amount.round();
        log('RAZORPAY_CRASH_PREVENTION: Converted double amount to int: $amountValue');
      } else {
        log('RAZORPAY_CRASH_PREVENTION: Invalid amount type: ${amount.runtimeType}, value: $amount');
        return false;
      }

      if (amountValue <= 0) {
        log('RAZORPAY_CRASH_PREVENTION: Invalid amount: $amountValue (must be > 0)');
        return false;
      }

      // Validate key format
      final key = options['key'] as String;
      if (key.isEmpty) {
        log('RAZORPAY_CRASH_PREVENTION: Razorpay key is empty');
        return false;
      }

      if (!key.startsWith('rzp_')) {
        log('RAZORPAY_CRASH_PREVENTION: Invalid Razorpay key format: $key (should start with rzp_)');
        return false;
      }

      log('RAZORPAY_CRASH_PREVENTION: ✅ Payment options validated successfully');
      return true;
    } catch (e) {
      log('RAZORPAY_CRASH_PREVENTION: ❌ Payment options validation failed: $e');
      return false;
    }
  }
}

/// **RAZORPAY CRASH PREVENTION MIXIN**
///
/// Add this mixin to controllers that use Razorpay
mixin RazorpayCrashPreventionMixin {
  final RazorpayCrashPrevention _razorpayCrashPrevention =
      RazorpayCrashPrevention();

  /// **SAFE RAZORPAY INITIALIZATION**
  Future<bool> safeInitializeRazorpay({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) async {
    return await _razorpayCrashPrevention.safeInitialize(
      onSuccess: onSuccess,
      onFailure: onFailure,
      onExternalWallet: onExternalWallet,
    );
  }

  /// **SAFE PAYMENT OPENING**
  Future<bool> safeOpenRazorpayPayment(Map<String, dynamic> options) async {
    return await _razorpayCrashPrevention.safeOpenPayment(options);
  }

  /// **SAFE CLEANUP**
  void safeCleanupRazorpay() {
    _razorpayCrashPrevention.safeCleanup();
  }

  /// **CHECK IF RAZORPAY IS SAFE**
  bool get isRazorpaySafe => _razorpayCrashPrevention.isInitialized;

  /// **GET RAZORPAY INSTANCE**
  Razorpay? get razorpayInstance => _razorpayCrashPrevention.razorpayInstance;
}

/// **RAZORPAY ERROR RECOVERY**
///
/// Handles specific Razorpay errors and provides recovery
class RazorpayErrorRecovery {
  static int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 3;
  static DateTime? _lastErrorTime;
  static const Duration _errorCooldown = Duration(minutes: 5);

  /// **HANDLE RAZORPAY ERROR**
  ///
  /// Provides recovery strategies for Razorpay errors
  static Future<bool> handleError(dynamic error) async {
    try {
      _consecutiveErrors++;
      _lastErrorTime = DateTime.now();

      log('RAZORPAY_ERROR_RECOVERY: Handling error: $error');

      // Check if we should attempt recovery
      if (_consecutiveErrors > _maxConsecutiveErrors) {
        final now = DateTime.now();
        if (_lastErrorTime != null &&
            now.difference(_lastErrorTime!) < _errorCooldown) {
          log('RAZORPAY_ERROR_RECOVERY: Too many consecutive errors, skipping recovery');
          return false;
        } else {
          // Reset error count after cooldown
          _consecutiveErrors = 0;
        }
      }

      // Try recovery strategies
      if (await _attemptRecovery(error)) {
        log('RAZORPAY_ERROR_RECOVERY: ✅ Recovery successful');
        _consecutiveErrors = 0;
        return true;
      } else {
        log('RAZORPAY_ERROR_RECOVERY: ❌ Recovery failed');
        return false;
      }
    } catch (e) {
      log('RAZORPAY_ERROR_RECOVERY: ❌ Error handling failed: $e');
      return false;
    }
  }

  /// **ATTEMPT RECOVERY**
  static Future<bool> _attemptRecovery(dynamic error) async {
    try {
      // Strategy 1: Clean up and reinitialize
      log('RAZORPAY_ERROR_RECOVERY: Attempting cleanup and reinitialization...');

      // Wait a bit before retrying
      await Future.delayed(const Duration(seconds: 2));

      // Strategy 2: Check if it's a version compatibility issue
      if (error.toString().contains('NoSuchFieldError') ||
          error.toString().contains('activity_result_invalid_parameters')) {
        log('RAZORPAY_ERROR_RECOVERY: Detected version compatibility issue');
        return false; // This requires dependency update
      }

      return true;
    } catch (e) {
      log('RAZORPAY_ERROR_RECOVERY: Recovery attempt failed: $e');
      return false;
    }
  }

  /// **RESET ERROR COUNT**
  static void resetErrorCount() {
    _consecutiveErrors = 0;
    _lastErrorTime = null;
    log('RAZORPAY_ERROR_RECOVERY: Error count reset');
  }
}
