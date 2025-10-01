import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/constant/constant.dart';

class MartAddressController extends GetxController {
  final RxList<ShippingAddress> addresses = <ShippingAddress>[].obs;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
  }

  void loadAddresses() {
    final userModel = Constant.userModel;
    if (userModel?.shippingAddress != null) {
      addresses.assignAll(userModel!.shippingAddress!);
    }
  }

  void addAddress() {
    // TODO: Show add address dialog
    Get.snackbar(
      'Add Address',
      'Add address functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void editAddress(int index) {
    // TODO: Show edit address dialog
    Get.snackbar(
      'Edit Address',
      'Edit address functionality coming soon!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteAddress(int index) {
    if (index >= 0 && index < addresses.length) {
      final address = addresses[index];
      Get.dialog(
        AlertDialog(
          title: const Text('Delete Address'),
          content: Text('Are you sure you want to delete "${address.addressAs ?? 'this address'}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _performDeleteAddress(index);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _performDeleteAddress(int index) {
    if (index >= 0 && index < addresses.length) {
      addresses.removeAt(index);
      _updateUserAddresses();
      Get.snackbar(
        'Success',
        'Address deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void setDefaultAddress(int index) {
    if (index >= 0 && index < addresses.length) {
      // Remove default from all addresses
      for (int i = 0; i < addresses.length; i++) {
        addresses[i] = addresses[i].copyWith(isDefault: false);
      }
      
      // Set the selected address as default
      addresses[index] = addresses[index].copyWith(isDefault: true);
      
      _updateUserAddresses();
      update();
      
      Get.snackbar(
        'Success',
        'Default address updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _updateUserAddresses() {
    final userModel = Constant.userModel;
    if (userModel != null) {
      userModel.shippingAddress = addresses.toList();
      // TODO: Update user in Firestore or API
    }
  }
}
