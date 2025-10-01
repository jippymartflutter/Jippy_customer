import 'dart:async';

import 'package:customer/models/order_model.dart';
import 'package:customer/services/database_helper.dart';
import 'package:get/get.dart';

class OrderPlacingController extends GetxController {
  RxBool isLoading = true.obs;
  RxBool isPlacing = false.obs;
  RxInt counter = 0.obs;
  Timer? timer;

  @override
  void onInit() {
    print('DEBUG: OrderPlacingController initialized');
    getArgument();
    startTimer();
    super.onInit();
  }

  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  Rx<OrderModel> orderModel = OrderModel().obs;

  getArgument() async {
    print('DEBUG: Getting order arguments');
    try {
      // Clear cart immediately to free up memory
      await DatabaseHelper.instance.deleteAllCartProducts();
      
      dynamic argumentData = Get.arguments;
      if (argumentData != null) {
        orderModel.value = argumentData['orderModel'];
        print('DEBUG: Order received: ${orderModel.value.id}');
      }
      
      isLoading.value = false;
      update();
    } catch (e) {
      print('DEBUG: Error getting arguments: $e');
      isLoading.value = false;
      update();
    }
  }

  void startTimer() {
    print('DEBUG: Starting order placement timer');
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter.value == 2) { // Reduced from 3 to 2 seconds
        timer.cancel();
        isPlacing.value = true;
        print('DEBUG: Order placement completed');
      }
      counter++;
    });
  }
}
