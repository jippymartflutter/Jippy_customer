import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:customer/utils/production_logger.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/constant/constant.dart';

class AppLifecycleLogger extends WidgetsBindingObserver {
  static final AppLifecycleLogger _instance = AppLifecycleLogger._internal();
  factory AppLifecycleLogger() => _instance;
  AppLifecycleLogger._internal();

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  DateTime? _lastResumeTime;
  DateTime? _lastPauseTime;
  int _appOpenCount = 0;
  bool _isInitialized = false;

  /// **INITIALIZE LIFECYCLE LOGGER**
  static Future<void> initialize() async {
    if (_instance._isInitialized) return;
    
    try {
      WidgetsBinding.instance.addObserver(_instance);
      _instance._isInitialized = true;
      
      // Log initial state
      await _instance._logAppState('INITIALIZED', 'App lifecycle logger started');
      
      // Set up Firebase Auth state listener
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        _instance._logAuthStateChange(user);
      });
      
      log('[LIFECYCLE_LOGGER] Initialized successfully');
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Initialization failed: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _handleLifecycleChange(state);
  }

  /// **HANDLE LIFECYCLE STATE CHANGES**
  Future<void> _handleLifecycleChange(AppLifecycleState state) async {
    try {
      final timestamp = DateTime.now();
      final stateName = state.toString().split('.').last.toUpperCase();
      
      switch (state) {
        case AppLifecycleState.resumed:
          _appOpenCount++;
          _lastResumeTime = timestamp;
          await _logAppState(stateName, 'App resumed (count: $_appOpenCount)');
          await _checkAuthenticationState('RESUMED');
          break;
          
        case AppLifecycleState.paused:
          _lastPauseTime = timestamp;
          await _logAppState(stateName, 'App paused');
          await _saveAppState();
          break;
          
        case AppLifecycleState.inactive:
          await _logAppState(stateName, 'App inactive');
          break;
          
        case AppLifecycleState.detached:
          await _logAppState(stateName, 'App detached');
          await _saveAppState();
          break;
          
        case AppLifecycleState.hidden:
          await _logAppState(stateName, 'App hidden');
          break;
      }
      
      // Send to Firebase Crashlytics
      FirebaseCrashlytics.instance.log('AppLifecycleState: $stateName');
      
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error handling lifecycle change: $e');
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  /// **LOG AUTHENTICATION STATE CHANGES**
  Future<void> _logAuthStateChange(User? user) async {
    try {
      final userId = user?.uid;
      
      // Get email and phone from Firestore profile data instead of Firebase Auth
      String? email;
      String? phoneNumber;
      
      if (userId != null && Constant.userModel != null) {
        email = Constant.userModel?.email;
        phoneNumber = Constant.userModel?.phoneNumber;
      } else {
        // Fallback to Firebase Auth data if Firestore profile not available
        email = user?.email;
        phoneNumber = user?.phoneNumber;
      }
      
      final authInfo = {
        'user_id': userId,
        'email': email,
        'phone_number': phoneNumber,
        'is_authenticated': user != null,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _logAppState('AUTH_STATE_CHANGE', 'Auth state changed: ${authInfo.toString()}');
      
      // Log to Firebase Crashlytics
      FirebaseCrashlytics.instance.log('AuthStateChange: ${authInfo.toString()}');
      
      // Set user ID for production logger
      if (userId != null) {
        ProductionLogger.setUserId(userId);
      }
      
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error logging auth state change: $e');
    }
  }

  /// **LOG USER PROFILE LOADED - Updates auth state with complete profile data**
  Future<void> logUserProfileLoaded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && Constant.userModel != null) {
        final authInfo = {
          'user_id': user.uid,
          'email': Constant.userModel?.email,
          'phone_number': Constant.userModel?.phoneNumber,
          'is_authenticated': true,
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        await _logAppState('AUTH_STATE_CHANGE', 'Auth state updated with profile data: ${authInfo.toString()}');
        
        // Log to Firebase Crashlytics
        FirebaseCrashlytics.instance.log('AuthStateUpdated: ${authInfo.toString()}');
      }
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error logging user profile loaded: $e');
    }
  }

  /// **CHECK AUTHENTICATION STATE ON RESUME**
  Future<void> _checkAuthenticationState(String trigger) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final apiToken = await _secureStorage.read(key: 'api_token');
      final isOtpVerified = Preferences.getBoolean('isOtpVerified');
      
      final authStatus = {
        'firebase_user': user?.uid,
        'api_token_exists': apiToken != null && apiToken.isNotEmpty,
        'otp_verified': isOtpVerified,
        'trigger': trigger,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _logAppState('AUTH_CHECK', 'Authentication status: ${authStatus.toString()}');
      
      // Check for potential logout conditions
      if (user == null && apiToken != null && apiToken.isNotEmpty) {
        await _logAppState('POTENTIAL_LOGOUT', 'Firebase user null but API token exists');
        FirebaseCrashlytics.instance.log('Potential logout detected: Firebase user null but API token exists');
      }
      
      if (user != null && (apiToken == null || apiToken.isEmpty)) {
        await _logAppState('POTENTIAL_LOGOUT', 'Firebase user exists but no API token');
        FirebaseCrashlytics.instance.log('Potential logout detected: Firebase user exists but no API token');
      }
      
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error checking auth state: $e');
    }
  }

  /// **SAVE APP STATE**
  Future<void> _saveAppState() async {
    try {
      final appState = {
        'last_resume_time': _lastResumeTime?.toIso8601String(),
        'last_pause_time': _lastPauseTime?.toIso8601String(),
        'app_open_count': _appOpenCount,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await Preferences.setString('app_lifecycle_state', appState.toString());
      await _logAppState('STATE_SAVED', 'App state saved: ${appState.toString()}');
      
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error saving app state: $e');
    }
  }

  /// **LOG APP STATE WITH MULTIPLE OUTPUTS**
  Future<void> _logAppState(String state, String message) async {
    try {
      final logMessage = '[$state] $message';
      
      // Console logging
      log(logMessage);
      
      // Production logger
      ProductionLogger.info('LIFECYCLE', logMessage);
      
      // Firebase Crashlytics
      FirebaseCrashlytics.instance.log(logMessage);
      
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error logging app state: $e');
    }
  }

  /// **GET APP STATISTICS**
  Future<Map<String, dynamic>> getAppStats() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final apiToken = await _secureStorage.read(key: 'api_token');
      
      return {
        'app_open_count': _appOpenCount,
        'last_resume_time': _lastResumeTime?.toIso8601String(),
        'last_pause_time': _lastPauseTime?.toIso8601String(),
        'firebase_user': user?.uid,
        'api_token_exists': apiToken != null && apiToken.isNotEmpty,
        'is_initialized': _isInitialized,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// **FORCE LOG CURRENT STATE**
  Future<void> forceLogCurrentState() async {
    try {
      await _checkAuthenticationState('MANUAL_CHECK');
      await _saveAppState();
      await _logAppState('MANUAL_LOG', 'Manual state logging triggered');
    } catch (e) {
      log('[LIFECYCLE_LOGGER] Error in manual logging: $e');
    }
  }

  /// **DISPOSE LOGGER**
  static void dispose() {
    WidgetsBinding.instance.removeObserver(_instance);
    _instance._isInitialized = false;
    log('[LIFECYCLE_LOGGER] Disposed');
  }
}
