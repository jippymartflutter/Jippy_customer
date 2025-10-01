import 'package:customer/constant/show_toast_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:customer/utils/preferences.dart'; // Removed unused import
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/services/database_helper.dart';

class OtpController extends GetxController {
  Rx<TextEditingController> otpController = TextEditingController().obs;
  RxString verificationId = ''.obs;
  RxBool isLoading = false.obs;
  RxString countryCode = ''.obs;
  RxString phoneNumber = ''.obs;

  final Dio dio = Dio();
  final storage = FlutterSecureStorage();

  void setVerificationId(String id) {
    verificationId.value = id;
  }

  Future<void> verifyOtp(String enteredOtp, String phone) async {
    if (enteredOtp.length != 6) {
      ShowToastDialog.showToast("Enter a valid 6-digit OTP");
      return;
    }
    isLoading.value = true;
    ShowToastDialog.showLoader("Verifying OTP...");
    try {
      final response = await dio.post(
        'https://jippymart.in/api/verify-otp',
        data: {
          "phone": phone.replaceAll('+', ''),
          "otp": enteredOtp,
        },
        options: Options(headers: {"Accept": "application/json"}),
      );
      if (response.data['success'] == true) {
        // Store API token securely
        await storage.write(key: 'api_token', value: response.data['token']);
        developer.log('[OTP] api_token written to secure storage: ${response.data['token']}');
        // Set token for future API calls
        dio.options.headers['Authorization'] = 'Bearer ${response.data['token']}';
        // Sign in to Firebase
        await FirebaseAuth.instance.signInWithCustomToken(response.data['firebase_custom_token']);
        developer.log('[OTP] Firebase sign-in with custom token successful');
        // Ensure Firestore user document exists with UID as document ID
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          final usersCollection = FirebaseFirestore.instance.collection('users');
          // Find any document with this user's phone/email but wrong doc ID
          final query = await usersCollection.where('phoneNumber', isEqualTo: phone).get();
          for (var doc in query.docs) {
            if (doc.id != firebaseUser.uid) {
              // Migrate data to correct UID doc and delete old
              await usersCollection.doc(firebaseUser.uid).set(doc.data(), SetOptions(merge: true));
              await usersCollection.doc(doc.id).delete();
              developer.log('[OTP] Migrated user doc from ${doc.id} to ${firebaseUser.uid}');
            }
          }
          // Always ensure UID doc exists/updated
          final userDoc = usersCollection.doc(firebaseUser.uid);
          final userData = {
            'id': firebaseUser.uid,
            'phoneNumber': phone,
            'active': true,
            'appIdentifier': 'android',
            'createdAt': FieldValue.serverTimestamp(),
            'role': 'customer',
            // Add other fields as needed
          };
          await userDoc.set(userData, SetOptions(merge: true));
          developer.log('[OTP] Firestore user document ensured for UID: ${firebaseUser.uid}');
        }
        // Clear any existing cart data for new user session
        try {
          await DatabaseHelper.instance.deleteAllCartProducts();
          developer.log('[OTP] Cart cleared for new user session');
        } catch (e) {
          developer.log('[OTP] Error clearing cart: $e');
        }
        // Navigate to dashboard
        Get.offAllNamed('/DashBoardScreen');
      } else {
        ShowToastDialog.showToast(response.data['message'] ?? "Invalid OTP. Try again.");
      }
    } catch (e) {
      developer.log('[OTP] Error verifying OTP: $e');
      ShowToastDialog.showToast("Invalid OTP. Try again.");
    } finally {
      isLoading.value = false;
      ShowToastDialog.closeLoader();
    }
  }

  @override
  void onClose() {
    otpController.value.dispose();
    super.onClose();
  }
}
