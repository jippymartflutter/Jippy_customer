import 'package:get/get.dart';
import 'package:customer/constant/constant.dart';

class MartEditProfileController extends GetxController {
  bool isLoading = false;

  void updateProfile({
    required String firstName,
    required String lastName,
  }) {
    if (firstName.trim().isEmpty && lastName.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter at least first name or last name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading = true;
    update();

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      final userModel = Constant.userModel;
      if (userModel != null) {
        userModel.firstName = firstName.trim();
        userModel.lastName = lastName.trim();
        
        // TODO: Update user in Firestore or API
        
        isLoading = false;
        update();
        
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        
        Get.back();
      } else {
        isLoading = false;
        update();
        
        Get.snackbar(
          'Error',
          'User not found',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    });
  }
}
