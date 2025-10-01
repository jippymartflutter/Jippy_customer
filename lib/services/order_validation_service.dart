import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user_model.dart';
import '../models/zone_model.dart';
import '../constant/constant.dart';
import '../utils/fire_store_utils.dart';

/// Service for validating orders before placement
/// Ensures delivery address is within vendor's delivery zone
class OrderValidationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Validates if the selected delivery address is within the vendor's delivery zone
  /// 
  /// [addressId] - ID of the selected delivery address
  /// [vendorId] - ID of the vendor/restaurant
  /// 
  /// Returns true if address is valid, throws exception if invalid
  Future<bool> validateDeliveryAddress(String addressId, String vendorId) async {
    try {
      print('🔍 Validating delivery address: $addressId for vendor: $vendorId');
      
      // Get address details
      final addressDoc = await _firestore
          .collection('addresses')
          .doc(addressId)
          .get();

      if (!addressDoc.exists) {
        throw 'Address not found';
      }

      final address = ShippingAddress.fromJson(addressDoc.data()!);
      print('📍 Address zone: ${address.zoneId}');

      // Get vendor details
      final vendorDoc = await _firestore
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (!vendorDoc.exists) {
        throw 'Vendor not found';
      }

      final vendor = vendorDoc.data()!;
      final vendorZoneId = vendor['zoneId'] ?? '';
      print('🏪 Vendor zone: $vendorZoneId');

      // Validate zone match
      if (address.zoneId != vendorZoneId) {
        print('❌ Zone mismatch: Address zone (${address.zoneId}) != Vendor zone ($vendorZoneId)');
        throw 'Selected address is outside vendor delivery zone';
      }

      print('✅ Address validation successful');
      return true;
    } catch (e) {
      print('❌ Address validation error: $e');
      rethrow;
    }
  }

  /// Validates the entire order before placement
  /// 
  /// [addressId] - ID of the selected delivery address
  /// [vendorId] - ID of the vendor/restaurant
  /// [items] - List of items in the order
  /// 
  /// Throws exception if validation fails
  Future<void> validateOrderBeforePlacement({
    required String addressId,
    required String vendorId,
    required List<dynamic> items,
  }) async {
    try {
      // Validate delivery address
      await validateDeliveryAddress(addressId, vendorId);
      
      // Add other validations here (minimum order, item availability, etc.)
      print('✅ All order validations passed');
    } catch (e) {
      print('❌ Order validation failed: $e');
      rethrow;
    }
  }

  /// Gets user-friendly error message for validation failures
  /// 
  /// [error] - The error message from validation
  /// 
  /// Returns user-friendly error message
  String getErrorMessage(String error) {
    if (error.contains('outside vendor delivery zone')) {
      return 'Sorry, delivery is not available to this address. Please select an address within our delivery zone.';
    } else if (error.contains('Address not found')) {
      return 'Selected address not found. Please select a different address.';
    } else if (error.contains('Vendor not found')) {
      return 'Vendor not found. Please try again.';
    } else {
      return 'Unable to place order. Please try again.';
    }
  }

  /// 🔑 DETECT ZONE ID FOR ADDRESS COORDINATES
  /// 
  /// This method detects the zone ID for an address that doesn't have one
  /// by checking if the coordinates fall within any zone polygon
  Future<String?> detectZoneIdForAddress(ShippingAddress address) async {
    try {
      print('🔍 [ORDER_VALIDATION] Detecting zone ID for address: ${address.id}');
      
      if (address.location?.latitude == null || address.location?.longitude == null) {
        print('🔍 [ORDER_VALIDATION] Address has no coordinates');
        return null;
      }
      
      // Get all zones from Firestore
      List<ZoneModel>? zones = await FireStoreUtils.getZone();
      
      if (zones == null || zones.isEmpty) {
        print('🔍 [ORDER_VALIDATION] No zones available in database');
        return null;
      }
      
      print('🔍 [ORDER_VALIDATION] Found ${zones.length} zones to check');
      
      // Check if coordinates fall within any zone polygon
      for (ZoneModel zone in zones) {
        if (zone.area != null && zone.area!.isNotEmpty) {
          print('🔍 [ORDER_VALIDATION] Checking zone: ${zone.name} (${zone.id})');
          
          // Use the existing polygon validation logic
          if (Constant.isPointInPolygon(
            LatLng(address.location!.latitude!, address.location!.longitude!),
            zone.area!,
          )) {
            print('🔍 [ORDER_VALIDATION] Zone detected: ${zone.name} (${zone.id})');
            return zone.id;
          }
        }
      }
      
      print('🔍 [ORDER_VALIDATION] Address coordinates not within any service zone');
      return null;
      
    } catch (e) {
      print('🔍 [ORDER_VALIDATION] Error detecting zone: $e');
      return null;
    }
  }

  /// Validates if a specific address is within a vendor's delivery zone
  /// 
  /// [address] - The address to validate
  /// [vendorId] - ID of the vendor/restaurant
  /// 
  /// Returns true if address is valid, false otherwise
  Future<bool> isAddressValidForVendor(ShippingAddress address, String vendorId) async {
    try {
      // Get vendor details
      final vendorDoc = await _firestore
          .collection('vendors')
          .doc(vendorId)
          .get();

      if (!vendorDoc.exists) {
        return false;
      }

      final vendor = vendorDoc.data()!;
      final vendorZoneId = vendor['zoneId'] ?? '';

      // Check zone match
      return address.zoneId == vendorZoneId;
    } catch (e) {
      print('❌ Error checking address validity: $e');
      return false;
    }
  }

  /// Gets all valid addresses for a specific vendor
  /// 
  /// [userId] - ID of the user
  /// [vendorId] - ID of the vendor/restaurant
  /// 
  /// Returns list of valid addresses
  Future<List<ShippingAddress>> getValidAddressesForVendor(String userId, String vendorId) async {
    try {
      // Get all user addresses
      final addressesSnapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      final addresses = addressesSnapshot.docs
          .map((doc) => ShippingAddress.fromJson(doc.data()))
          .toList();

      // Filter valid addresses
      final validAddresses = <ShippingAddress>[];
      for (final address in addresses) {
        if (await isAddressValidForVendor(address, vendorId)) {
          validAddresses.add(address);
        }
      }

      return validAddresses;
    } catch (e) {
      print('❌ Error getting valid addresses: $e');
      return [];
    }
  }
}
