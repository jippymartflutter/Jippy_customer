import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  RxList<OrderModel> allList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> inProgressList = <OrderModel>[].obs;
  RxList<OrderModel> deliveredList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledList = <OrderModel>[].obs;

  RxBool isLoading = true.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getOrder();
    super.onInit();
  }

  void refreshDataAfterUserLoaded() {
    print('[DEBUG] Refreshing favourites after user data loaded');
    getOrder();
  }

  getOrder() async {
    print(' [OrderController] getOrder called ');
    // Debug logging (will be optimized out in release builds)
    if (kDebugMode) {
      log('[OrderController] getOrder called');
      log('[OrderController] Constant.userModel: ${Constant.userModel != null ? "EXISTS" : "NULL"}');
    }
    // Ensure backendUserId is set if user model exists
    if (Constant.userModel != null) {
      // Always use the correct user ID from Constant.userModel
      FireStoreUtils.backendUserId = Constant.userModel!.id;
      if (kDebugMode) {
        log('[OrderController] Set backendUserId to: ${Constant.userModel!.id}');
      }
    }

    if (Constant.userModel != null) {
      if (kDebugMode) {
        log('[OrderController] User model exists, fetching orders...');
      }
      try {
        final orders = await FireStoreUtils.getAllOrder();
        if (kDebugMode) {
          log('[OrderController] Fetched ${orders.length} orders');
        }

        allList.value = orders;
        if (kDebugMode) {
          log('[OrderController] All orders: ${allList.length}');
        }

        newOrderList.value = allList
            .where((p0) =>
                p0.status == Constant.orderPlaced || p0.status == "pending")
            .toList();
        rejectedList.value =
            allList.where((p0) => p0.status == Constant.orderRejected).toList();
        inProgressList.value = allList
            .where((p0) =>
                p0.status == Constant.orderAccepted ||
                p0.status == Constant.driverPending ||
                p0.status == Constant.orderShipped ||
                p0.status == Constant.orderInTransit)
            .toList();
        deliveredList.value = allList
            .where((p0) => p0.status == Constant.orderCompleted)
            .toList();
        cancelledList.value = allList
            .where((p0) => p0.status == Constant.orderCancelled)
            .toList();
      } catch (e) {
        if (kDebugMode) {
          log('[OrderController] Error fetching orders: $e');
        }
      }
    } else {
      if (kDebugMode) {
        log('[OrderController] ERROR: Constant.userModel is null');
      }
    }

    isLoading.value = false;
    if (kDebugMode) {
      log('[OrderController] getOrder completed');
    }
  }

  final CartProvider cartProvider = CartProvider();

  addToCart({required CartProductModel cartProductModel}) {
    print("addToCart");
    cartProvider.addToCart(
        Get.context!, cartProductModel, cartProductModel.quantity!);
    update();
  }

  // Method to manually refresh orders (for debugging)
  Future<void> refreshOrders() async {
    log('[OrderController] Manual refresh requested');
    isLoading.value = true;
    await getOrder();
  }

  // Method to force set the correct user ID (for debugging)
  void forceSetUserId() {
    if (Constant.userModel != null) {
      FireStoreUtils.backendUserId = Constant.userModel!.id;
      log('[OrderController] Force set backendUserId to: ${Constant.userModel!.id}');
    }
  }
}
