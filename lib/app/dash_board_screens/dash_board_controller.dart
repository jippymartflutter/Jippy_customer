import 'package:customer/app/favourite_screens/favourite_screen.dart';
import 'package:customer/app/home_screen/home_screen.dart';
import 'package:customer/app/home_screen/home_screen_two.dart';
import 'package:customer/app/order_list_screen/order_screen.dart';
import 'package:customer/app/profile_screen/profile_screen.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/services/global_deeplink_handler.dart';
import 'package:customer/services/final_deep_link_service.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class DashBoardController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList pageList = [].obs;
  RxString currentTheme = "theme_1".obs;
  RxBool isThemeLoading = false.obs;
  RxString themeError = "".obs;
  StreamSubscription<DocumentSnapshot>? _themeSubscription;
  Worker? _themeListener;
  final Map<String, List<Widget>> _pageCache = {};
  
  // Error recovery variables
  int _retryCount = 0;
  final int _maxRetries = 5;

  @override
  void onInit() {
    print('🔗 [DASHBOARD] onInit() called - Starting dashboard initialization...');
    
    // **OPTIMIZED: Initialize theme and page list immediately**
    currentTheme.value = Constant.theme;
    _updatePageList();
    
    // **OPTIMIZED: Defer heavy operations to background**
    _initializeBackgroundServices();
    
    super.onInit();
    print('🔗 [DASHBOARD] onInit() completed - Dashboard controller initialized');
  }
  
  // **NEW: Background initialization for heavy operations**
  void _initializeBackgroundServices() {
    Future.microtask(() async {
      try {
        // Load tax list in background
        await getTaxList();
        
        // Set up Firestore listener in background
        _setupThemeListener();
        
        // Listen to local theme changes with proper disposal
        _themeListener = ever(currentTheme, (_) {
          print('[DEBUG] Theme changed to: ${currentTheme.value}');
          _updatePageList();
        });
        
        // **OPTIMIZED: Process deeplinks with shorter delay**
        print('🔗 [DASHBOARD] Setting up deeplink processing with 1 second delay...');
        await Future.delayed(const Duration(milliseconds: 1000));
        _processPendingDeeplinks();
        
        // Clear the last processed link to allow new deep links
        try {
          FinalDeepLinkService().clearLastProcessedLink();
          print('🔗 [DASHBOARD] Cleared last processed link to allow new deep links');
        } catch (e) {
          print('🔗 [DASHBOARD] Could not clear last processed link: $e');
        }
      } catch (e) {
        print('🔗 [DASHBOARD] Background initialization error: $e');
      }
    });
  }

  void _setupThemeListener() {
    try {
      print('[DEBUG] Setting up theme listener...');
      _themeSubscription = FirebaseFirestore.instance
          .collection('settings')
          .doc('home_page_theme')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final newTheme = snapshot.data()!['theme'] as String? ?? 'theme_1';
          if (newTheme != currentTheme.value) {
            print('[DEBUG] Firestore theme update: $newTheme');
            currentTheme.value = newTheme;
            Constant.theme = newTheme;
            themeError.value = ""; // Clear any previous errors
            _retryCount = 0; // Reset retry count on success
          }
        }
      }, onError: (error) {
        print('[ERROR] Theme listener error: $error');
        themeError.value = "Failed to listen to theme changes: $error";
        _handleThemeError();
      });
      print('[DEBUG] Theme listener set up successfully');
    } catch (e) {
      print('[ERROR] Setting up theme listener: $e');
      themeError.value = "Failed to set up theme listener: $e";
      _handleThemeError();
    }
  }

  void _handleThemeError() {
    if (_retryCount < _maxRetries) {
      print('[DEBUG] Theme error occurred, will retry...');
      retryThemeSetup();
    } else {
      print('[ERROR] Max retries reached for theme setup');
      themeError.value = "Failed to load theme after $_maxRetries attempts. Please check your connection.";
    }
  }

  void _updatePageList() {
    print('[DEBUG] Updating page list for theme: ${currentTheme.value}');
    
    // Use null-safe wallet setting
    final bool walletEnabled = Constant.walletSetting ?? false;
    final cacheKey = '${currentTheme.value}_$walletEnabled';
    
    // Check cache first
    if (_pageCache.containsKey(cacheKey)) {
      print('[DEBUG] Using cached page list for key: $cacheKey');
      pageList.value = _pageCache[cacheKey]!;
      update();
      return;
    }
    
    // Create new page list
    final List<Widget> newPages;
    
    if (currentTheme.value == "theme_2") {
      newPages = walletEnabled
          ? [
              const HomeScreen(),
              const FavouriteScreen(),
              const WalletScreen(),
              const OrderScreen(),
              const ProfileScreen(),
            ]
          : [
              const HomeScreen(),
              const FavouriteScreen(),
              const OrderScreen(),
              const ProfileScreen(),
            ];
    } else {
      newPages = walletEnabled
          ? [
              const HomeScreenTwo(),
              const FavouriteScreen(),
              const WalletScreen(),
              const OrderScreen(),
              const ProfileScreen(),
            ]
          : [
              const HomeScreenTwo(),
              const FavouriteScreen(),
              const OrderScreen(),
              const ProfileScreen(),
            ];
    }
    
    // Cache the new page list
    _pageCache[cacheKey] = newPages;
    print('[DEBUG] Created and cached new page list for key: $cacheKey');
    
    pageList.value = newPages;
    update();
  }

  // Method to update theme from external changes (called by Firestore listener)
  void updateTheme(String newTheme) {
    if (currentTheme.value != newTheme) {
      print('[DEBUG] External theme update: $newTheme');
      currentTheme.value = newTheme;
      Constant.theme = newTheme;
    }
  }

  /// 🔗 Process any pending deeplinks after home screen loads
  void _processPendingDeeplinks() async {
    try {
      print('🔗 [DASHBOARD] 🔍 Checking for pending deeplinks...');
      final globalHandler = GlobalDeeplinkHandler.instance;
      
      print('🔗 [DASHBOARD] 🔍 Global handler found: ${globalHandler != null}');
      print('🔗 [DASHBOARD] 🔍 Has pending deeplink: ${globalHandler.hasPendingDeeplink}');
      print('🔗 [DASHBOARD] 🔍 Pending deeplink: ${globalHandler.pendingDeeplink}');
      
      if (globalHandler.hasPendingDeeplink) {
        print('🔗 [DASHBOARD] ✅ Pending deeplink detected: ${globalHandler.pendingDeeplink}');
        print('🔗 [DASHBOARD] 🚀 Processing deeplink now...');
        
        // **OPTIMIZED: Reduced delay for faster navigation**
        print('🔗 [DASHBOARD] ⏳ Waiting for home screen to load before navigation...');
        await Future.delayed(Duration(milliseconds: 500));
        
        globalHandler.navigatePendingDeeplink();
        print('🔗 [DASHBOARD] ✅ Deeplink processing completed');
      } else {
        print('🔗 [DASHBOARD] ❌ No pending deeplinks found');
      }
    } catch (e) {
      print('🔗 [DASHBOARD] ❌ Error processing pending deeplinks: $e');
    }
  }

  // Manual refresh method for theme
  Future<void> refreshTheme() async {
    try {
      isThemeLoading.value = true;
      themeError.value = "";
      
      print('[DEBUG] Manually refreshing theme...');
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('home_page_theme')
          .get();
          
      if (doc.exists && doc.data() != null) {
        final newTheme = doc.data()!['theme'] as String? ?? 'theme_1';
        if (newTheme != currentTheme.value) {
          print('[DEBUG] Manual theme refresh: $newTheme');
          currentTheme.value = newTheme;
          Constant.theme = newTheme;
        } else {
          print('[DEBUG] Theme is already up to date: $newTheme');
        }
      } else {
        print('[DEBUG] Theme document not found, using default');
        currentTheme.value = 'theme_1';
        Constant.theme = 'theme_1';
      }
    } catch (e) {
      print('[ERROR] Refreshing theme: $e');
      themeError.value = "Failed to refresh theme: $e";
    } finally {
      isThemeLoading.value = false;
    }
  }

  // Manual test method for theme switching (for debugging)
  void testThemeSwitch() {
    String newTheme = currentTheme.value == "theme_1" ? "theme_2" : "theme_1";
    print('[DEBUG] Manual theme switch test: ${currentTheme.value} -> $newTheme');
    updateTheme(newTheme);
  }

  // Enhanced retry mechanism with exponential backoff
  Future<void> retryThemeSetup() async {
    if (_retryCount >= _maxRetries) {
      print('[ERROR] Max retries reached for theme setup');
      themeError.value = "Failed to load theme after $_maxRetries attempts. Please check your connection.";
      _retryCount = 0;
      return;
    }
    
    _retryCount++;
    final delay = Duration(seconds: pow(2, _retryCount).toInt());
    print('[DEBUG] Retry $_retryCount/$_maxRetries - Next retry in ${delay.inSeconds}s');
    
    _themeSubscription?.cancel();
    await Future.delayed(delay);
    _setupThemeListener();
  }

  // Clear cache method for memory management
  void clearPageCache() {
    print('[DEBUG] Clearing page cache...');
    _pageCache.clear();
  }

  // Get cache statistics for debugging
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _pageCache.length,
      'cacheKeys': _pageCache.keys.toList(),
      'retryCount': _retryCount,
      'maxRetries': _maxRetries,
    };
  }

  getTaxList() async {
    await FireStoreUtils.getTaxList().then(
      (value) {
        if (value != null) {
          Constant.taxList = value;
        }
      },
    );
  }

  @override
  void onClose() {
    // Cancel the Firestore subscription
    _themeSubscription?.cancel();
    _themeListener?.dispose(); // Dispose the ever listener
    print('[DEBUG] Theme subscription cancelled');
    super.onClose();
  }

  DateTime? currentBackPressTime;
  RxBool canPopNow = false.obs;
} 