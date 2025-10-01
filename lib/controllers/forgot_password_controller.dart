import 'package:customer/constant/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // Controller for email input field
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;

  forgotPassword() async {
    // Original code
    // if (emailEditingController.text.isEmpty) {
    //   ShowToastDialog.showToast("Please enter email".tr);
    //   return;
    // }

    // if (!GetUtils.isEmail(emailEditingController.text.trim())) {
    //   ShowToastDialog.showToast("Please enter valid email".tr);
    //   return;
    // }

    // ShowToastDialog.showLoader("Please wait".tr);
    // try {
    //   await FirebaseAuth.instance
    //       .sendPasswordResetEmail(email: emailEditingController.text.trim())
    //       .then((value) {
    //     ShowToastDialog.closeLoader();
    //     ShowToastDialog.showToast("Password reset email sent".tr);
    //     Get.back();
    //   }).catchError((error) {
    //     ShowToastDialog.closeLoader();
    //     if (error.code == 'user-not-found') {
    //       ShowToastDialog.showToast("No user found with this email".tr);
    //     } else if (error.code == 'invalid-email') {
    //       ShowToastDialog.showToast("Invalid email format".tr);
    //     } else if (error.code == 'too-many-requests') {
    //       ShowToastDialog.showToast("Too many attempts. Please try again later".tr);
    //     } else {
    //       ShowToastDialog.showToast(error.message ?? "Something went wrong".tr);
    //     }
    //   });
    // } catch (e) {
    //   ShowToastDialog.closeLoader();
    //   ShowToastDialog.showToast("Something went wrong".tr);
    // }

    // New code with additional validation and error handling
    if (emailEditingController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter email".tr);
      return;
    }

    // Validate email format
    if (!GetUtils.isEmail(emailEditingController.value.text.trim())) {
      ShowToastDialog.showToast("Please enter a valid email address".tr);
      return;
    }

    ShowToastDialog.showLoader("Please wait".tr);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailEditingController.value.text.trim(),
      );
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Reset Password link sent to'.tr} ${emailEditingController.value.text}');
      Get.back();
    } on FirebaseAuthException catch (e) {
      ShowToastDialog.closeLoader();
      switch (e.code) {
        case 'user-not-found':
          ShowToastDialog.showToast('No user found for that email.'.tr);
          break;
        case 'invalid-email':
          ShowToastDialog.showToast('The email address is invalid.'.tr);
          break;
        case 'too-many-requests':
          ShowToastDialog.showToast('Too many attempts. Please try again later.'.tr);
          break;
        default:
          ShowToastDialog.showToast(e.message ?? 'An error occurred. Please try again.'.tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('An unexpected error occurred. Please try again.'.tr);
    }
  }
}
