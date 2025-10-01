import 'package:customer/app/auth_screen/otp_screen.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Removed unused import
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PhoneNumberController extends GetxController {
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController().obs;
  RxBool isLoading = false.obs;
  RxString verificationId = ''.obs;

  PhoneNumberController() {
    countryCodeEditingController.value.text = '+91';
  }

  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  sendCode() async {
    final rawNumber = phoneNUmberEditingController.value.text.trim();
    final countryCode = countryCodeEditingController.value.text.trim();
    // Only allow 10-digit numbers for India
    if (countryCode != '+91' || rawNumber.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(rawNumber)) {
      ShowToastDialog.showToast('Please enter a valid 10-digit Indian mobile number.');
      return;
    }
    final fullNumber = countryCode + rawNumber;
    try {
      ShowToastDialog.showLoader("Please wait".tr);
      final response = await dio.post(
        'https://your-backend.com/api/send-otp',
        data: {"phone": fullNumber.replaceAll('+', '')},
        options: Options(headers: {"Accept": "application/json"}),
      );
      ShowToastDialog.closeLoader();
      if (response.data['success'] == true) {
        Get.to(() => const OtpScreen(), arguments: {
          "countryCode": countryCode,
          "phoneNumber": rawNumber,
        });
      } else {
        ShowToastDialog.showToast(response.data['message'] ?? "Failed to send OTP");
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("An error occurred. Please try again.".tr);
    }
  }

  // --- Deprecated: Firebase Phone Auth (replaced by custom backend OTP API) ---
  // The following code is commented out as we now use our own backend for OTP verification.
  //
  // Future<void> signInWithPhoneAuthCredential(PhoneAuthCredential credential) async {
  //   try {
  //     final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  //     if (userCredential.user != null) {
  //       // Handle successful sign in
  //       print('Auto sign-in: Navigating to OtpScreen with verificationId: ' + (this.verificationId.value ?? 'null'));
  //       Get.offAll(() => const OtpScreen(), arguments: {
  //         "countryCode": countryCodeEditingController.value.text.trim(),
  //         "phoneNumber": phoneNUmberEditingController.value.text.trim(),
  //         "verificationId": this.verificationId.value ?? '',
  //       });
  //     }
  //   } catch (e) {
  //     ShowToastDialog.showToast("Failed to sign in with phone number".tr);
  //     debugPrint("Error in signInWithPhoneAuthCredential: $e");
  //   }
  // }
}
