import 'dart:async';

import 'package:customer/app/auth_screen/login_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/app/location_permission_screen/location_permission_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/utils/app_lifecycle_logger.dart';
import 'package:customer/utils/auth_helper.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/notification_service.dart';
import 'package:customer/utils/preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final Dio dio = Dio();
  final storage = FlutterSecureStorage();
  @override
  void onInit() {
    Timer(const Duration(seconds: 3), () => redirectScreen());
    super.onInit();
  }

  Future<void> redirectScreen() async {
    print('[SPLASH] redirectScreen called');
    print('[SPLASH] === SplashController redirectScreen START ===');

    // 1. Check if location is saved locally (GetStorage)
    final box = GetStorage();
    final savedLocation = box.read('user_location');
    if (savedLocation != null &&
        savedLocation['latitude'] != null &&
        savedLocation['longitude'] != null) {
      print('[SPLASH] Reading location from LOCAL STORAGE (GetStorage): '
          'lat=${savedLocation['latitude']}, lng=${savedLocation['longitude']}');
      Constant.selectedLocation = ShippingAddress(
        addressAs: 'Home',
        location: UserLocation(
          latitude: savedLocation['latitude'],
          longitude: savedLocation['longitude'],
        ),
        locality: '',
      );
      print(
          '[SPLASH] Reading location from LOCAL STORAGE (GetStorage): lat=${savedLocation['latitude']}, lng=${savedLocation['longitude']}');
      // DashBoardController already registered in main.dart
      Get.offAll(const DashBoardScreen());
      return;
    }

    // 2. If not found, continue with your existing Firestore logic
    print('[SPLASH] No local location found, checking onboarding status...');
    // Skip onboarding for existing users to reduce APK size
    if (Preferences.getBoolean(Preferences.isFinishOnBoardingKey) == false) {
      print(
          '[SPLASH] Onboarding not finished, but skipping for APK size optimization');
      // Mark onboarding as finished to skip it
      Preferences.setBoolean(Preferences.isFinishOnBoardingKey, true);
    }

    // Use enhanced AuthHelper to get current user with device-specific handling
    User? firebaseUser = await AuthHelper.getCurrentUser();
    print(
        '[SPLASH] AuthHelper.getCurrentUser result: ${firebaseUser?.uid ?? "null"}');

    // Get auth diagnostics for debugging device-specific issues
    final diagnostics = await AuthHelper.getAuthDiagnostics();
    print('[SPLASH] Auth diagnostics: $diagnostics');

    if (firebaseUser == null) {
      print('[SPLASH] No valid user session found, navigating to LoginScreen');
      await AuthHelper.clearAuthData();
      Get.offAll(const LoginScreen());
      return;
    }

    if (firebaseUser != null) {
      print('[SPLASH] User is signed in. Fetching Firestore profile...');
      print('[SPLASH] Firebase UID: ${firebaseUser.uid}');
      print('[SPLASH] Firebase Phone: ${firebaseUser.phoneNumber}');

      final userDoc = await FireStoreUtils.getUserProfile(firebaseUser.uid);
      print(
          '[SPLASH] getUserProfile result: ${userDoc != null ? "SUCCESS" : "NULL"}');

      if (userDoc != null) {
        UserModel userModel = userDoc;
        // Set the global user model so it's available throughout the app
        Constant.userModel = userModel;
        print('[DEBUG] User profile after OTP: \n${userModel.toJson()}');
        print(
            '[DEBUG] User role: "${userModel.role}", Expected: "${Constant.userRoleCustomer}"');
        print('[DEBUG] User active status: ${userModel.active}');
        print(
            '[DEBUG] Constant.userModel set: ${Constant.userModel?.toJson()}');

        // Log auth state change with complete profile data
        await AppLifecycleLogger().logUserProfileLoaded();

        if (userModel.role == Constant.userRoleCustomer) {
          if (userModel.active == true) {
            // Set the backendUserId to ensure orders can be fetched
            FireStoreUtils.backendUserId = userModel.id;
            print('[SPLASH] Set backendUserId to: ${userModel.id}');

            userModel.fcmToken = await NotificationService.getToken();
            await FireStoreUtils.updateUser(userModel);
            if (userModel.shippingAddress != null &&
                userModel.shippingAddress!.isNotEmpty) {
              if (userModel.shippingAddress!
                  .where((element) => element.isDefault == true)
                  .isNotEmpty) {
                Constant.selectedLocation = userModel.shippingAddress!
                    .where((element) => element.isDefault == true)
                    .single;
              } else {
                Constant.selectedLocation = userModel.shippingAddress!.first;
              }
              final box = GetStorage();
              final localLocation = box.read('user_location');
              print(
                  '[DEBUG] About to check/migrate Firestore address to local storage');
              if (localLocation == null &&
                  Constant.selectedLocation.location != null) {
                box.write('user_location', {
                  'latitude': Constant.selectedLocation.location!.latitude,
                  'longitude': Constant.selectedLocation.location!.longitude,
                });
                print(
                    '[LOCATION] Migrated location from FIRESTORE to LOCAL STORAGE (GetStorage): '
                    'lat=${Constant.selectedLocation.location!.latitude}, '
                    'lng=${Constant.selectedLocation.location!.longitude}');
              }
              print('[DEBUG] Finished migration check');
              print(
                  '[SPLASH] Reading location from FIRESTORE: lat=${Constant.selectedLocation.location?.latitude}, lng=${Constant.selectedLocation.location?.longitude}');
              // DashBoardController already registered in main.dart
              Get.offAll(const DashBoardScreen());
            } else {
              print(
                  '[SPLASH] No shipping address in Firestore, navigating to LocationPermissionScreen');
              Get.offAll(const LocationPermissionScreen());
            }
            return;
          } else {
            print(
                '[SPLASH] User is inactive, signing out and navigating to LoginScreen');
            await FirebaseAuth.instance.signOut();
            FireStoreUtils.backendUserId = null;
            await Preferences.setBoolean('isOtpVerified', false);
            Get.offAll(const LoginScreen());
            return;
          }
        } else {
          print(
              '[SPLASH] User role is not customer, navigating to LoginScreen');
          await FirebaseAuth.instance.signOut();
          FireStoreUtils.backendUserId = null;
          await Preferences.setBoolean('isOtpVerified', false);
          Get.offAll(const LoginScreen());
          return;
        }
      } else {
        //        print('[SPLASH] No Firestore profile found, navigating to SignupScreen');
        //     Get.offAllNamed('/SignupScreen', arguments: {
        //       "userModel": UserModel(id: firebaseUser.uid, phoneNumber: firebaseUser.phoneNumber),
        //       "type": "mobileNumber"
        //     });
        //     return;
        //   }
        // }

        // print('[SPLASH] No valid session, signing out and navigating to LoginScreen');
        // await FirebaseAuth.instance.signOut();
        // FireStoreUtils.backendUserId = null;
        // await Preferences.setBoolean('isOtpVerified', false);
        // Get.offAll(const LoginScreen());

        print('[SPLASH] No user profile found in Firestore');

        // Check if we have a valid API token but no Firestore profile
        final apiToken = await secureStorage.read(key: 'api_token');
        if (apiToken != null && apiToken.isNotEmpty) {
          print(
              '[SPLASH] Found API token but no Firestore profile, attempting to restore session...');
          try {
            // Try to get user profile from backend
            final response = await Dio().post(
              'https://jippymart.in/api/user/profile',
              options: Options(
                headers: {'Authorization': 'Bearer $apiToken'},
                sendTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

            if (response.statusCode == 200 && response.data['user'] != null) {
              print('[SPLASH] Successfully restored user session from backend');
              // Create a basic user model and continue
              final userData = response.data['user'];
              final userId = firebaseUser?.uid ?? userData['id'];
              Constant.userModel = UserModel(
                id: userId,
                phoneNumber:
                    userData['phoneNumber'] ?? firebaseUser?.phoneNumber,
                active: true,
                role: 'customer',
              );

              // Set the backendUserId to ensure orders can be fetched
              FireStoreUtils.backendUserId = userId;
              print(
                  '[SPLASH] Set backendUserId to: $userId (from backend session)');
              // DashBoardController already registered in main.dart
              Get.offAll(const DashBoardScreen());
              return;
            }
          } catch (e) {
            print('[SPLASH] Error restoring session from backend: $e');
          }
        }

        print('[SPLASH] No valid session found, navigating to LoginScreen');
        await FirebaseAuth.instance.signOut();
        FireStoreUtils.backendUserId = null;
        await Preferences.setBoolean('isOtpVerified', false);
        Get.offAll(const LoginScreen());
        return;
      }
    }
  }

  Future<void> restoreSession() async {
    String? apiToken = await storage.read(key: 'api_token');
    if (apiToken != null) {
      dio.options.headers['Authorization'] = 'Bearer $apiToken';
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        final response = await dio
            .post('https://your-backend.com/api/refresh-firebase-token');
        if (response.data['success'] == true) {
          await FirebaseAuth.instance
              .signInWithCustomToken(response.data['firebase_custom_token']);
        }
      }
    }
  }
}
