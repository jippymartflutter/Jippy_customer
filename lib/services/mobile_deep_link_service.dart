import 'dart:async';
import 'dart:developer' as developer;
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

/// Mobile Deep Link Service for handling incoming deep links
/// Supports both HTTPS and custom scheme links
class MobileDeepLinkService {
  static final MobileDeepLinkService _instance = MobileDeepLinkService._internal();
  factory MobileDeepLinkService() => _instance;
  MobileDeepLinkService._internal();

  StreamSubscription? _linkSubscription;
  bool _isInitialized = false;
  String? _pendingDeepLink;
  final AppLinks _appLinks = AppLinks();

  /// Initialize the deep link service
  Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('🔗 [MOBILE_DEEP_LINK] Service already initialized');
      return;
    }

    developer.log('🔗 [MOBILE_DEEP_LINK] Initializing Mobile Deep Link Service...');
    
    try {
      // Handle incoming links when app is running
      _handleIncomingLinks();
      
      // Handle initial link when app is opened from a deep link
      await _handleInitialLink();
      
      // Check for pending deep links from web page
      await _checkPendingDeepLinks();
      
      _isInitialized = true;
      developer.log('🔗 [MOBILE_DEEP_LINK] Service initialized successfully');
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error initializing service: $e');
    }
  }

  /// Handle incoming links when app is already running
  void _handleIncomingLinks() {
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        final link = uri.toString();
        if (link.isNotEmpty) {
          developer.log('🔗 [MOBILE_DEEP_LINK] Incoming link received: $link');
          _processDeepLink(link);
        }
      },
      onError: (err) {
        developer.log('❌ [MOBILE_DEEP_LINK] Error in link stream: $err');
      },
    );
  }

  /// Handle initial link when app is opened from a deep link
  Future<void> _handleInitialLink() async {
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        final link = initialUri.toString();
        developer.log('🔗 [MOBILE_DEEP_LINK] Initial link received: $link');
        _processDeepLink(link);
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error getting initial link: $e');
    }
  }

  /// Check for pending deep links stored by web page
  Future<void> _checkPendingDeepLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingLink = prefs.getString('pendingDeepLink');
      
      if (pendingLink != null && pendingLink.isNotEmpty) {
        developer.log('🔗 [MOBILE_DEEP_LINK] Found pending deep link: $pendingLink');
        
        // Clear the pending link
        await prefs.remove('pendingDeepLink');
        await prefs.remove('pendingProductId');
        
        // Process the pending link
        _processDeepLink(pendingLink);
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error checking pending links: $e');
    }
  }

  /// Process a deep link and determine the action
  void _processDeepLink(String link) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Processing deep link: $link');
    
    try {
      if (link.startsWith('jippymart://')) {
        // Custom scheme: jippymart://product/123
        _handleCustomScheme(link);
      } else if (link.contains('jippymart.in')) {
        // HTTPS scheme: https://jippymart.in/product/123
        _handleHttpsScheme(link);
      } else {
        developer.log('❌ [MOBILE_DEEP_LINK] Unknown link format: $link');
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error processing deep link: $e');
    }
  }

  /// Handle custom scheme links (jippymart://)
  void _handleCustomScheme(String link) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Handling custom scheme: $link');
    
    try {
      final uri = Uri.parse(link);
      final segments = uri.pathSegments;
      
      if (segments.length >= 2) {
        final type = segments[0]; // product, restaurant, mart
        final id = segments[1];   // 123
        
        developer.log('🔗 [MOBILE_DEEP_LINK] Custom scheme - Type: $type, ID: $id');
        _navigateToContent(type, id);
      } else {
        developer.log('❌ [MOBILE_DEEP_LINK] Invalid custom scheme format: $link');
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error parsing custom scheme: $e');
    }
  }

  /// Handle HTTPS scheme links (https://jippymart.in)
  void _handleHttpsScheme(String link) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Handling HTTPS scheme: $link');
    
    try {
      final uri = Uri.parse(link);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 2) {
        final type = pathSegments[0]; // product, restaurant, mart
        final id = pathSegments[1];   // 123
        
        developer.log('🔗 [MOBILE_DEEP_LINK] HTTPS scheme - Type: $type, ID: $id');
        _navigateToContent(type, id);
      } else {
        developer.log('❌ [MOBILE_DEEP_LINK] Invalid HTTPS scheme format: $link');
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error parsing HTTPS scheme: $e');
    }
  }

  /// Navigate to the appropriate screen based on link type
  void _navigateToContent(String type, String id) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Navigating to $type with ID: $id');
    
    try {
      switch (type.toLowerCase()) {
        case 'product':
          _navigateToProduct(id);
          break;
        case 'restaurant':
          _navigateToRestaurant(id);
          break;
        case 'mart':
          _navigateToMart(id);
          break;
        default:
          developer.log('❌ [MOBILE_DEEP_LINK] Unknown content type: $type');
      }
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error navigating to content: $e');
    }
  }

  /// Navigate to product details screen
  void _navigateToProduct(String productId) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Navigating to product: $productId');
    
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(Duration(milliseconds: 500), () {
      try {
        // Navigate to product details screen
        // This will be implemented based on your app's navigation structure
        Get.toNamed('/product-detail', arguments: {'id': productId});
        developer.log('✅ [MOBILE_DEEP_LINK] Navigated to product: $productId');
      } catch (e) {
        developer.log('❌ [MOBILE_DEEP_LINK] Error navigating to product: $e');
      }
    });
  }

  /// Navigate to restaurant details screen
  void _navigateToRestaurant(String restaurantId) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Navigating to restaurant: $restaurantId');
    
    Future.delayed(Duration(milliseconds: 500), () {
      try {
        // Navigate to restaurant details screen
        Get.toNamed('/restaurant-detail', arguments: {'id': restaurantId});
        developer.log('✅ [MOBILE_DEEP_LINK] Navigated to restaurant: $restaurantId');
      } catch (e) {
        developer.log('❌ [MOBILE_DEEP_LINK] Error navigating to restaurant: $e');
      }
    });
  }

  /// Navigate to mart/category screen
  void _navigateToMart(String martId) {
    developer.log('🔗 [MOBILE_DEEP_LINK] Navigating to mart: $martId');
    
    Future.delayed(Duration(milliseconds: 500), () {
      try {
        // Navigate to mart/category screen
        Get.toNamed('/mart-detail', arguments: {'id': martId});
        developer.log('✅ [MOBILE_DEEP_LINK] Navigated to mart: $martId');
      } catch (e) {
        developer.log('❌ [MOBILE_DEEP_LINK] Error navigating to mart: $e');
      }
    });
  }

  /// Store a pending deep link for later processing
  Future<void> storePendingDeepLink(String link) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pendingDeepLink', link);
      developer.log('🔗 [MOBILE_DEEP_LINK] Stored pending deep link: $link');
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error storing pending link: $e');
    }
  }

  /// Clear pending deep links
  Future<void> clearPendingDeepLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pendingDeepLink');
      await prefs.remove('pendingProductId');
      developer.log('🔗 [MOBILE_DEEP_LINK] Cleared pending deep links');
    } catch (e) {
      developer.log('❌ [MOBILE_DEEP_LINK] Error clearing pending links: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
    _isInitialized = false;
    developer.log('🔗 [MOBILE_DEEP_LINK] Service disposed');
  }
}
