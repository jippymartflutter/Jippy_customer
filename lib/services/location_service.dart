import 'dart:developer';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {

  /// Get current location with proper error handling
  static Future<Position?> getCurrentLocation({
    bool showLoader = true,
    bool showError = true,
  }) async {
    try {
      if (showLoader) {
        ShowToastDialog.showLoader("Getting your location...".tr);
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log('[LOCATION_SERVICE] Location services disabled');
        if (showLoader) ShowToastDialog.closeLoader();
        if (showError) {
          ShowToastDialog.showToast("Please enable location services in your device settings".tr);
        }
        return null;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        log('[LOCATION_SERVICE] Requesting location permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (showLoader) ShowToastDialog.closeLoader();
          if (showError) {
            ShowToastDialog.showToast("Location permission denied".tr);
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (showLoader) ShowToastDialog.closeLoader();
        if (showError) {
          ShowToastDialog.showToast("Location permissions are permanently denied. Please enable them in settings.".tr);
        }
        return null;
      }

      // Get current position with timeout
      log('[LOCATION_SERVICE] Getting current position...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      log('[LOCATION_SERVICE] Position obtained: ${position.latitude}, ${position.longitude}');
      if (showLoader) ShowToastDialog.closeLoader();
      return position;

    } catch (e) {
      log('[LOCATION_SERVICE] Error getting location: $e');
      if (showLoader) ShowToastDialog.closeLoader();
      if (showError) {
        ShowToastDialog.showToast("Failed to get current location. Please try again.".tr);
      }
      return null;
    }
  }

  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        return "${placemark.name}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}";
      }
      return null;
    } catch (e) {
      log('[LOCATION_SERVICE] Error getting address: $e');
      return null;
    }
  }

  /// Create shipping address from current location
  static Future<ShippingAddress?> createShippingAddressFromLocation({
    bool showLoader = true,
    bool showError = true,
  }) async {
    try {
      Position? position = await getCurrentLocation(
        showLoader: showLoader,
        showError: showError,
      );

      if (position == null) {
        return null;
      }

      ShippingAddress addressModel = ShippingAddress();
      addressModel.id = 'current_location_${DateTime.now().millisecondsSinceEpoch}'; // 🔑 Add unique ID
      addressModel.addressAs = "Current Location";
      addressModel.location = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      // Get address string
      String? addressString = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (addressString != null) {
        addressModel.locality = addressString;
        addressModel.address = addressString; // Add address field
      } else {
        // Fallback address
        addressModel.locality = "Current Location";
        addressModel.address = "Current Location";
      }

      // 🔑 CRITICAL: Detect zone ID for current location
      String? detectedZoneId = await _detectZoneIdForCoordinates(position.latitude, position.longitude);
      addressModel.zoneId = detectedZoneId;
      
      log('[LOCATION_SERVICE] Created current location address with ID: ${addressModel.id} and zone ID: ${detectedZoneId ?? "NULL"}');

      return addressModel;

    } catch (e) {
      log('[LOCATION_SERVICE] Error creating shipping address: $e');
      if (showError) {
        ShowToastDialog.showToast("Failed to get location details. Please try again.".tr);
      }
      return null;
    }
  }

  /// Update location and navigate to dashboard
  static Future<bool> updateLocationAndNavigate({
    bool showLoader = true,
    bool showError = true,
  }) async {
    try {
      ShippingAddress? addressModel = await createShippingAddressFromLocation(
        showLoader: showLoader,
        showError: showError,
      );

      if (addressModel == null) {
        return false;
      }

      // Update global location
      Constant.selectedLocation = addressModel;

      // Save to local storage
      await Preferences.setString('user_location', addressModel.location!.toJson().toString());

      // Update user profile if logged in
      if (Constant.userModel != null) {
        try {
          await FireStoreUtils.updateUser(Constant.userModel!);
        } catch (e) {
          log('[LOCATION_SERVICE] Error updating user profile: $e');
        }
      }

      log('[LOCATION_SERVICE] Location updated successfully');
      return true;

    } catch (e) {
      log('[LOCATION_SERVICE] Error updating location: $e');
      if (showError) {
        ShowToastDialog.showToast("Failed to update location. Please try again.".tr);
      }
      return false;
    }
  }

  /// Check if location is within service area
  static Future<bool> isLocationInServiceArea(double latitude, double longitude) async {
    try {
      // Get zones and check if location is within any zone
      List<ZoneModel>? zones = await FireStoreUtils.getZone();
      
      if (zones != null) {
        for (ZoneModel zone in zones) {
          if (zone.area != null && Constant.isPointInPolygon(
            LatLng(latitude, longitude),
            zone.area!,
          )) {
            Constant.selectedZone = zone;
            Constant.isZoneAvailable = true;
            return true;
          }
        }
      }
      
      return false;
    } catch (e) {
      log('[LOCATION_SERVICE] Error checking service area: $e');
      return false;
    }
  }

  /// 🔑 DETECT ZONE ID FOR COORDINATES
  /// 
  /// This method detects the zone ID for given coordinates by checking
  /// if the coordinates fall within any zone polygon
  static Future<String?> _detectZoneIdForCoordinates(double latitude, double longitude) async {
    try {
      log('[LOCATION_SERVICE] Starting zone detection for coordinates: $latitude, $longitude');
      
      // Get all zones from Firestore
      List<ZoneModel>? zones = await FireStoreUtils.getZone();
      
      if (zones == null || zones.isEmpty) {
        log('[LOCATION_SERVICE] No zones available in database');
        return null;
      }
      
      log('[LOCATION_SERVICE] Found ${zones.length} zones to check');
      
      // Check if coordinates fall within any zone polygon
      for (ZoneModel zone in zones) {
        if (zone.area != null && zone.area!.isNotEmpty) {
          log('[LOCATION_SERVICE] Checking zone: ${zone.name} (${zone.id})');
          
          // Use the existing polygon validation logic
          if (Constant.isPointInPolygon(
            LatLng(latitude, longitude),
            zone.area!,
          )) {
            log('[LOCATION_SERVICE] Zone detected: ${zone.name} (${zone.id})');
            return zone.id;
          }
        }
      }
      
      log('[LOCATION_SERVICE] Coordinates not within any service zone');
      return null;
      
    } catch (e) {
      log('[LOCATION_SERVICE] Error detecting zone: $e');
      return null;
    }
  }

  /// Validate location coordinates
  static bool isValidLocation(double latitude, double longitude) {
    return latitude >= -90 && latitude <= 90 && 
           longitude >= -180 && longitude <= 180 &&
           latitude != 0 && longitude != 0;
  }
} 