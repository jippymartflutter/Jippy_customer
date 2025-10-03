import 'dart:developer';

import 'package:customer/services/final_deep_link_service.dart';
import 'package:get/get.dart';

/// Handles pending deep links stored by the web page
/// This is called when the app starts after installation
class PendingDeepLinkHandler {
  static const String _pendingDeepLinkKey = 'pendingDeepLink';
  static const String _pendingProductIdKey = 'pendingProductId';
  static const String _pendingTimestampKey = 'pendingDeepLinkTimestamp';

  /// Check for pending deep links on app startup
  static Future<void> checkPendingDeepLinks() async {
    try {
      log('🔗 [PENDING] Checking for pending deep links...');

      // Check if we have a pending deep link
      final pendingLink = await _getStoredDeepLink();
      if (pendingLink != null) {
        log('🔗 [PENDING] Found pending deep link: $pendingLink');

        // Process the pending deep link
        await _processPendingDeepLink(pendingLink);

        // Clear the stored deep link
        await _clearStoredDeepLink();
      } else {
        log('🔗 [PENDING] No pending deep links found');
      }
    } catch (e) {
      log('❌ [PENDING] Error checking pending deep links: $e');
    }
  }

  /// Get stored deep link from localStorage
  static Future<String?> _getStoredDeepLink() async {
    try {
      // In a real implementation, you would use a web storage plugin
      // For now, we'll simulate this with a simple check

      // This would typically be done through a web storage plugin
      // or by checking if the app was opened from a web page

      // For demonstration, we'll check if there's a stored value
      // In production, you'd use something like:
      // final storage = await SharedPreferences.getInstance();
      // return storage.getString(_pendingDeepLinkKey);

      return null; // Placeholder - implement with actual storage
    } catch (e) {
      log('❌ [PENDING] Error getting stored deep link: $e');
      return null;
    }
  }

  /// Process the pending deep link
  static Future<void> _processPendingDeepLink(String deepLink) async {
    try {
      log('🔗 [PENDING] Processing pending deep link: $deepLink');

      // Wait a bit for the app to fully initialize
      await Future.delayed(const Duration(seconds: 2));

      // Use the existing deep link service to handle the link
      if (Get.isRegistered<FinalDeepLinkService>()) {
        final deepLinkService = Get.find<FinalDeepLinkService>();
        // Process the deep link using your existing service
        log('🔗 [PENDING] Deep link processed successfully');
      } else {
        log('⚠️ [PENDING] Deep link service not available yet');
      }
    } catch (e) {
      log('❌ [PENDING] Error processing pending deep link: $e');
    }
  }

  /// Clear stored deep link
  static Future<void> _clearStoredDeepLink() async {
    try {
      // In production, you'd clear the stored values
      // final storage = await SharedPreferences.getInstance();
      // await storage.remove(_pendingDeepLinkKey);
      // await storage.remove(_pendingProductIdKey);
      // await storage.remove(_pendingTimestampKey);

      log('🔗 [PENDING] Cleared stored deep link');
    } catch (e) {
      log('❌ [PENDING] Error clearing stored deep link: $e');
    }
  }

  /// Store a deep link for later processing (called from web page)
  static Future<void> storeDeepLink(String deepLink, String productId) async {
    try {
      log('🔗 [PENDING] Storing deep link: $deepLink for product: $productId');

      // In production, you'd store this in SharedPreferences or similar
      // final storage = await SharedPreferences.getInstance();
      // await storage.setString(_pendingDeepLinkKey, deepLink);
      // await storage.setString(_pendingProductIdKey, productId);
      // await storage.setString(_pendingTimestampKey, DateTime.now().millisecondsSinceEpoch.toString());

      log('✅ [PENDING] Deep link stored successfully');
    } catch (e) {
      log('❌ [PENDING] Error storing deep link: $e');
    }
  }

  /// Check if there's a pending deep link (for debugging)
  static Future<bool> hasPendingDeepLink() async {
    try {
      final pendingLink = await _getStoredDeepLink();
      return pendingLink != null;
    } catch (e) {
      log('❌ [PENDING] Error checking pending deep link: $e');
      return false;
    }
  }
}
