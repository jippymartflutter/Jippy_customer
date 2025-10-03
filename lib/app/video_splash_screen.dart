import 'dart:async';
import 'dart:developer' as developer;

import 'package:customer/app/auth_screen/phone_number_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/app_update_service.dart';
import 'package:customer/services/final_deep_link_service.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/anr_prevention.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

class VideoSplashScreen extends StatefulWidget {
  const VideoSplashScreen({super.key});

  @override
  State<VideoSplashScreen> createState() => _VideoSplashScreenState();
}

class _VideoSplashScreenState extends State<VideoSplashScreen> {
  bool _isLogoLoaded = false;
  bool _hasError = false;
  String _errorMessage = '';
  Timer? _navigationTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeLogo();
  }

  void _initializeLogo() async {
    try {
      developer.log('VideoSplashScreen: Initializing logo...');

      // Add a small delay to ensure the widget is properly mounted
      await Future.delayed(const Duration(milliseconds: 50));

      if (mounted) {
        setState(() {
          _isLogoLoaded = true;
        });

        developer.log('VideoSplashScreen: Logo loaded successfully');
      }

      // **OPTIMIZED: Reduced splash duration for faster app opening**
      _navigationTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          developer.log(
              'VideoSplashScreen: Splash duration completed, navigating to main app');
          _navigateToMainApp();
        }
      });
    } catch (e) {
      developer.log('VideoSplashScreen: Error initializing logo: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Unable to load app. Please restart the application.';
      });

      // Wait a bit then navigate to main app
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _navigateToMainApp();
        }
      });
    }
  }

  void _navigateToMainApp() async {
    // Prevent multiple navigation calls
    if (_hasNavigated) {
      developer.log('VideoSplashScreen: Already navigated, skipping...');
      return;
    }

    try {
      _hasNavigated = true;
      // No need to dispose anything for GIF

      developer.log('VideoSplashScreen: Navigating to main app');

      // Check if there's a pending deep link
      developer.log('VideoSplashScreen: Checking for pending deep links...');
      // The deep link service will handle navigation automatically
      // We just need to ensure the app is ready

      // 1. Read API token
      final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
      final apiToken = await secureStorage.read(key: 'api_token');
      developer.log(
          '[VIDEO_SPLASH] api_token from secure storage: ${apiToken != null ? "EXISTS (${apiToken.length} chars)" : "NULL"}');

      // 2. Check Firebase user
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      developer.log(
          '[VIDEO_SPLASH] Firebase currentUser: ${firebaseUser?.uid ?? "NULL"}');
      developer.log(
          '[VIDEO_SPLASH] Firebase user email: ${firebaseUser?.email ?? "NULL"}');
      developer.log(
          '[VIDEO_SPLASH] Firebase user phone: ${firebaseUser?.phoneNumber ?? "NULL"}');
      developer.log(
          '[VIDEO_SPLASH] Firebase user isAnonymous: ${firebaseUser?.isAnonymous ?? "NULL"}');

      // If no API token or no Firebase user, go to phone number login
      if (apiToken == null || apiToken.isEmpty || firebaseUser == null) {
        developer.log(
            '[VIDEO_SPLASH] No API token or Firebase user. Checking for app updates before login...');

        // DEBUG MODE: Additional logging for debugging logout issues
        if (kDebugMode) {
          developer.log('[VIDEO_SPLASH] DEBUG MODE - Authentication state:');
          developer.log(
              '[VIDEO_SPLASH] DEBUG - API Token: ${apiToken != null ? "EXISTS" : "NULL"}');
          developer.log(
              '[VIDEO_SPLASH] DEBUG - Firebase User: ${firebaseUser != null ? "EXISTS" : "NULL"}');
          developer.log(
              '[VIDEO_SPLASH] DEBUG - Firebase Auth State: ${FirebaseAuth.instance.authStateChanges().first}');
        }

        // **FIXED: Check for app updates asynchronously to prevent blocking**
        developer
            .log('[VIDEO_SPLASH] Checking for app updates asynchronously...');

        // Navigate immediately and check updates in background
        developer
            .log('[VIDEO_SPLASH] Navigating to PhoneNumberScreen immediately.');
        Get.offAll(() => const PhoneNumberScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));

        // Check for updates in background without blocking navigation
        _checkUpdatesInBackground();
        return;
      }

      // 3. If Firebase user is null but token exists, try to refresh Firebase session
      // (This block is now unreachable, so you can remove or comment it out)

      // 4. Check all three: API token, Firebase user, Firestore user profile
      if (apiToken != null && apiToken.isNotEmpty && firebaseUser != null) {
        developer.log(
            '[VIDEO_SPLASH] All tokens present, navigating immediately...');

        // **FIXED: Navigate immediately and verify user profile in background**
        developer
            .log('[VIDEO_SPLASH] Navigating to DashBoardScreen immediately.');
        Get.offAll(() => const DashBoardScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 800));

        // Process any pending deep links after successful login
        try {
          final deepLinkService = FinalDeepLinkService();
          deepLinkService.processPendingDeepLinkAfterLogin();
          print(
              '🔗 [VIDEO_SPLASH] Processing pending deep link after login...');
        } catch (e) {
          print('❌ [VIDEO_SPLASH] Error processing pending deep link: $e');
        }

        // Verify user profile in background and handle if needed
        _verifyUserProfileInBackground(firebaseUser.uid);

        // Check for updates in background without blocking navigation
        _checkUpdatesInBackground();
        return;
      }

      // If any check fails, go to login
      developer.log(
          '[VIDEO_SPLASH] Session check failed. Navigating to LoginScreen.');
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const PhoneNumberScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200));
    } catch (e) {
      developer.log('VideoSplashScreen: Error navigating to main app: $e');
      // Fallback navigation to login screen
      Get.offAll(() => const PhoneNumberScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1200));
    }
  }

  /// **NEW: Check for updates in background without blocking UI**
  void _checkUpdatesInBackground() {
    Future.microtask(() async {
      try {
        developer.log('[VIDEO_SPLASH] Background: Checking for app updates...');
        bool updateRequired = await AppUpdateService.checkForUpdate().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            developer.log(
                '[VIDEO_SPLASH] Background: Update check timed out, continuing...');
            return false;
          },
        );

        if (updateRequired) {
          developer.log(
              '[VIDEO_SPLASH] Background: Update required, will show update dialog when ready.');
          // The AppUpdateService will handle showing the update dialog
        } else {
          developer.log('[VIDEO_SPLASH] Background: No update required.');
        }
      } catch (e) {
        developer
            .log('[VIDEO_SPLASH] Background: Error checking for updates: $e');
        // Continue app flow even if update check fails
      }
    });
  }

  /// **ANR-FIXED: Verify user profile in background without blocking UI**
  void _verifyUserProfileInBackground(String userId) {
    ANRPrevention.executeWithANRPrevention(
      'VideoSplash_UserProfileVerification',
      () async {
        try {
          developer.log('[VIDEO_SPLASH] Background: Verifying user profile...');

          // **CRITICAL ANR FIX: Use ANR Prevention with 3s timeout**
          UserModel? userModel =
              await FireStoreUtils.getUserProfile(userId).timeout(
            const Duration(seconds: 3), // Reduced from 15s to 3s
            onTimeout: () {
              developer.log(
                  '[VIDEO_SPLASH] Background: User profile check timed out after 3s, continuing...');
              return null;
            },
          );

          if (userModel != null && userModel.active == true) {
            developer.log(
                '[VIDEO_SPLASH] Background: User profile verified and active.');
          } else {
            developer.log(
                '[VIDEO_SPLASH] Background: User profile missing or inactive. Will handle in background.');
            // Could show a toast or handle this gracefully without blocking the user
          }
        } catch (e) {
          developer.log(
              '[VIDEO_SPLASH] Background: Error verifying user profile: $e');
          // Continue app flow even if profile verification fails
        }
      },
      timeout: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/ic_logo.png",
                      width: 150, height: 150),
                  const SizedBox(height: 20),
                  Text(
                    "Loading...",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: AppThemeData.medium,
                    ),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Error: $_errorMessage",
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              )
            : _isLogoLoaded
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.white,
                    child: Center(
                      child: Image.asset(
                        "assets/images/ic_logo.png",
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Container(
                    // Show loading indicator while logo is loading
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/images/ic_logo.png",
                              width: 150, height: 150),
                          const SizedBox(height: 20),
                          const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
