import 'package:flutter/material.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/restaurant_status_manager.dart';

/// **Restaurant Status Utilities**
/// 
/// Provides helper methods for restaurant status checks across the app.
/// This class centralizes status logic and provides consistent behavior.
class RestaurantStatusUtils {
  static final RestaurantStatusManager _statusManager = RestaurantStatusManager();

  /// **CHECK IF RESTAURANT IS OPEN**
  /// 
  /// Uses the failproof system to determine if a restaurant is open
  /// @param vendor - The restaurant vendor model
  /// @return true if restaurant is open, false otherwise
  static bool isRestaurantOpen(VendorModel vendor) {
    return _statusManager.isRestaurantOpenNow(vendor.workingHours, vendor.isOpen);
  }

  /// **GET RESTAURANT STATUS INFO**
  /// 
  /// Returns comprehensive status information for a restaurant
  /// @param vendor - The restaurant vendor model
  /// @return Map containing status information
  static Map<String, dynamic> getRestaurantStatus(VendorModel vendor) {
    return _statusManager.getRestaurantStatus(vendor.workingHours, vendor.isOpen);
  }

  /// **CHECK IF RESTAURANT CAN ACCEPT ORDERS**
  /// 
  /// Determines if a restaurant can accept orders based on status
  /// @param vendor - The restaurant vendor model
  /// @return true if orders can be accepted, false otherwise
  static bool canAcceptOrders(VendorModel vendor) {
    return isRestaurantOpen(vendor);
  }

  /// **GET STATUS DISPLAY WIDGET**
  /// 
  /// Returns a widget to display restaurant status
  /// @param vendor - The restaurant vendor model
  /// @return Widget displaying the status
  static Widget getStatusWidget(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    final isClosed = !canAcceptOrders(vendor);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // Keep original padding
      decoration: BoxDecoration(
        color: isClosed ? Colors.red[600] : status['statusColor'],
        borderRadius: BorderRadius.circular(24), // Keep original border radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClosed ? Icons.lock : status['statusIcon'],
            color: Colors.white,
            size: 16, // Keep original size
          ),
          const SizedBox(width: 6), // Keep original spacing
          Text(
            isClosed ? 'Closed' : status['statusText'],
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, // Keep original weight
              fontSize: 12, // Keep original size
            ),
          ),
        ],
      ),
    );
  }

  /// **GET CLOSED MESSAGE WIDGET**
  /// 
  /// Returns a widget to display when restaurant is closed
  /// @param vendor - The restaurant vendor model
  /// @return Widget displaying closed message
  static Widget getClosedMessageWidget(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    
    return Center(
      child: Column(
        children: [
          Icon(Icons.lock, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          const Text(
            'This restaurant is currently closed.',
            style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            status['reason'],
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (status['nextOpeningTime'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Next opening: ${status['nextOpeningTime']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// **VALIDATE RESTAURANT STATUS**
  /// 
  /// Validates that restaurant status data is properly formatted
  /// @param vendor - The restaurant vendor model
  /// @return true if status data is valid, false otherwise
  static bool validateRestaurantStatus(VendorModel vendor) {
    return _statusManager.validateWorkingHours(vendor.workingHours);
  }

  /// **GET STATUS SUMMARY**
  /// 
  /// Returns a human-readable summary of restaurant status
  /// @param vendor - The restaurant vendor model
  /// @return String containing status summary
  static String getStatusSummary(VendorModel vendor) {
    return _statusManager.getStatusSummary(vendor.workingHours, vendor.isOpen);
  }

  /// **FILTER RESTAURANTS BY STATUS**
  /// 
  /// Filters a list of restaurants to show only open ones
  /// @param restaurants - List of restaurant vendor models
  /// @param showOnlyOpen - If true, show only open restaurants
  /// @return Filtered list of restaurants
  static List<VendorModel> filterRestaurantsByStatus(
    List<VendorModel> restaurants,
    {bool showOnlyOpen = true}
  ) {
    if (showOnlyOpen) {
      return restaurants.where((restaurant) => isRestaurantOpen(restaurant)).toList();
    }
    return restaurants;
  }

  /// **SORT RESTAURANTS BY STATUS**
  /// 
  /// Sorts restaurants with open ones first
  /// @param restaurants - List of restaurant vendor models
  /// @return Sorted list of restaurants
  static List<VendorModel> sortRestaurantsByStatus(List<VendorModel> restaurants) {
    final sorted = List<VendorModel>.from(restaurants);
    sorted.sort((a, b) {
      final aOpen = isRestaurantOpen(a);
      final bOpen = isRestaurantOpen(b);
      
      if (aOpen && !bOpen) return -1;
      if (!aOpen && bOpen) return 1;
      return 0;
    });
    
    return sorted;
  }

  /// **GET STATUS COLOR**
  /// 
  /// Returns the appropriate color for restaurant status
  /// @param vendor - The restaurant vendor model
  /// @return Color for the status
  static Color getStatusColor(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['statusColor'];
  }

  /// **GET STATUS ICON**
  /// 
  /// Returns the appropriate icon for restaurant status
  /// @param vendor - The restaurant vendor model
  /// @return IconData for the status
  static IconData getStatusIcon(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['statusIcon'];
  }

  /// **GET STATUS TEXT**
  /// 
  /// Returns the appropriate text for restaurant status
  /// @param vendor - The restaurant vendor model
  /// @return String for the status
  static String getStatusText(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['statusText'];
  }

  /// **GET STATUS REASON**
  /// 
  /// Returns the reason for the current status
  /// @param vendor - The restaurant vendor model
  /// @return String explaining the status
  static String getStatusReason(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['reason'];
  }

  /// **GET NEXT OPENING TIME**
  /// 
  /// Returns the next time the restaurant will be open
  /// @param vendor - The restaurant vendor model
  /// @return String with next opening time or null
  static String? getNextOpeningTime(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['nextOpeningTime'];
  }

  /// **CHECK IF RESTAURANT IS MANUALLY CLOSED**
  /// 
  /// Checks if restaurant is manually closed by owner
  /// @param vendor - The restaurant vendor model
  /// @return true if manually closed, false otherwise
  static bool isManuallyClosed(VendorModel vendor) {
    return vendor.isOpen == false;
  }

  /// **CHECK IF RESTAURANT HAS NO MANUAL TOGGLE**
  /// 
  /// Checks if restaurant has no manual toggle set
  /// @param vendor - The restaurant vendor model
  /// @return true if no manual toggle, false otherwise
  static bool hasNoManualToggle(VendorModel vendor) {
    return vendor.isOpen == null;
  }

  /// **CHECK IF RESTAURANT IS WITHIN WORKING HOURS**
  /// 
  /// Checks if current time is within restaurant's working hours
  /// @param vendor - The restaurant vendor model
  /// @return true if within working hours, false otherwise
  static bool isWithinWorkingHours(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['withinWorkingHours'];
  }

  /// **CHECK IF RESTAURANT HAS WORKING HOURS**
  /// 
  /// Checks if restaurant has working hours configured
  /// @param vendor - The restaurant vendor model
  /// @return true if has working hours, false otherwise
  static bool hasWorkingHours(VendorModel vendor) {
    final status = getRestaurantStatus(vendor);
    return status['hasWorkingHours'];
  }
}
