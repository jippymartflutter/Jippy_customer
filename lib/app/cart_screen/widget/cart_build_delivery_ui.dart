import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart' show Constant;
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum CartTheme {
  food, // Default food app theme
  mart, // Green mart theme
  mixed // Mixed cart theme
}

// Cart theme colors class
class CartThemeColors {
  final Color primary;
  final Color primaryDark;
  final Color accent;
  final Color surface;
  final Color onSurface;

  const CartThemeColors({
    required this.primary,
    required this.primaryDark,
    required this.accent,
    required this.surface,
    required this.onSurface,
  });
}

Widget buildDeliveryFeeUI({
  required bool isFreeDelivery,
  required double originalFee,
  required double currentFee,
  required DarkThemeProvider themeChange,
}) {
  print('[DELIVERY_UI] 🎨 Building delivery fee UI:');
  print('[DELIVERY_UI]   - isFreeDelivery: $isFreeDelivery');
  print('[DELIVERY_UI]   - originalFee: ₹$originalFee');
  print('[DELIVERY_UI]   - currentFee: ₹$currentFee');

  // Check if this is the special case: free delivery eligible but with extra charge
  // This happens when subtotal >= threshold but distance > free km
  bool isFreeDeliveryWithExtraCharge =
      isFreeDelivery && currentFee > 0.0 && originalFee > 0.0;

  if (isFreeDelivery) {
    if (isFreeDeliveryWithExtraCharge) {
      // Special case: Free delivery eligible but with extra charge due to distance
      // Show: Green "Free Delivery" + strikethrough original fee + extra charge
      print('[DELIVERY_UI] 🎯 Special case: Free delivery with extra charge');
      return Row(
        children: [
          Text(
            'Free Delivery',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: AppThemeData.success400,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Constant.amountShow(amount: originalFee.toString()),
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: AppThemeData.danger300,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppThemeData.danger300,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Constant.amountShow(amount: currentFee.toString()),
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      // Standard free delivery: Green text + Strikethrough original fee + ₹0.00
      print('[DELIVERY_UI] 🎯 Standard free delivery');
      return Row(
        children: [
          Text(
            'Free Delivery',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: AppThemeData.success400,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Constant.amountShow(amount: originalFee.toString()),
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: AppThemeData.danger300,
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              decorationColor: AppThemeData.danger300,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Constant.amountShow(amount: '0.00'),
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: themeChange.getThem()
                  ? AppThemeData.grey50
                  : AppThemeData.grey900,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  } else {
    // Paid delivery UI: Regular text + delivery charge
    print('[DELIVERY_UI] 🎯 Paid delivery');
    return Row(
      children: [
        Text(
          'Delivery Charge',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.regular,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          Constant.amountShow(amount: currentFee.toString()),
          style: TextStyle(
            fontFamily: AppThemeData.regular,
            color: themeChange.getThem()
                ? AppThemeData.grey50
                : AppThemeData.grey900,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

tipsDialog(CartController controller, themeChange) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    insetPadding: const EdgeInsets.all(10),
    clipBehavior: Clip.antiAliasWithSaveLayer,
    backgroundColor:
        themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
    child: Padding(
      padding: const EdgeInsets.all(30),
      child: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldWidget(
              title: 'Tips Amount'.tr,
              controller: controller.tipsController.value,
              textInputType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
              ],
              prefix: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Text(
                  "${Constant.currencyModel!.symbol}".tr,
                  style: TextStyle(
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontFamily: AppThemeData.semiBold,
                      fontSize: 12),
                ),
              ),
              hintText: 'Enter Tips Amount'.tr,
            ),
            Row(
              children: [
                Expanded(
                  child: RoundedButtonFill(
                    title: "Cancel".tr,
                    color: themeChange.getThem()
                        ? AppThemeData.grey700
                        : AppThemeData.grey200,
                    textColor: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                    onPress: () async {
                      Get.back();
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: RoundedButtonFill(
                    title: "Add".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      if (controller.tipsController.value.text.isEmpty) {
                        ShowToastDialog.showToast(
                            "Please enter tips Amount".tr);
                      } else {
                        controller.deliveryTips.value =
                            double.parse(controller.tipsController.value.text);
                        controller.calculatePrice();
                        Get.back();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

cardDecoration(CartController controller, PaymentGateway value, themeChange,
    String image) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(value.name == "payFast" ? 0 : 8.0),
        child: image == ''
            ? Container(
                color: themeChange.getThem()
                    ? AppThemeData.grey800
                    : AppThemeData.grey100)
            : Image.asset(
                image,
              ),
      ),
    ),
  );
}
