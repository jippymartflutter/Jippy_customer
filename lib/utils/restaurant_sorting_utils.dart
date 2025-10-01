import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/restaurant_status_utils.dart';

/// **HELPER METHOD TO SORT RESTAURANTS - CLOSED AT BOTTOM**
List<VendorModel> sortRestaurantsWithClosedAtBottom(List<VendorModel> restaurants) {
  final sortedList = List<VendorModel>.from(restaurants);
  
  sortedList.sort((a, b) {
    final aIsOpen = RestaurantStatusUtils.canAcceptOrders(a);
    final bIsOpen = RestaurantStatusUtils.canAcceptOrders(b);
    
    // **OPEN RESTAURANTS FIRST, CLOSED RESTAURANTS LAST**
    if (aIsOpen && !bIsOpen) return -1;  // a is open, b is closed -> a comes first
    if (!aIsOpen && bIsOpen) return 1;   // a is closed, b is open -> b comes first
    
    // **IF BOTH HAVE SAME STATUS, MAINTAIN ORIGINAL ORDER**
    return 0;
  });
  
  return sortedList;
}
