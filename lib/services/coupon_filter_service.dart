import 'package:customer/models/coupon_model.dart';

/// Service to filter coupons based on context (mart vs restaurant)
class CouponFilterService {
  
  /// Filter coupons based on context type
  /// 
  /// [coupons] - List of all available coupons
  /// [contextType] - "mart" or "restaurant"
  /// [fallbackEnabled] - Whether to include coupons without cType as fallback
  /// 
  /// Returns filtered list of coupons applicable to the given context
  static List<CouponModel> filterCouponsByContext({
    required List<CouponModel> coupons,
    required String contextType,
    bool fallbackEnabled = true,
  }) {
    try {
      print('[COUPON_FILTER] 🔍 Filtering ${coupons.length} coupons for context: $contextType');
      
      final List<CouponModel> filteredCoupons = [];
      final List<CouponModel> fallbackCoupons = [];
      
      for (final coupon in coupons) {
        // Skip disabled coupons
        if (coupon.isEnabled == false) {
          continue;
        }
        
        // Check if coupon has cType field
        if (coupon.cType != null && coupon.cType!.isNotEmpty) {
          // Coupon has explicit type - check if it matches context
          if (coupon.cType!.toLowerCase() == contextType.toLowerCase()) {
            filteredCoupons.add(coupon);
            print('[COUPON_FILTER] ✅ Added ${coupon.code} (${coupon.cType})');
          } else {
            print('[COUPON_FILTER] ❌ Skipped ${coupon.code} (${coupon.cType} != $contextType)');
          }
        } else {
          // Coupon doesn't have cType - add to fallback list
          if (fallbackEnabled) {
            fallbackCoupons.add(coupon);
            print('[COUPON_FILTER] 🔄 Added ${coupon.code} to fallback (no cType)');
          } else {
            print('[COUPON_FILTER] ⚠️ Skipped ${coupon.code} (no cType, fallback disabled)');
          }
        }
      }
      
      // Combine filtered coupons with fallback coupons
      final result = [...filteredCoupons, ...fallbackCoupons];
      
      print('[COUPON_FILTER] 📊 Result: ${filteredCoupons.length} context-specific + ${fallbackCoupons.length} fallback = ${result.length} total');
      
      return result;
      
    } catch (e) {
      print('[COUPON_FILTER] ❌ Error filtering coupons: $e');
      // Return all coupons as fallback if filtering fails
      return coupons.where((c) => c.isEnabled != false).toList();
    }
  }
  
  /// Get mart-specific coupons
  static List<CouponModel> getMartCoupons({
    required List<CouponModel> coupons,
    bool fallbackEnabled = true,
  }) {
    return filterCouponsByContext(
      coupons: coupons,
      contextType: 'mart',
      fallbackEnabled: fallbackEnabled,
    );
  }
  
  /// Get restaurant-specific coupons
  static List<CouponModel> getRestaurantCoupons({
    required List<CouponModel> coupons,
    bool fallbackEnabled = true,
  }) {
    return filterCouponsByContext(
      coupons: coupons,
      contextType: 'restaurant',
      fallbackEnabled: fallbackEnabled,
    );
  }
  
  /// Check if a coupon is applicable for the given context
  static bool isCouponApplicable({
    required CouponModel coupon,
    required String contextType,
    bool fallbackEnabled = true,
  }) {
    // Skip disabled coupons
    if (coupon.isEnabled == false) {
      return false;
    }
    
    // If coupon has cType, check if it matches
    if (coupon.cType != null && coupon.cType!.isNotEmpty) {
      return coupon.cType!.toLowerCase() == contextType.toLowerCase();
    }
    
    // If no cType, allow as fallback if enabled
    return fallbackEnabled;
  }
  
  /// Get coupon statistics for debugging
  static Map<String, int> getCouponStats(List<CouponModel> coupons) {
    int martCoupons = 0;
    int restaurantCoupons = 0;
    int noTypeCoupons = 0;
    int disabledCoupons = 0;
    
    for (final coupon in coupons) {
      if (coupon.isEnabled == false) {
        disabledCoupons++;
        continue;
      }
      
      if (coupon.cType == null || coupon.cType!.isEmpty) {
        noTypeCoupons++;
      } else if (coupon.cType!.toLowerCase() == 'mart') {
        martCoupons++;
      } else if (coupon.cType!.toLowerCase() == 'restaurant') {
        restaurantCoupons++;
      }
    }
    
    return {
      'total': coupons.length,
      'mart': martCoupons,
      'restaurant': restaurantCoupons,
      'no_type': noTypeCoupons,
      'disabled': disabledCoupons,
    };
  }
}
