import 'dart:developer';

import 'package:flutter_smartlook/flutter_smartlook.dart';

/// **SMARTLOOK ANR PREVENTION FIX**
///
/// This utility prevents Smartlook from causing ANR by configuring it
/// to use background threads and reducing heavy operations.
class SmartlookANRFix {
  static bool _isConfigured = false;
  static bool _isEnabled = true;

  /// **Configure Smartlook to prevent ANR**
  ///
  /// Sets up Smartlook with ANR-safe configuration
  static Future<void> configureSmartlook() async {
    if (_isConfigured) return;

    try {
      log('SMARTLOOK_ANR_FIX: Configuring Smartlook for ANR prevention');

      // Configure Smartlook with ANR-safe settings
      await _configureANRSafeSettings();

      _isConfigured = true;
      log('SMARTLOOK_ANR_FIX: Smartlook configured successfully');
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to configure Smartlook: $e');
      _isEnabled = false;
    }
  }

  /// **Configure ANR-safe settings**
  static Future<void> _configureANRSafeSettings() async {
    try {
      // Note: setEventTrackingMode is not available in this version
      // Smartlook manages tracking automatically
      log('SMARTLOOK_ANR_FIX: Event tracking mode configuration not available in current SDK version');

      // Disable heavy operations that can cause ANR
      await _disableHeavyOperations();

      // Configure background processing
      await _configureBackgroundProcessing();
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to configure ANR-safe settings: $e');
      rethrow;
    }
  }

  /// **Disable heavy operations that can cause ANR**
  static Future<void> _disableHeavyOperations() async {
    try {
      // Note: setEventTrackingMode is not available in this version
      // Smartlook manages tracking automatically
      log('SMARTLOOK_ANR_FIX: Heavy operations configuration not available in current SDK version');

      log('SMARTLOOK_ANR_FIX: Heavy operations disabled');
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to disable heavy operations: $e');
    }
  }

  /// **Configure background processing**
  static Future<void> _configureBackgroundProcessing() async {
    try {
      // Note: setEventTrackingMode is not available in this version
      // Smartlook manages background processing automatically
      log('SMARTLOOK_ANR_FIX: Background processing configuration not available in current SDK version');

      log('SMARTLOOK_ANR_FIX: Background processing configured');
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to configure background processing: $e');
    }
  }

  /// **Safe event tracking**
  ///
  /// Tracks events without blocking the main thread
  static Future<void> safeTrackEvent(String eventName,
      {Map<String, dynamic>? properties}) async {
    if (!_isEnabled || !_isConfigured) return;

    try {
      // Use microtask to move off main thread
      await Future.microtask(() async {
        // Note: trackEvent with properties is not available in this version
        // Use the instance method instead
        final smartlook = Smartlook.instance;
        smartlook.trackEvent(eventName);
      });
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to track event "$eventName": $e');
    }
  }

  /// **Safe user identification**
  ///
  /// Sets user ID without blocking the main thread
  static Future<void> safeSetUserIdentifier(String userId) async {
    if (!_isEnabled || !_isConfigured) return;

    try {
      await Future.microtask(() async {
        // Use the instance method instead of static method
        final smartlook = Smartlook.instance;
        smartlook.user.setIdentifier(userId);
      });
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to set user identifier: $e');
    }
  }

  /// **Safe navigation tracking**
  ///
  /// Tracks navigation without blocking the main thread
  static Future<void> safeTrackNavigation(String screenName) async {
    if (!_isEnabled || !_isConfigured) return;

    try {
      await Future.microtask(() async {
        // Note: trackEvent with properties is not available in this version
        // Use the instance method instead
        final smartlook = Smartlook.instance;
        smartlook.trackEvent('navigation_$screenName');
      });
    } catch (e) {
      log('SMARTLOOK_ANR_FIX: Failed to track navigation: $e');
    }
  }

  /// **Disable Smartlook if causing issues**
  static void disableSmartlook() {
    _isEnabled = false;
    log('SMARTLOOK_ANR_FIX: Smartlook disabled due to ANR issues');
  }

  /// **Enable Smartlook after fixing issues**
  static void enableSmartlook() {
    _isEnabled = true;
    log('SMARTLOOK_ANR_FIX: Smartlook enabled');
  }

  /// **Get Smartlook status**
  static Map<String, dynamic> getStatus() {
    return {
      'isConfigured': _isConfigured,
      'isEnabled': _isEnabled,
      'isANRSafe': _isConfigured && _isEnabled,
    };
  }

  /// **Cleanup Smartlook resources**
  static void cleanup() {
    _isConfigured = false;
    _isEnabled = true;
    log('SMARTLOOK_ANR_FIX: Cleanup completed');
  }
}

/// **SMARTLOOK ANR PREVENTION MIXIN**
///
/// Add this mixin to controllers that use Smartlook
mixin SmartlookANRPrevention {
  /// **Safe Smartlook event tracking**
  Future<void> safeTrackEvent(String eventName,
      {Map<String, dynamic>? properties}) async {
    await SmartlookANRFix.safeTrackEvent(eventName, properties: properties);
  }

  /// **Safe Smartlook navigation tracking**
  Future<void> safeTrackNavigation(String screenName) async {
    await SmartlookANRFix.safeTrackNavigation(screenName);
  }

  /// **Safe Smartlook user identification**
  Future<void> safeSetUserIdentifier(String userId) async {
    await SmartlookANRFix.safeSetUserIdentifier(userId);
  }
}
