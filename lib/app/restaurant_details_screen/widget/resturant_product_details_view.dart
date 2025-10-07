import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constant/constant.dart';
import '../../../constant/show_toast_dialog.dart';
import '../../../themes/responsive.dart';
import '../../../utils/fire_store_utils.dart';
import '../../../utils/network_image_widget.dart';

class ProductDetailsView extends StatelessWidget {
  final ProductModel productModel;

  const ProductDetailsView({super.key, required this.productModel});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantDetailsController(),
        builder: (controller) {
          bool isItemAvailable = productModel.isAvailable ?? true;

          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : AppThemeData.surface,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: themeChange.getThem()
                        ? AppThemeData.grey900
                        : AppThemeData.grey50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
                            child: ColorFiltered(
                              colorFilter: isItemAvailable
                                  ? const ColorFilter.mode(
                                      Colors.transparent, BlendMode.multiply)
                                  : const ColorFilter.mode(
                                      Colors.grey, BlendMode.saturation),
                              child: NetworkImageWidget(
                                imageUrl: productModel.photo.toString(),
                                height: Responsive.height(11, context),
                                width: Responsive.width(22, context),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        productModel.name.toString(),
                                        textAlign: TextAlign.start,
                                        maxLines: 2,
                                        style: TextStyle(
                                          fontSize: 16,
                                          overflow: TextOverflow.ellipsis,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () async {
                                        if (controller.favouriteItemList
                                            .where((p0) =>
                                                p0.productId == productModel.id)
                                            .isNotEmpty) {
                                          FavouriteItemModel favouriteModel =
                                              FavouriteItemModel(
                                                  productId: productModel.id,
                                                  storeId: controller
                                                      .vendorModel.value.id,
                                                  userId: FireStoreUtils
                                                      .getCurrentUid());
                                          controller.favouriteItemList
                                              .removeWhere((item) =>
                                                  item.productId ==
                                                  productModel.id);
                                          await FireStoreUtils
                                              .removeFavouriteItem(
                                                  favouriteModel);
                                        } else {
                                          FavouriteItemModel favouriteModel =
                                              FavouriteItemModel(
                                                  productId: productModel.id,
                                                  storeId: controller
                                                      .vendorModel.value.id,
                                                  userId: FireStoreUtils
                                                      .getCurrentUid());
                                          controller.favouriteItemList
                                              .add(favouriteModel);

                                          await FireStoreUtils.setFavouriteItem(
                                              favouriteModel);
                                        }
                                      },
                                      child: Obx(
                                        () => controller.favouriteItemList
                                                .where((p0) =>
                                                    p0.productId ==
                                                    productModel.id)
                                                .isNotEmpty
                                            ? SvgPicture.asset(
                                                "assets/icons/ic_like_fill.svg",
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/ic_like.svg",
                                              ),
                                      ),
                                    )
                                  ],
                                ),
                                if (!isItemAvailable)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      "Not Available",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontFamily: AppThemeData.medium,
                                      ),
                                    ),
                                  ),
                                Text(
                                  productModel.description.toString(),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: AppThemeData.regular,
                                    fontWeight: FontWeight.w400,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  productModel.itemAttribute == null ||
                          productModel.itemAttribute!.attributes!.isEmpty
                      ? const SizedBox()
                      : ListView.builder(
                          itemCount:
                              productModel.itemAttribute!.attributes!.length,
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            String title = "";
                            for (var element in controller.attributesList) {
                              if (productModel.itemAttribute!.attributes![index]
                                      .attributeId ==
                                  element.id) {
                                title = element.title.toString();
                              }
                            }
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              child: Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      productModel
                                              .itemAttribute!
                                              .attributes![index]
                                              .attributeOptions!
                                              .isNotEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    title,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontFamily:
                                                          AppThemeData.semiBold,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey100
                                                          : AppThemeData
                                                              .grey800,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: Text(
                                                    "Required • Select any 1 option"
                                                        .tr,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey400
                                                          : AppThemeData
                                                              .grey500,
                                                    ),
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 10),
                                                  child: Divider(),
                                                ),
                                              ],
                                            )
                                          : Offstage(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Wrap(
                                          spacing: 6.0,
                                          runSpacing: 6.0,
                                          children: List.generate(
                                            productModel
                                                .itemAttribute!
                                                .attributes![index]
                                                .attributeOptions!
                                                .length,
                                            (i) {
                                              return InkWell(
                                                onTap: isItemAvailable
                                                    ? () async {
                                                        if (controller
                                                            .selectedIndexVariants
                                                            .where((element) =>
                                                                element.contains(
                                                                    '$index _'))
                                                            .isEmpty) {
                                                          controller.selectedVariants.insert(
                                                              index,
                                                              productModel
                                                                  .itemAttribute!
                                                                  .attributes![
                                                                      index]
                                                                  .attributeOptions![
                                                                      i]
                                                                  .toString());
                                                          controller
                                                              .selectedIndexVariants
                                                              .add(
                                                                  '$index _${productModel.itemAttribute!.attributes![index].attributeOptions![i].toString()}');
                                                          controller
                                                              .selectedIndexArray
                                                              .add(
                                                                  '${index}_$i');
                                                        } else {
                                                          controller
                                                              .selectedIndexArray
                                                              .remove(
                                                                  '${index}_${productModel.itemAttribute!.attributes![index].attributeOptions?.indexOf(controller.selectedIndexVariants.where((element) => element.contains('$index _')).first.replaceAll('$index _', ''))}');
                                                          controller
                                                              .selectedVariants
                                                              .removeAt(index);
                                                          controller
                                                              .selectedIndexVariants
                                                              .remove(controller
                                                                  .selectedIndexVariants
                                                                  .where((element) =>
                                                                      element.contains(
                                                                          '$index _'))
                                                                  .first);
                                                          controller.selectedVariants.insert(
                                                              index,
                                                              productModel
                                                                  .itemAttribute!
                                                                  .attributes![
                                                                      index]
                                                                  .attributeOptions![
                                                                      i]
                                                                  .toString());
                                                          controller
                                                              .selectedIndexVariants
                                                              .add(
                                                                  '$index _${productModel.itemAttribute!.attributes![index].attributeOptions![i].toString()}');
                                                          controller
                                                              .selectedIndexArray
                                                              .add(
                                                                  '${index}_$i');
                                                        }

                                                        final bool
                                                            productIsInList =
                                                            cartItem.any(
                                                                (product) =>
                                                                    product
                                                                        .id ==
                                                                    "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                        if (productIsInList) {
                                                          CartProductModel
                                                              element =
                                                              cartItem.firstWhere(
                                                                  (product) =>
                                                                      product
                                                                          .id ==
                                                                      "${productModel.id}~${productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).isNotEmpty ? productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId.toString() : ""}");
                                                          controller.quantity
                                                                  .value =
                                                              element.quantity!;
                                                        } else {
                                                          controller.quantity
                                                              .value = 1;
                                                        }

                                                        controller.update();
                                                        controller
                                                            .calculatePrice(
                                                                productModel);
                                                      }
                                                    : null,
                                                child: Chip(
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              color: Colors
                                                                  .transparent),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          20))),
                                                  label: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        productModel
                                                            .itemAttribute!
                                                            .attributes![index]
                                                            .attributeOptions![
                                                                i]
                                                            .toString(),
                                                        style: TextStyle(
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          fontFamily:
                                                              AppThemeData
                                                                  .medium,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: controller
                                                                  .selectedVariants
                                                                  .contains(productModel
                                                                      .itemAttribute!
                                                                      .attributes![
                                                                          index]
                                                                      .attributeOptions![
                                                                          i]
                                                                      .toString())
                                                              ? Colors.white
                                                              : themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey600
                                                                  : AppThemeData
                                                                      .grey300,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  backgroundColor: controller
                                                          .selectedVariants
                                                          .contains(productModel
                                                              .itemAttribute!
                                                              .attributes![
                                                                  index]
                                                              .attributeOptions![
                                                                  i]
                                                              .toString())
                                                      ? AppThemeData.primary300
                                                      : themeChange.getThem()
                                                          ? AppThemeData.grey800
                                                          : AppThemeData
                                                              .grey100,
                                                  elevation: 6.0,
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                ),
                                              );
                                            },
                                          ).toList(),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                  productModel.addOnsTitle == null ||
                          productModel.addOnsTitle!.isEmpty
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 5),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      "Addons".tr,
                                      style: TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey100
                                            : AppThemeData.grey800,
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(),
                                  ),
                                  ListView.builder(
                                      itemCount:
                                          productModel.addOnsTitle!.length,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        String title =
                                            productModel.addOnsTitle![index];
                                        String price =
                                            productModel.addOnsPrice![index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    fontFamily:
                                                        AppThemeData.medium,
                                                    fontWeight: FontWeight.w500,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey100
                                                        : AppThemeData.grey800,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                Constant.amountShow(
                                                    amount: Constant
                                                        .productCommissionPrice(
                                                            controller
                                                                .vendorModel
                                                                .value,
                                                            price)),
                                                textAlign: TextAlign.start,
                                                maxLines: 1,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  fontWeight: FontWeight.w500,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey100
                                                      : AppThemeData.grey800,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Obx(
                                                () => SizedBox(
                                                  height: 24.0,
                                                  width: 24.0,
                                                  child: Checkbox(
                                                    value: controller
                                                        .selectedAddOns
                                                        .contains(title),
                                                    activeColor:
                                                        AppThemeData.primary300,
                                                    onChanged: isItemAvailable
                                                        ? (value) {
                                                            if (value != null) {
                                                              if (value ==
                                                                  true) {
                                                                controller
                                                                    .selectedAddOns
                                                                    .add(title);
                                                              } else {
                                                                controller
                                                                    .selectedAddOns
                                                                    .remove(
                                                                        title);
                                                              }
                                                              controller
                                                                  .update();
                                                            }
                                                          }
                                                        : null,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      }),
                                ],
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
            bottomNavigationBar: Container(
              color: themeChange.getThem()
                  ? AppThemeData.grey800
                  : AppThemeData.grey100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: Responsive.width(100, context),
                        height: Responsive.height(5.5, context),
                        decoration: ShapeDecoration(
                          color: themeChange.getThem()
                              ? AppThemeData.grey700
                              : AppThemeData.grey200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(200),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: isItemAvailable
                                  ? () {
                                      if (controller.quantity.value > 1) {
                                        controller.quantity.value -= 1;
                                        controller.update();
                                      }
                                    }
                                  : null,
                              child: Icon(
                                Icons.remove,
                                color: isItemAvailable
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                controller.quantity.value.toString(),
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: AppThemeData.medium,
                                  fontWeight: FontWeight.w500,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey100
                                      : AppThemeData.grey800,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: isItemAvailable
                                  ? () {
                                      // Check for promotional item limit before incrementing (ULTRA-FAST - ZERO ASYNC)
                                      final promo = controller
                                          .getActivePromotionForProduct(
                                        productId: productModel.id ?? '',
                                        restaurantId:
                                            productModel.vendorID ?? '',
                                      );

                                      if (promo != null) {
                                        final isAllowed = controller
                                            .isPromotionalItemQuantityAllowed(
                                                productModel.id ?? '',
                                                productModel.vendorID ?? '',
                                                controller.quantity.value + 1);

                                        if (!isAllowed) {
                                          final limit = controller
                                              .getPromotionalItemLimit(
                                                  productModel.id ?? '',
                                                  productModel.vendorID ?? '');
                                          ShowToastDialog.showToast(
                                              "Maximum $limit items allowed for this promotional offer"
                                                  .tr);
                                          return;
                                        }
                                      }

                                      if (productModel.itemAttribute == null) {
                                        if (controller.quantity.value <=
                                                (productModel.quantity ?? 0) ||
                                            (productModel.quantity ?? 0) ==
                                                -1) {
                                          controller.quantity.value += 1;
                                          controller.update();
                                        } else {
                                          ShowToastDialog.showToast(
                                              "Out of stock".tr);
                                        }
                                      } else {
                                        int totalQuantity = int.parse(
                                            productModel
                                                .itemAttribute!.variants!
                                                .where((element) =>
                                                    element.variantSku ==
                                                    controller.selectedVariants
                                                        .join('-'))
                                                .first
                                                .variantQuantity
                                                .toString());
                                        if (controller.quantity.value <=
                                                totalQuantity ||
                                            totalQuantity == -1) {
                                          controller.quantity.value += 1;
                                          controller.update();
                                        } else {
                                          ShowToastDialog.showToast(
                                              "Out of stock".tr);
                                        }
                                      }
                                    }
                                  : null,
                              child: Icon(
                                Icons.add,
                                color: isItemAvailable
                                    ? Colors.black
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 2,
                      child: isItemAvailable
                          ? FutureBuilder<String>(
                              future: controller.calculatePrice(productModel),
                              builder: (context, snapshot) {
                                final price = snapshot.data ?? "0";
                                return RoundedButtonFill(
                                  title:
                                      "${'Add item'.tr} ${Constant.amountShow(amount: price)}"
                                          .tr,
                                  height: 5.5,
                                  color: AppThemeData.primary300,
                                  textColor: AppThemeData.grey50,
                                  fontSizes: 16,
                                  onPress: () async {
                                    // Check for promotional item limit before adding to cart (ULTRA-FAST - ZERO ASYNC)
                                    final promo =
                                        controller.getActivePromotionForProduct(
                                      productId: productModel.id ?? '',
                                      restaurantId: productModel.vendorID ?? '',
                                    );

                                    if (promo != null) {
                                      final isAllowed = controller
                                          .isPromotionalItemQuantityAllowed(
                                              productModel.id ?? '',
                                              productModel.vendorID ?? '',
                                              controller.quantity.value);

                                      if (!isAllowed) {
                                        final limit =
                                            controller.getPromotionalItemLimit(
                                                productModel.id ?? '',
                                                productModel.vendorID ?? '');
                                        ShowToastDialog.showToast(
                                            "Maximum $limit items allowed for this promotional offer"
                                                .tr);
                                        return;
                                      }
                                    }

                                    if (productModel.itemAttribute == null) {
                                      // Check for promotional price
                                      String finalPrice =
                                          Constant.productCommissionPrice(
                                              controller.vendorModel.value,
                                              productModel.price.toString());
                                      String finalDiscountPrice = double.parse(
                                                  productModel.disPrice
                                                      .toString()) <=
                                              0
                                          ? "0"
                                          : Constant.productCommissionPrice(
                                              controller.vendorModel.value,
                                              productModel.disPrice.toString());

                                      if (promo != null) {
                                        // Use promotional price
                                        finalPrice =
                                            (promo['special_price'] as num)
                                                .toString();
                                        finalDiscountPrice =
                                            Constant.productCommissionPrice(
                                                controller.vendorModel.value,
                                                productModel.price
                                                    .toString()); // original price for strikethrough
                                      }

                                      controller.addToCart(
                                          productModel: productModel,
                                          price: finalPrice,
                                          discountPrice: finalDiscountPrice,
                                          isIncrement: true,
                                          quantity: controller.quantity.value);
                                    } else {
                                      String variantPrice = "0";
                                      if (productModel.itemAttribute!.variants!
                                          .where((element) =>
                                              element.variantSku ==
                                              controller.selectedVariants
                                                  .join('-'))
                                          .isNotEmpty) {
                                        variantPrice =
                                            Constant.productCommissionPrice(
                                                controller.vendorModel.value,
                                                productModel.itemAttribute!
                                                        .variants!
                                                        .where((element) =>
                                                            element
                                                                .variantSku ==
                                                            controller
                                                                .selectedVariants
                                                                .join('-'))
                                                        .first
                                                        .variantPrice ??
                                                    '0');
                                      }
                                      Map<String, String> mapData = {};
                                      for (var element in productModel
                                          .itemAttribute!.attributes!) {
                                        mapData.addEntries([
                                          MapEntry(
                                              controller.attributesList
                                                  .where((element1) =>
                                                      element.attributeId ==
                                                      element1.id)
                                                  .first
                                                  .title
                                                  .toString(),
                                              controller.selectedVariants[
                                                  productModel.itemAttribute!
                                                      .attributes!
                                                      .indexOf(element)])
                                        ]);
                                      }

                                      VariantInfo variantInfo = VariantInfo(
                                          variantPrice: productModel
                                                  .itemAttribute!.variants!
                                                  .where((element) =>
                                                      element.variantSku ==
                                                      controller.selectedVariants
                                                          .join('-'))
                                                  .first
                                                  .variantPrice ??
                                              '0',
                                          variantSku: controller.selectedVariants
                                              .join('-'),
                                          variantOptions: mapData,
                                          variantImage: productModel
                                                  .itemAttribute!.variants!
                                                  .where((element) =>
                                                      element.variantSku == controller.selectedVariants.join('-'))
                                                  .first
                                                  .variantImage ??
                                              '',
                                          variantId: productModel.itemAttribute!.variants!.where((element) => element.variantSku == controller.selectedVariants.join('-')).first.variantId ?? '0');

                                      controller.addToCart(
                                          productModel: productModel,
                                          price: variantPrice,
                                          discountPrice: "0",
                                          isIncrement: true,
                                          variantInfo: variantInfo,
                                          quantity: controller.quantity.value);
                                    }

                                    Get.back();
                                  },
                                );
                              },
                            )
                          : const SizedBox(), // Removed the grey button completely
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
