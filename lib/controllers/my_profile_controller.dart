import 'dart:developer';

import 'package:customer/constant/constant.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MyProfileController extends GetxController {
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getThem();
    loadUserData();
    super.onInit();
  }

  RxString isDarkMode = "Light".obs;
  RxBool isDarkModeSwitch = false.obs;

  getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    if (isDarkMode.value == "Dark") {
      isDarkModeSwitch.value = true;
    } else if (isDarkMode.value == "Light") {
      isDarkModeSwitch.value = false;
    } else {
      isDarkModeSwitch.value = false;
    }
  }

  Future<void> loadUserData() async {
    try {
      log('[PROFILE_SCREEN] Starting to load user data');
      // Load user data if not already loaded
      if (Constant.userModel == null) {
        log('[PROFILE_SCREEN] Constant.userModel is null, fetching from Firestore');
        final userModel = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
        log('[PROFILE_SCREEN] getUserProfile result: ${userModel != null ? "SUCCESS" : "NULL"}');
        if (userModel != null) {
          Constant.userModel = userModel;
          log('[PROFILE_SCREEN] Set Constant.userModel: ${userModel.toJson()}');
        } else {
          log('[PROFILE_SCREEN] Failed to load user model');
        }
      } else {
        log('[PROFILE_SCREEN] Constant.userModel already exists: ${Constant.userModel?.toJson()}');
      }
    } catch (e) {
      log('[PROFILE_SCREEN] Error loading user data: $e');
    } finally {
      isLoading.value = false;
      log('[PROFILE_SCREEN] Loading completed, isLoading set to false');
    }
  }

  Future<bool> deleteUserFromServer() async {
    var url = '${Constant.websiteUrl}/api/delete-user';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': FireStoreUtils.getCurrentUid(),
        },
      );
      log("deleteUserFromServer :: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
