import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geocoding/geocoding.dart';

/// **GPS Location Service for Zone Detection**
/// 
/// This service provides GPS-based location detection as a fallback
/// when user shipping addresses are not available.
/// 
/// Features:
/// - GPS location detection
/// - Location caching in local storage
/// - Permission handling
/// - Fallback mechanisms
/// - Real-time location updates
class GpsLocationService {
  static final GpsLocationService _instance = GpsLocationService._internal();
  factory GpsLocationService() => _instance;
  GpsLocationService._internal();

  static const String _locationCacheKey = 'gps_location_cache';
  static const String _locationTimestampKey = 'gps_location_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 1);

  /// **Get Current GPS Location**
  /// 
  /// Returns GPS coordinates with caching and fallback mechanisms
  /// 
  /// Priority:
  /// 1. Fresh GPS location (if available and recent)
  /// 2. Cached GPS location (if not expired)
  /// 3. Null (if no location available)
  static Future<Position?> getCurrentLocation() async {
    try {
      print('[GPS_LOCATION] Getting current GPS location...');
      
      // Check if we have recent cached location
      final cachedLocation = await _getCachedLocation();
      if (cachedLocation != null) {
        print('[GPS_LOCATION] Using cached location: ${cachedLocation.latitude}, ${cachedLocation.longitude}');
        return cachedLocation;
      }

      // Check location permissions
      final hasPermission = await _checkLocationPermissions();
      if (!hasPermission) {
        print('[GPS_LOCATION] Location permissions not granted');
        return null;
      }

      // Check if location services are enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        print('[GPS_LOCATION] Location services are disabled');
        return null;
      }

      // Get current GPS location with retry mechanism
      print('[GPS_LOCATION] Requesting fresh GPS location...');
      Position? position;
      
      // Retry mechanism with proper delays for GPS lock
      for (int attempt = 1; attempt <= 3; attempt++) {
        try {
          print('[GPS_LOCATION] GPS attempt $attempt/3');
          
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium, // Balanced accuracy for speed
            timeLimit: const Duration(seconds: 10), // Increased timeout for GPS lock
          ).timeout(
            const Duration(seconds: 12), // Additional timeout wrapper
            onTimeout: () {
              print('[GPS_LOCATION] GPS location request timed out (attempt $attempt)');
              throw TimeoutException('GPS location request timed out', const Duration(seconds: 12));
            },
          );
          
          // If we got a valid position, break out of retry loop
          if (position.latitude != 0 && position.longitude != 0) {
            print('[GPS_LOCATION] GPS location obtained on attempt $attempt: ${position.latitude}, ${position.longitude}');
            break;
          }
          
        } catch (e) {
          print('[GPS_LOCATION] GPS attempt $attempt failed: $e');
          
          // If this is not the last attempt, wait before retrying
          if (attempt < 3) {
            print('[GPS_LOCATION] Waiting 3 seconds before retry...');
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      // Check if we successfully got a position
      if (position != null && position.latitude != 0 && position.longitude != 0) {
        // Cache the location
        await _cacheLocation(position);
        return position;
      } else {
        print('[GPS_LOCATION] Failed to get GPS location after 3 attempts');
        return null;
      }
    } on TimeoutException catch (e) {
      print('[GPS_LOCATION] GPS location request timed out: $e');
      return null;
    } catch (e) {
      print('[GPS_LOCATION] Error getting GPS location: $e');
      return null;
    }
  }

  /// **Check Location Permissions**
  /// 
  /// Requests and checks location permissions
  static Future<bool> _checkLocationPermissions() async {
    try {
      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('[GPS_LOCATION] Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('[GPS_LOCATION] Location permission denied forever');
        return false;
      }

      print('[GPS_LOCATION] Location permission granted');
      return true;
    } catch (e) {
      print('[GPS_LOCATION] Error checking location permissions: $e');
      return false;
    }
  }

  /// **Get Cached Location**
  /// 
  /// Retrieves cached GPS location if it's not expired
  static Future<Position?> _getCachedLocation() async {
    try {
      final box = GetStorage();
      final cachedLat = box.read('${_locationCacheKey}_lat');
      final cachedLng = box.read('${_locationCacheKey}_lng');
      final cachedAddress = box.read('${_locationCacheKey}_address');
      final cachedLocality = box.read('${_locationCacheKey}_locality');
      final cachedTimestamp = box.read(_locationTimestampKey);

      if (cachedLat != null && cachedLng != null && cachedTimestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cacheTime) < _cacheExpiry) {
          print('[GPS_LOCATION] Using cached location: ${cachedLat}, ${cachedLng} - ${cachedAddress ?? 'No address'}');
          return Position(
            latitude: cachedLat,
            longitude: cachedLng,
            timestamp: cacheTime,
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        } else {
          print('[GPS_LOCATION] Cached location expired');
          // Clear expired cache
          await _clearCachedLocation();
        }
      }
      
      return null;
    } catch (e) {
      print('[GPS_LOCATION] Error getting cached location: $e');
      return null;
    }
  }

  /// **Cache Location**
  /// 
  /// Saves GPS location to local storage
  static Future<void> _cacheLocation(Position position) async {
    try {
      final box = GetStorage();
      
      // Get address from coordinates
      String address = '';
      try {
        address = await getAddressFromCoordinates(position.latitude, position.longitude);
      } catch (e) {
        print('[GPS_LOCATION] Error getting address for caching: $e');
        address = 'Current Location';
      }
      
      await box.write('${_locationCacheKey}_lat', position.latitude);
      await box.write('${_locationCacheKey}_lng', position.longitude);
      await box.write('${_locationCacheKey}_address', address);
      await box.write('${_locationCacheKey}_locality', address);
      await box.write(_locationTimestampKey, position.timestamp.millisecondsSinceEpoch);
      
      print('[GPS_LOCATION] Location cached with address: ${position.latitude}, ${position.longitude} - $address');
    } catch (e) {
      print('[GPS_LOCATION] Error caching location: $e');
    }
  }

  /// **Clear Cached Location**
  /// 
  /// Removes cached GPS location from local storage
  static Future<void> _clearCachedLocation() async {
    try {
      final box = GetStorage();
      await box.remove('${_locationCacheKey}_lat');
      await box.remove('${_locationCacheKey}_lng');
      await box.remove('${_locationCacheKey}_address');
      await box.remove('${_locationCacheKey}_locality');
      await box.remove(_locationTimestampKey);
      
      print('[GPS_LOCATION] Cached location cleared');
    } catch (e) {
      print('[GPS_LOCATION] Error clearing cached location: $e');
    }
  }

  /// **Get Location for Zone Detection**
  /// 
  /// This is the main method to be called for zone detection
  /// Returns coordinates in the format expected by zone detection
  /// **Get Full Address from GPS Coordinates**
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      print('[GPS_LOCATION] Getting address for coordinates: $latitude, $longitude');
      
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Debug: Print all available address components
        print('[GPS_LOCATION] Address components:');
        print('  subThoroughfare: ${place.subThoroughfare}');
        print('  thoroughfare: ${place.thoroughfare}');
        print('  subLocality: ${place.subLocality}');
        print('  locality: ${place.locality}');
        print('  administrativeArea: ${place.administrativeArea}');
        print('  subAdministrativeArea: ${place.subAdministrativeArea}');
        print('  postalCode: ${place.postalCode}');
        print('  country: ${place.country}');
        print('  name: ${place.name}');
        print('  street: ${place.street}');
        
        // Build address string similar to the format you showed
        String address = '';
        
        // Extract door number from various possible fields
        String doorNumber = '';
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
          doorNumber = place.subThoroughfare!;
        } else if (place.name != null && place.name!.isNotEmpty) {
          // Sometimes door number is in the 'name' field
          doorNumber = place.name!;
        } else if (place.street != null && place.street!.isNotEmpty) {
          // Sometimes door number is in the 'street' field
          doorNumber = place.street!;
        }
        
        // Add door number if found
        if (doorNumber.isNotEmpty) {
          address += doorNumber;
          print('[GPS_LOCATION] Door number extracted: $doorNumber');
        }
        
        // Extract street name from various possible fields
        String streetName = '';
        if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          streetName = place.thoroughfare!;
        } else if (place.name != null && place.name!.isNotEmpty && doorNumber != place.name) {
          // If name field contains street info (not just door number)
          streetName = place.name!;
        } else if (place.street != null && place.street!.isNotEmpty && doorNumber != place.street) {
          // If street field contains street info (not just door number)
          streetName = place.street!;
        }
        
        // Add street name if found and different from door number
        if (streetName.isNotEmpty && streetName != doorNumber) {
          if (address.isNotEmpty) address += ', ';
          address += streetName;
          print('[GPS_LOCATION] Street name extracted: $streetName');
        } else {
          print('[GPS_LOCATION] No street name found (door number: $doorNumber)');
        }
        
        // Add sub-locality (area/neighborhood)
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }
        
        // Add locality/area
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }
        
        // Add sub-administrative area (district)
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subAdministrativeArea!;
        }
        
        // Add city/administrative area
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.administrativeArea!;
        }
        
        // Add postal code
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.postalCode!;
        }
        
        // Add country
        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }
        
        // If we still don't have a detailed address, try using the 'name' field
        if (address.isEmpty || address.split(',').length < 3) {
          if (place.name != null && place.name!.isNotEmpty) {
            address = place.name!;
            // Add additional components if available
            if (place.locality != null && place.locality!.isNotEmpty && !address.contains(place.locality!)) {
              address += ', ${place.locality!}';
            }
            if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty && !address.contains(place.administrativeArea!)) {
              address += ', ${place.administrativeArea!}';
            }
            if (place.country != null && place.country!.isNotEmpty && !address.contains(place.country!)) {
              address += ', ${place.country!}';
            }
          }
        }
        
        print('[GPS_LOCATION] Address obtained: $address');
        return address;
      }
    } catch (e) {
      print('[GPS_LOCATION] Error getting address: $e');
    }
    
    // Fallback to coordinates if address lookup fails
    return 'GPS Location ($latitude, $longitude)';
  }

  static Future<Map<String, double>?> getLocationForZoneDetection() async {
    try {
      print('[GPS_LOCATION] Getting location for zone detection...');
      
      final position = await getCurrentLocation();
      if (position != null) {
        final location = {
          'latitude': position.latitude,
          'longitude': position.longitude,
        };
        
        print('[GPS_LOCATION] Location for zone detection: ${location['latitude']}, ${location['longitude']}');
        return location;
      } else {
        print('[GPS_LOCATION] No location available for zone detection');
        return null;
      }
    } catch (e) {
      print('[GPS_LOCATION] Error getting location for zone detection: $e');
      return null;
    }
  }

  /// **Force Refresh Location**
  /// 
  /// Forces a fresh GPS location request, ignoring cache
  static Future<Position?> forceRefreshLocation() async {
    try {
      print('[GPS_LOCATION] Force refreshing GPS location...');
      
      // Clear cached location
      await _clearCachedLocation();
      
      // Get fresh location
      return await getCurrentLocation();
    } catch (e) {
      print('[GPS_LOCATION] Error force refreshing location: $e');
      return null;
    }
  }

  /// **Check if Location is Available**
  /// 
  /// Checks if GPS location is available (permissions + services)
  static Future<bool> isLocationAvailable() async {
    try {
      final hasPermission = await _checkLocationPermissions();
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      
      return hasPermission && isLocationEnabled;
    } catch (e) {
      print('[GPS_LOCATION] Error checking location availability: $e');
      return false;
    }
  }

  /// **Get Cached Address Information**
  /// 
  /// Retrieves cached address information for coordinates
  static Future<Map<String, String>?> getCachedAddressInfo() async {
    try {
      final box = GetStorage();
      final cachedLat = box.read('${_locationCacheKey}_lat');
      final cachedLng = box.read('${_locationCacheKey}_lng');
      final cachedAddress = box.read('${_locationCacheKey}_address');
      final cachedLocality = box.read('${_locationCacheKey}_locality');
      final cachedTimestamp = box.read(_locationTimestampKey);

      if (cachedLat != null && cachedLng != null && cachedTimestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(cachedTimestamp);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(cacheTime) < _cacheExpiry) {
          return {
            'latitude': cachedLat.toString(),
            'longitude': cachedLng.toString(),
            'address': cachedAddress ?? '',
            'locality': cachedLocality ?? '',
          };
        }
      }
      
      return null;
    } catch (e) {
      print('[GPS_LOCATION] Error getting cached address info: $e');
      return null;
    }
  }
}
