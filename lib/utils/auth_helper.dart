import 'dart:developer';

import 'package:customer/utils/preferences.dart';
import 'package:customer/utils/production_logger.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthHelper {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final Dio _dio = Dio();

  // **DEVICE-SPECIFIC AUTHENTICATION ENHANCEMENTS**
  static const String _deviceIdKey = 'device_id';
  static const String _lastAuthCheckKey = 'last_auth_check';
  static const String _authRetryCountKey = 'auth_retry_count';
  static const int _maxRetryCount = 5;
  static const Duration _authCheckInterval = Duration(minutes: 30);

  /// **ENHANCED AUTHENTICATION CHECK WITH DEVICE-SPECIFIC HANDLING**
  static Future<User?> getCurrentUser({int retryCount = 3}) async {
    try {
      // Initialize production logger if not already done
      await ProductionLogger.initialize();

      ProductionLogger.info('AUTH_HELPER', 'Starting authentication check');

      // Check if we should skip auth check (rate limiting)
      if (_shouldSkipAuthCheck()) {
        ProductionLogger.info(
            'AUTH_HELPER', 'Skipping auth check due to rate limiting');
        log('[AUTH_HELPER] Skipping auth check due to rate limiting');
        return FirebaseAuth.instance.currentUser;
      }

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        ProductionLogger.info(
            'AUTH_HELPER', 'Firebase user found: ${user.uid}');
        // Update last auth check time
        await _updateLastAuthCheck();
        return user;
      }

      // Try to restore session with enhanced retry logic
      for (int i = 0; i < retryCount; i++) {
        try {
          ProductionLogger.info(
              'AUTH_HELPER', 'Attempt ${i + 1} to restore session');
          log('[AUTH_HELPER] Attempt ${i + 1} to restore session');

          final apiToken = await _secureStorage.read(key: 'api_token');
          if (apiToken == null || apiToken.isEmpty) {
            ProductionLogger.warning(
                'AUTH_HELPER', 'No API token found in secure storage');
            log('[AUTH_HELPER] No API token found');
            break;
          }

          // Try to refresh Firebase token with device-specific handling
          final deviceId = await _getDeviceId();
          ProductionLogger.info('AUTH_HELPER',
              'Refreshing Firebase token with device ID: $deviceId');

          final response = await _dio.post(
            'https://jippymart.in/api/refresh-firebase-token',
            options: Options(
              headers: {
                'Authorization': 'Bearer $apiToken',
                'Device-ID': deviceId,
                'App-Version': '2.2.1', // Add your app version
              },
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

          if (response.statusCode == 200 &&
              response.data['firebase_custom_token'] != null) {
            ProductionLogger.info(
                'AUTH_HELPER', 'Firebase custom token received, signing in');
            await FirebaseAuth.instance
                .signInWithCustomToken(response.data['firebase_custom_token']);
            user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              ProductionLogger.info('AUTH_HELPER',
                  'Successfully restored session for user: ${user.uid}');
              log('[AUTH_HELPER] Successfully restored session');
              await _updateLastAuthCheck();
              await _resetRetryCount();
              return user;
            } else {
              ProductionLogger.error(
                  'AUTH_HELPER', 'Firebase sign-in failed - no user returned');
            }
          } else {
            ProductionLogger.warning('AUTH_HELPER',
                'Invalid response from token refresh: ${response.statusCode}');
          }
        } catch (e) {
          ProductionLogger.error('AUTH_HELPER', 'Error in attempt ${i + 1}', e);
          log('[AUTH_HELPER] Error in attempt ${i + 1}: $e');
          await _incrementRetryCount();

          if (i < retryCount - 1) {
            // Exponential backoff with device-specific delays
            final delay = Duration(milliseconds: 1000 * (i + 1));
            await Future.delayed(delay);
          }
        }
      }

      ProductionLogger.error('AUTH_HELPER',
          'Failed to restore session after $retryCount attempts');
      log('[AUTH_HELPER] Failed to restore session after $retryCount attempts');
      return null;
    } catch (e) {
      log('[AUTH_HELPER] Critical error in getCurrentUser: $e');
      return null;
    }
  }

  /// **DEVICE-SPECIFIC SESSION VALIDATION**
  static Future<bool> isSessionValid() async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;

      // Check if token is about to expire
      final tokenResult = await user.getIdTokenResult();
      final expirationTime = tokenResult.expirationTime;

      if (expirationTime != null) {
        final timeUntilExpiry = expirationTime.difference(DateTime.now());

        // If token expires in less than 5 minutes, refresh it
        if (timeUntilExpiry.inMinutes < 5) {
          log('[AUTH_HELPER] Token expiring soon, refreshing...');
          await user.getIdToken(true);
        }
      }

      return true;
    } catch (e) {
      log('[AUTH_HELPER] Session validation failed: $e');
      return false;
    }
  }

  /// **ENHANCED AUTHENTICATION CLEARING**
  static Future<void> clearAuthData() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _secureStorage.delete(key: 'api_token');
      await _resetRetryCount();
      await _clearLastAuthCheck();
      log('[AUTH_HELPER] Auth data cleared successfully');
    } catch (e) {
      log('[AUTH_HELPER] Error clearing auth data: $e');
    }
  }

  /// **DEVICE ID MANAGEMENT**
  static Future<String> _getDeviceId() async {
    try {
      String? deviceId = await _secureStorage.read(key: _deviceIdKey);
      if (deviceId == null || deviceId.isEmpty) {
        // Generate a unique device ID
        deviceId = DateTime.now().millisecondsSinceEpoch.toString() +
            (1000 + (DateTime.now().millisecondsSinceEpoch % 9000)).toString();
        await _secureStorage.write(key: _deviceIdKey, value: deviceId);
      }
      return deviceId;
    } catch (e) {
      log('[AUTH_HELPER] Error getting device ID: $e');
      return 'unknown_device';
    }
  }

  /// **RATE LIMITING FOR AUTH CHECKS**
  static bool _shouldSkipAuthCheck() {
    try {
      final lastCheck = Preferences.getInt(_lastAuthCheckKey);
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final timeDiff = Duration(milliseconds: currentTime - lastCheck);

      // Skip if last check was too recent
      if (timeDiff < _authCheckInterval) {
        return true;
      }

      // Skip if too many retries recently
      final retryCount = Preferences.getInt(_authRetryCountKey);
      if (retryCount > _maxRetryCount) {
        log('[AUTH_HELPER] Too many auth retries, skipping check');
        return true;
      }

      return false;
    } catch (e) {
      log('[AUTH_HELPER] Error checking auth rate limit: $e');
      return false;
    }
  }

  /// **UPDATE LAST AUTH CHECK TIME**
  static Future<void> _updateLastAuthCheck() async {
    try {
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      await Preferences.setInt(_lastAuthCheckKey, currentTime);
    } catch (e) {
      log('[AUTH_HELPER] Error updating last auth check: $e');
    }
  }

  /// **CLEAR LAST AUTH CHECK TIME**
  static Future<void> _clearLastAuthCheck() async {
    try {
      await Preferences.clearKeyData(_lastAuthCheckKey);
    } catch (e) {
      log('[AUTH_HELPER] Error clearing last auth check: $e');
    }
  }

  /// **INCREMENT RETRY COUNT**
  static Future<void> _incrementRetryCount() async {
    try {
      final currentCount = Preferences.getInt(_authRetryCountKey);
      await Preferences.setInt(_authRetryCountKey, currentCount + 1);
    } catch (e) {
      log('[AUTH_HELPER] Error incrementing retry count: $e');
    }
  }

  /// **RESET RETRY COUNT**
  static Future<void> _resetRetryCount() async {
    try {
      await Preferences.setInt(_authRetryCountKey, 0);
    } catch (e) {
      log('[AUTH_HELPER] Error resetting retry count: $e');
    }
  }

  /// **DEVICE-SPECIFIC AUTHENTICATION DIAGNOSTICS**
  static Future<Map<String, dynamic>> getAuthDiagnostics() async {
    try {
      final diagnostics = <String, dynamic>{
        'device_id': await _getDeviceId(),
        'firebase_user': FirebaseAuth.instance.currentUser?.uid,
        'api_token_exists': await _secureStorage.read(key: 'api_token') != null,
        'last_auth_check': Preferences.getInt(_lastAuthCheckKey),
        'retry_count': Preferences.getInt(_authRetryCountKey),
        'app_version': '2.2.1', // Add your app version
        'timestamp': DateTime.now().toIso8601String(),
      };

      log('[AUTH_HELPER] Auth diagnostics: $diagnostics');
      return diagnostics;
    } catch (e) {
      log('[AUTH_HELPER] Error getting auth diagnostics: $e');
      return {'error': e.toString()};
    }
  }

  /// **FORCE AUTHENTICATION REFRESH**
  static Future<bool> forceAuthRefresh() async {
    try {
      log('[AUTH_HELPER] Force refreshing authentication...');

      // Clear rate limiting
      await _clearLastAuthCheck();
      await _resetRetryCount();

      // Force token refresh
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.getIdToken(true);
        log('[AUTH_HELPER] Force auth refresh successful');
        return true;
      }

      return false;
    } catch (e) {
      log('[AUTH_HELPER] Force auth refresh failed: $e');
      return false;
    }
  }
}
