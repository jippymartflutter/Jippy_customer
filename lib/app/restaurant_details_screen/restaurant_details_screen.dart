import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/restaurant_details_screen/widget/restaurant_detail_shimmer_widget.dart';
import 'package:customer/app/review_list_screen/review_list_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/restaurant_details_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/special_price_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final String? scrollToProductId;

  const RestaurantDetailsScreen({
    super.key,
    this.scrollToProductId,
  });

  void _showMenuModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 50, left: 20, right: 40),
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Column(
                    children: [
                      _buildMenuItem('Items at 169', 42),
                      _buildMenuItem('Items at 179', 7),
                      _buildMenuItem('Items at 189', 23),
                      _buildMenuItem('Recommended', 20),
                      _buildMenuItem('Combos for Jerry', 5, isNew: true),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, int count, {bool isNew = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$count items',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: RestaurantDetailsController(scrollToProductId: scrollToProductId),
        autoRemove: false,
        builder: (controller) {
          return Scaffold(
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : InkWell(
              onTap: () {
                Get.to(const CartScreen());
              },
              child: SafeArea(
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF48000),
                        Color(0xFFff0404)
                        // AppThemeData.danger200,
                        // AppThemeData.danger300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${cartItem.length} items',
                        style: TextStyle(
                          fontFamily: AppThemeData.medium,
                          color: AppThemeData.grey50,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'View Cart',
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          color: AppThemeData.grey50,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: Visibility(
              visible: true,
              child: FloatingActionButton(
                onPressed: () {
                  _showMenuModal(context);
                },
                backgroundColor: Colors.black, // WhatsApp green color
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SvgPicture.asset(
                    'assets/images/menu.svg',
                    width: 44,
                    height: 44,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            body: RefreshIndicator(
              onRefresh: controller.getArgument,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      expandedHeight: Responsive.height(30, context),
                      floating: true,
                      pinned: true,
                      automaticallyImplyLeading: false,
                      backgroundColor: AppThemeData.primary300,
                      title: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey50,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.vendorModel.value.title ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey50,
                                fontFamily: AppThemeData.semiBold,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          children: [
                            controller.vendorModel.value.photos == null ||
                                controller.vendorModel.value.photos!.isEmpty
                                ? Stack(
                              children: [
                                NetworkImageWidget(
                                  imageUrl: controller
                                      .vendorModel.value.photo
                                      .toString(),
                                  fit: BoxFit.cover,
                                  width: Responsive.width(100, context),
                                  height: Responsive.height(40, context),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: const Alignment(0.00, -1.00),
                                      end: const Alignment(0, 1),
                                      colors: [
                                        Colors.black.withOpacity(0),
                                        Colors.black
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : PageView.builder(
                              physics: const BouncingScrollPhysics(),
                              controller: controller.pageController.value,
                              scrollDirection: Axis.horizontal,
                              itemCount: controller
                                  .vendorModel.value.photos!.length,
                              padEnds: false,
                              pageSnapping: true,
                              allowImplicitScrolling: true,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                String image = controller
                                    .vendorModel.value.photos![index];
                                return Stack(
                                  children: [
                                    NetworkImageWidget(
                                      imageUrl: image.toString(),
                                      fit: BoxFit.cover,
                                      width:
                                      Responsive.width(100, context),
                                      height:
                                      Responsive.height(40, context),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: const Alignment(
                                              0.00, -1.00),
                                          end: const Alignment(0, 1),
                                          colors: [
                                            Colors.black.withOpacity(0),
                                            Colors.black
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            Positioned(
                              bottom: 10,
                              right: 0,
                              left: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  controller.vendorModel.value.photos!.length,
                                      (index) {
                                    return Obx(
                                          () =>
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 5),
                                            alignment: Alignment.centerLeft,
                                            height: 9,
                                            width: 9,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: controller.currentPage
                                                  .value ==
                                                  index
                                                  ? AppThemeData.primary300
                                                  : AppThemeData.grey300,
                                            ),
                                          ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                //changed here1
                body: controller.isLoading.value
                // ? Constant.loader(message: "Loading restaurant details...".tr)
                    ? resturantDetailsShimmer()
                    : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    controller: controller.scrollController.value,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          controller
                                              .vendorModel.value.title
                                              .toString(),
                                          textAlign: TextAlign.start,
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 22,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            fontFamily:
                                            AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                          ),
                                        ),
                                        SizedBox(
                                          width: Responsive.width(
                                              78, context),
                                          child: Text(
                                            controller.vendorModel.value
                                                .location
                                                .toString(),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily:
                                              AppThemeData.medium,
                                              fontWeight: FontWeight.w500,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey400
                                                  : AppThemeData.grey400,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.primary600
                                              : AppThemeData.primary50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  120)),
                                        ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_star.svg",
                                                colorFilter:
                                                ColorFilter.mode(
                                                    AppThemeData
                                                        .primary300,
                                                    BlendMode.srcIn),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                Constant.calculateReview(
                                                    reviewCount: controller
                                                        .vendorModel
                                                        .value
                                                        .reviewsCount!
                                                        .toStringAsFixed(
                                                        0),
                                                    reviewSum: controller
                                                        .vendorModel
                                                        .value
                                                        .reviewsSum
                                                        .toString()),
                                                style: TextStyle(
                                                  color: themeChange
                                                      .getThem()
                                                      ? AppThemeData
                                                      .primary300
                                                      : AppThemeData
                                                      .primary300,
                                                  fontFamily: AppThemeData
                                                      .semiBold,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(const ReviewListScreen(),
                                              arguments: {
                                                "vendorModel": controller
                                                    .vendorModel.value
                                              });
                                        },
                                        child: Text(
                                          "${controller.vendorModel.value
                                              .reviewsCount} ${'Ratings'.tr}",
                                          style: TextStyle(
                                            decoration:
                                            TextDecoration.underline,
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey200
                                                : AppThemeData.grey700,
                                            fontFamily:
                                            AppThemeData.regular,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  /*
                                  if (controller.vendorModel.value.reststatus == false) ...[
                                    Container(
                                  */
                                  // Use the new clean workflow for status display
                                  Obx(() {
                                    final statusInfo = controller
                                        .getRestaurantStatusInfo();
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: statusInfo['statusColor'],
                                        borderRadius:
                                        BorderRadius.circular(24),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            statusInfo['statusIcon'],
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            statusInfo['statusText'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight:
                                                FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Icon(
                                      Icons.circle,
                                      size: 5,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey500,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (controller.vendorModel.value
                                          .workingHours!.isEmpty) {
                                        ShowToastDialog.showToast(
                                            "Timing is not added by restaurant"
                                                .tr);
                                      } else {
                                        timeShowBottomSheet(
                                            context, controller);
                                      }
                                    },
                                    child: Text(
                                      "View Timings".tr,
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 14,
                                        decoration:
                                        TextDecoration.underline,
                                        decorationColor:
                                        AppThemeData.secondary300,
                                        overflow: TextOverflow.ellipsis,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                        color: themeChange.getThem()
                                            ? AppThemeData.secondary300
                                            : AppThemeData.secondary300,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              controller.vendorModel.value.dineInActive ==
                                  true ||
                                  (controller.vendorModel.value
                                      .openDineTime !=
                                      null &&
                                      controller.vendorModel.value
                                          .openDineTime!.isNotEmpty)
                                  ? const SizedBox() // Permanently hide Table Booking
                                  : const SizedBox(),
                              controller.couponList.isEmpty
                                  ? const SizedBox()
                                  : Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "Additional Offers".tr,
                                    textAlign: TextAlign.start,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 16,
                                      overflow:
                                      TextOverflow.ellipsis,
                                      fontFamily:
                                      AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  CouponListView(
                                    controller: controller,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Menu".tr,
                                textAlign: TextAlign.start,
                                maxLines: 1,
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
                              const SizedBox(
                                height: 10,
                              ),
                              TextFieldWidget(
                                controller: controller
                                    .searchEditingController.value,
                                hintText:
                                'Search the dish, food, meals and more...'
                                    .tr,
                                onchange: (value) {
                                  controller.searchProduct(value);
                                },
                                prefix: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SvgPicture.asset(
                                      "assets/icons/ic_search.svg"),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Add spacing between search bar and filters
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (!controller.isVag.value) {
                                          controller.isVag.value = true;
                                          controller.isNonVag.value =
                                          false;
                                          controller.filterRecord();
                                        }
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4),
                                        decoration: controller.isVag.value
                                            ? ShapeDecoration(
                                          color:
                                          themeChange.getThem()
                                              ? AppThemeData
                                              .primary600
                                              : AppThemeData
                                              .primary50,
                                          shape:
                                          RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: AppThemeData
                                                    .primary300),
                                            borderRadius:
                                            BorderRadius
                                                .circular(120),
                                          ),
                                        )
                                            : ShapeDecoration(
                                          color: themeChange
                                              .getThem()
                                              ? AppThemeData.grey800
                                              : AppThemeData
                                              .grey100,
                                          shape:
                                          RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: themeChange
                                                    .getThem()
                                                    ? AppThemeData
                                                    .grey700
                                                    : AppThemeData
                                                    .grey200),
                                            borderRadius:
                                            BorderRadius
                                                .circular(120),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_veg.svg",
                                              height: 16,
                                              width: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Veg'.tr,
                                              style: TextStyle(
                                                color: themeChange
                                                    .getThem()
                                                    ? AppThemeData.grey100
                                                    : AppThemeData
                                                    .grey800,
                                                fontFamily:
                                                AppThemeData.semiBold,
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (!controller.isNonVag.value) {
                                          controller.isNonVag.value =
                                          true;
                                          controller.isVag.value = false;
                                          controller.filterRecord();
                                        }
                                      },
                                      child: Container(
                                        padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 4),
                                        decoration: controller
                                            .isNonVag.value
                                            ? ShapeDecoration(
                                          color:
                                          themeChange.getThem()
                                              ? AppThemeData
                                              .primary600
                                              : AppThemeData
                                              .primary50,
                                          shape:
                                          RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: AppThemeData
                                                    .primary300),
                                            borderRadius:
                                            BorderRadius
                                                .circular(120),
                                          ),
                                        )
                                            : ShapeDecoration(
                                          color: themeChange
                                              .getThem()
                                              ? AppThemeData.grey800
                                              : AppThemeData
                                              .grey100,
                                          shape:
                                          RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: themeChange
                                                    .getThem()
                                                    ? AppThemeData
                                                    .grey700
                                                    : AppThemeData
                                                    .grey200),
                                            borderRadius:
                                            BorderRadius
                                                .circular(120),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_nonveg.svg",
                                              height: 16,
                                              width: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Non Veg'.tr,
                                              style: TextStyle(
                                                color: themeChange
                                                    .getThem()
                                                    ? AppThemeData.grey100
                                                    : AppThemeData
                                                    .grey800,
                                                fontFamily:
                                                AppThemeData.semiBold,
                                                fontWeight:
                                                FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        controller.toggleOfferFilter();
                                      },
                                      child:
                                      TweenAnimationBuilder<double>(
                                        duration: Duration(seconds: 2),
                                        tween:
                                        Tween(begin: 0.95, end: 1.05),
                                        builder: (context, value, child) {
                                          return Transform.scale(
                                            scale: controller
                                                .isOfferFilter.value
                                                ? 1.0
                                                : value,
                                            child: AnimatedContainer(
                                              duration: Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 6),
                                              decoration: controller
                                                  .isOfferFilter.value
                                                  ? BoxDecoration(
                                                gradient:
                                                LinearGradient(
                                                  colors: [
                                                    Color(
                                                        0xFFFF6B6B),
                                                    // Coral red
                                                    Color(
                                                        0xFFFF8E53),
                                                    // Orange
                                                    Color(
                                                        0xFFFF6B6B),
                                                    // Coral red
                                                  ],
                                                  begin: Alignment
                                                      .topLeft,
                                                  end: Alignment
                                                      .bottomRight,
                                                  stops: [
                                                    0.0,
                                                    0.5,
                                                    1.0
                                                  ],
                                                ),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    120),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(
                                                        0xFFFF6B6B)
                                                        .withOpacity(
                                                        0.4),
                                                    blurRadius: 12,
                                                    offset: Offset(
                                                        0, 3),
                                                  ),
                                                  BoxShadow(
                                                    color: Color(
                                                        0xFFFF8E53)
                                                        .withOpacity(
                                                        0.2),
                                                    blurRadius: 20,
                                                    offset: Offset(
                                                        0, 5),
                                                  ),
                                                ],
                                                border: Border.all(
                                                  color: Color(
                                                      0xFFFF6B6B),
                                                  width: 1.5,
                                                ),
                                              )
                                                  : BoxDecoration(
                                                gradient:
                                                LinearGradient(
                                                  colors: themeChange
                                                      .getThem()
                                                      ? [
                                                    Color(0xFFFF6B6B)
                                                        .withOpacity(
                                                        0.15), // Subtle coral
                                                    Color(0xFFFF8E53)
                                                        .withOpacity(
                                                        0.1), // Subtle orange
                                                  ]
                                                      : [
                                                    Color(0xFFFF6B6B)
                                                        .withOpacity(
                                                        0.08),
                                                    // Very subtle coral
                                                    Color(0xFFFF8E53)
                                                        .withOpacity(
                                                        0.05),
                                                    // Very subtle orange
                                                  ],
                                                  begin: Alignment
                                                      .topLeft,
                                                  end: Alignment
                                                      .bottomRight,
                                                ),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    120),
                                                border: Border.all(
                                                  color: Color(
                                                      0xFFFF6B6B)
                                                      .withOpacity(
                                                      0.3),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(
                                                        0xFFFF6B6B)
                                                        .withOpacity(
                                                        0.1),
                                                    blurRadius: 6,
                                                    offset: Offset(
                                                        0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize:
                                                MainAxisSize.min,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: [
                                                  Icon(
                                                    Icons.local_offer,
                                                    size: 16,
                                                    color: controller
                                                        .isOfferFilter
                                                        .value
                                                        ? Colors.white
                                                        : Color(
                                                        0xFFFF6B6B),
                                                  ),
                                                  const SizedBox(
                                                      width: 4),
                                                  Text(
                                                    'Offers'.tr,
                                                    style: TextStyle(
                                                      color: controller
                                                          .isOfferFilter
                                                          .value
                                                          ? Colors.white
                                                          : Color(
                                                          0xFFFF6B6B),
                                                      fontFamily:
                                                      AppThemeData
                                                          .semiBold,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      fontSize: 12,
                                                      shadows: controller
                                                          .isOfferFilter
                                                          .value
                                                          ? [
                                                        Shadow(
                                                          color: Colors
                                                              .black
                                                              .withOpacity(
                                                              0.3),
                                                          offset:
                                                          Offset(
                                                              0,
                                                              1),
                                                          blurRadius:
                                                          2,
                                                        ),
                                                      ]
                                                          : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    // Clear Filter Button
                                    Builder(
                                      builder: (context) {
                                        try {
                                          return Obx(() {
                                            // Safety check for controller and reactive variables
                                            if (!Get.isRegistered<
                                                RestaurantDetailsController>()) {
                                              return const SizedBox
                                                  .shrink();
                                            }

                                            // Show clear button only if any filter is active
                                            final hasActiveFilters =
                                                (controller.isVag
                                                    .value ??
                                                    false) ||
                                                    (controller.isNonVag
                                                        .value ??
                                                        false) ||
                                                    (controller
                                                        .isOfferFilter
                                                        .value ??
                                                        false) ||
                                                    (controller
                                                        .searchEditingController
                                                        .value
                                                        .text
                                                        .isNotEmpty);

                                            if (!hasActiveFilters) {
                                              return const SizedBox
                                                  .shrink();
                                            }

                                            return InkWell(
                                              onTap: () {
                                                try {
                                                  controller
                                                      .clearAllFilters();
                                                } catch (e) {
                                                  print(
                                                      'Error clearing filters: $e');
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8,
                                                    vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: themeChange
                                                      .getThem()
                                                      ? AppThemeData
                                                      .grey700
                                                      : AppThemeData
                                                      .grey200,
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(120),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: themeChange
                                                        .getThem()
                                                        ? AppThemeData
                                                        .grey600
                                                        : AppThemeData
                                                        .grey300,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .center,
                                                  children: [
                                                    Icon(
                                                      Icons.clear,
                                                      size: 16,
                                                      color: themeChange
                                                          .getThem()
                                                          ? AppThemeData
                                                          .grey100
                                                          : AppThemeData
                                                          .grey800,
                                                    ),
                                                    const SizedBox(
                                                        width: 4),
                                                    Text(
                                                      'Clear'.tr,
                                                      style: TextStyle(
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey100
                                                            : AppThemeData
                                                            .grey800,
                                                        fontFamily:
                                                        AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        } catch (e) {
                                          print(
                                              'Error building clear filter button: $e');
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // if (controller.vendorModel.value.reststatus == false || controller.isOpen.value == false) ...[
                        if (!controller.canAcceptOrders()) ...[
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                Icon(Icons.lock,
                                    color: Colors.red, size: 48),
                                SizedBox(height: 8),
                                Text(
                                  'This restaurant is currently closed.',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Obx(() {
                                  final statusInfo = controller
                                      .getRestaurantStatusInfo();

                                  return Column(
                                    children: [
                                      Text(
                                        statusInfo['reason'],
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600]),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (statusInfo['nextOpeningTime'] !=
                                          null) ...[
                                        SizedBox(height: 4),
                                        Text(
                                          'Next opening: ${statusInfo['nextOpeningTime']}',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500]),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ] else
                          ...[
                            ProductListView(controller: controller),
                          ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  timeShowBottomSheet(BuildContext context,
      RestaurantDetailsController productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) =>
            FractionallySizedBox(
              heightFactor: 0.70,
              child: StatefulBuilder(builder: (context1, setState) {
                final themeChange = Provider.of<DarkThemeProvider>(context1);
                return Scaffold(
                  backgroundColor: themeChange.getThem()
                      ? AppThemeData.surfaceDark
                      : AppThemeData.surface,
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Container(
                              width: 134,
                              height: 5,
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem()
                                    ? AppThemeData.grey50
                                    : AppThemeData.grey800,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: productModel
                                .vendorModel.value.workingHours!.length,
                            itemBuilder: (context, dayIndex) {
                              WorkingHours workingHours = productModel
                                  .vendorModel.value.workingHours![dayIndex];
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${workingHours.day}",
                                      textAlign: TextAlign.start,
                                      maxLines: 1,
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
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    workingHours.timeslot == null ||
                                        workingHours.timeslot!.isEmpty
                                        ? const SizedBox()
                                        : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount:
                                      workingHours.timeslot!.length,
                                      itemBuilder: (context, timeIndex) {
                                        Timeslot timeSlotModel =
                                        workingHours
                                            .timeslot![timeIndex];
                                        return Padding(
                                          padding:
                                          const EdgeInsets.all(8.0),
                                          child: Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          12)),
                                                      border: Border.all(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemeData
                                                              .grey400
                                                              : AppThemeData
                                                              .grey200)),
                                                  child: Center(
                                                    child: Text(
                                                      timeSlotModel.from
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontFamily:
                                                        AppThemeData
                                                            .medium,
                                                        fontSize: 14,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey400
                                                            : AppThemeData
                                                            .grey500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                      const BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          12)),
                                                      border: Border.all(
                                                          color: themeChange
                                                              .getThem()
                                                              ? AppThemeData
                                                              .grey400
                                                              : AppThemeData
                                                              .grey200)),
                                                  child: Center(
                                                    child: Text(
                                                      timeSlotModel.to
                                                          .toString(),
                                                      style: TextStyle(
                                                        fontFamily:
                                                        AppThemeData
                                                            .medium,
                                                        fontSize: 14,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey400
                                                            : AppThemeData
                                                            .grey500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ));
  }
}

class CouponListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const CouponListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SizedBox(
      height: Responsive.height(9, context),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.couponList.length,
        itemBuilder: (BuildContext context, int index) {
          CouponModel offerModel = controller.couponList[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 300, // fixed width for coupon card
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: themeChange.getThem()
                    ? AppThemeData.grey900
                    : AppThemeData.grey50,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      width: 1,
                      color: themeChange.getThem()
                          ? AppThemeData.grey800
                          : AppThemeData.grey100),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/offer_gif.gif"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          offerModel.discountType == "Fix Price"
                              ? Constant.amountShow(amount: offerModel.discount)
                              : "${offerModel.discount}%",
                          style: TextStyle(
                            color: themeChange.getThem()
                                ? AppThemeData.grey50
                                : AppThemeData.grey50,
                            fontFamily: AppThemeData.semiBold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offerModel.description.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          offerModel.isEnabled == false
                              ? Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "Used",
                              style: TextStyle(
                                fontFamily: AppThemeData.medium,
                                color: AppThemeData.grey400,
                                fontSize: 14,
                              ),
                            ),
                          )
                              : InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(
                                  text: offerModel.code.toString()))
                                  .then((value) {
                                ShowToastDialog.showToast("Copied".tr);
                              });
                            },
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    offerModel.code.toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey500,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                SvgPicture.asset(
                                    "assets/icons/ic_copy.svg"),
                                const SizedBox(
                                    height: 10, child: VerticalDivider()),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    Constant.timestampToDateTime(
                                        offerModel.expiresAt!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey400
                                          : AppThemeData.grey500,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProductListView extends StatelessWidget {
  final RestaurantDetailsController controller;

  const ProductListView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    print(
        "DEBUG: ProductListView build - Categories: ${controller
            .vendorCategoryList.length}, Products: ${controller.productList
            .length}");

    return Container(
      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: controller.productList.isEmpty
          ? _buildNoProductsMessage(context, themeChange)
          : controller.vendorCategoryList.isEmpty
          ? _buildProductsWithoutCategories(
          context, themeChange, controller)
          : ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: controller.vendorCategoryList.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          VendorCategoryModel vendorCategoryModel =
          controller.vendorCategoryList[index];

          print(
              "DEBUG: Building category: ${vendorCategoryModel
                  .title} with ${controller
                  .getProductsByCategory(vendorCategoryModel.id.toString())
                  .length} products");

          return ExpansionTile(
            childrenPadding: EdgeInsets.zero,
            tilePadding: EdgeInsets.zero,
            shape: const Border(),
            initiallyExpanded: true,
            title: Text(
              "${vendorCategoryModel.title.toString()} (${controller
                  .getProductsByCategory(vendorCategoryModel.id.toString())
                  .length})",
              style: TextStyle(
                fontSize: 18,
                fontFamily: AppThemeData.semiBold,
                fontWeight: FontWeight.w600,
                color: themeChange.getThem()
                    ? AppThemeData.grey50
                    : AppThemeData.grey900,
              ),
            ),
            children: [
              Obx(
                    () =>
                    ListView.builder(
                      itemCount: controller
                          .getProductsByCategory(
                          vendorCategoryModel.id.toString())
                          .length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        ProductModel productModel =
                        controller.getProductsByCategory(
                            vendorCategoryModel.id.toString())[index];

                        bool isItemAvailable =
                            productModel.isAvailable ?? true;
                        String price = "0.0";
                        String disPrice = "0.0";
                        List<String> selectedVariants = [];
                        List<String> selectedIndexVariants = [];
                        List<String> selectedIndexArray = [];
                        if (productModel.itemAttribute != null) {
                          if (productModel
                              .itemAttribute!.attributes!.isNotEmpty) {
                            for (var element in productModel
                                .itemAttribute!.attributes!) {
                              if (element.attributeOptions!.isNotEmpty) {
                                selectedVariants.add(productModel
                                    .itemAttribute!
                                    .attributes![productModel
                                    .itemAttribute!.attributes!
                                    .indexOf(element)]
                                    .attributeOptions![0]
                                    .toString());
                                selectedIndexVariants.add(
                                    '${productModel.itemAttribute!.attributes!
                                        .indexOf(element)} _${productModel
                                        .itemAttribute!.attributes![0]
                                        .attributeOptions![0].toString()}');
                                selectedIndexArray.add(
                                    '${productModel.itemAttribute!.attributes!
                                        .indexOf(element)}_0');
                              }
                            }
                          }
                          if (productModel.itemAttribute!.variants!
                              .where((element) =>
                          element.variantSku ==
                              selectedVariants.join('-'))
                              .isNotEmpty) {
                            price = Constant.productCommissionPrice(
                                controller.vendorModel.value,
                                productModel.itemAttribute!.variants!
                                    .where((element) =>
                                element.variantSku ==
                                    selectedVariants.join('-'))
                                    .first
                                    .variantPrice ??
                                    '0');
                            disPrice = "0";
                          }
                        } else {
                          price = Constant.productCommissionPrice(
                              controller.vendorModel.value,
                              productModel.price.toString());
                          disPrice = double.parse(
                              productModel.disPrice.toString()) <=
                              0
                              ? "0"
                              : Constant.productCommissionPrice(
                              controller.vendorModel.value,
                              productModel.disPrice.toString());
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        productModel.nonveg == true
                                            ? SvgPicture.asset(
                                            "assets/icons/ic_nonveg.svg")
                                            : SvgPicture.asset(
                                            "assets/icons/ic_veg.svg"),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          productModel.nonveg == true
                                              ? "Non Veg.".tr
                                              : "Pure veg.".tr,
                                          style: TextStyle(
                                            color: productModel.nonveg ==
                                                true
                                                ? AppThemeData.danger300
                                                : AppThemeData.success400,
                                            fontFamily:
                                            AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            productModel.name.toString(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontFamily:
                                              AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        FutureBuilder<
                                            Map<String, dynamic>?>(
                                          future: FireStoreUtils
                                              .getActivePromotionForProduct(
                                            productId:
                                            productModel.id ?? '',
                                            restaurantId:
                                            productModel.vendorID ??
                                                '',
                                          ),
                                          builder:
                                              (context, promoSnapshot) {
                                            if (promoSnapshot.data !=
                                                null) {
                                              return Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(4),
                                                ),
                                                child: Text(
                                                  'SPECIAL OFFER',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }
                                            return const SizedBox
                                                .shrink();
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        // **FIXED: Use cached promotional data instead of direct Firebase query**
                                        Builder(
                                          builder: (context) {
                                            final promo = controller
                                                .getActivePromotionForProduct(
                                              productId:
                                              productModel.id ?? '',
                                              restaurantId:
                                              productModel.vendorID ??
                                                  '',
                                            );
                                            final hasPromo =
                                                promo != null;
                                            final promoPrice = hasPromo
                                                ? (promo!['special_price']
                                            as num)
                                                .toString()
                                                : null;

                                            if (hasPromo) {
                                              // Special promotional price display
                                              return Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount:
                                                          promoPrice!),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey50
                                                            : AppThemeData
                                                            .grey900,
                                                        fontFamily:
                                                        AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: 5),
                                                  // Show original price with strikethrough
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount: Constant
                                                              .productCommissionPrice(
                                                              controller
                                                                  .vendorModel
                                                                  .value,
                                                              productModel
                                                                  .price
                                                                  .toString())),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                        decorationColor: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey500
                                                            : AppThemeData
                                                            .grey300,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey500
                                                            : AppThemeData
                                                            .grey300,
                                                        fontFamily:
                                                        AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            } else if (double.parse(
                                                disPrice) <=
                                                0) {
                                              // Normal price display
                                              return Text(
                                                Constant.amountShow(
                                                    amount: price),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: themeChange
                                                      .getThem()
                                                      ? AppThemeData
                                                      .grey50
                                                      : AppThemeData
                                                      .grey900,
                                                  fontFamily: AppThemeData
                                                      .semiBold,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              );
                                            } else {
                                              // Regular discount price display
                                              return Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount:
                                                          disPrice),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey50
                                                            : AppThemeData
                                                            .grey900,
                                                        fontFamily:
                                                        AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: 5),
                                                  Flexible(
                                                    child: Text(
                                                      Constant.amountShow(
                                                          amount: price),
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        decoration:
                                                        TextDecoration
                                                            .lineThrough,
                                                        decorationColor: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey500
                                                            : AppThemeData
                                                            .grey300,
                                                        color: themeChange
                                                            .getThem()
                                                            ? AppThemeData
                                                            .grey500
                                                            : AppThemeData
                                                            .grey300,
                                                        fontFamily:
                                                        AppThemeData
                                                            .semiBold,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        if (!isItemAvailable)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(
                                                top: 4),
                                            child: Text(
                                              "Not Available",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontFamily:
                                                AppThemeData.medium,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_star.svg",
                                          colorFilter:
                                          const ColorFilter.mode(
                                              AppThemeData.warning300,
                                              BlendMode.srcIn),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "${Constant.calculateReview(
                                              reviewCount: productModel
                                                  .reviewsCount!
                                                  .toStringAsFixed(0),
                                              reviewSum: productModel.reviewsSum
                                                  .toString())} (${productModel
                                              .reviewsCount!.toStringAsFixed(
                                              0)})",
                                          style: TextStyle(
                                            color: themeChange.getThem()
                                                ? AppThemeData.grey50
                                                : AppThemeData.grey900,
                                            fontFamily:
                                            AppThemeData.regular,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${productModel.description}",
                                      maxLines: 2,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontFamily: AppThemeData.regular,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Visibility(
                                      visible: false,
                                      child: InkWell(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext context) {
                                              return infoDialog(
                                                  controller,
                                                  themeChange,
                                                  productModel);
                                            },
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info,
                                              color: themeChange.getThem()
                                                  ? AppThemeData
                                                  .secondary300
                                                  : AppThemeData
                                                  .secondary300,
                                              size: 18,
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Text(
                                              "Info".tr,
                                              maxLines: 2,
                                              style: TextStyle(
                                                overflow:
                                                TextOverflow.ellipsis,
                                                fontSize: 16,
                                                color:
                                                themeChange.getThem()
                                                    ? AppThemeData
                                                    .secondary300
                                                    : AppThemeData
                                                    .secondary300,
                                                fontFamily:
                                                AppThemeData.regular,
                                                fontWeight:
                                                FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16)),
                                    child: ColorFiltered(
                                      colorFilter: isItemAvailable
                                          ? const ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.multiply)
                                          : const ColorFilter.mode(
                                          Colors.grey,
                                          BlendMode.saturation),
                                      child: NetworkImageWidget(
                                        imageUrl:
                                        productModel.photo.toString(),
                                        fit: BoxFit.cover,
                                        height: Responsive.height(
                                            16, context),
                                        width:
                                        Responsive.width(34, context),
                                      ),
                                    ),
                                  ),
                                  // **FIXED: Special promotional price badge using cached data**
                                  Builder(
                                    builder: (context) {
                                      final promo = controller
                                          .getActivePromotionForProduct(
                                        productId: productModel.id ?? '',
                                        restaurantId:
                                        productModel.vendorID ?? '',
                                      );

                                      print(
                                          '[DEBUG] Product ${productModel
                                              .id} - Promotion data: $promo');
                                      if (promo != null) {
                                        print(
                                            '[DEBUG] Showing SPECIAL badge for product ${productModel
                                                .id}');
                                        print(
                                            '[DEBUG] Badge will be rendered with black background and white text');
                                        return Positioned(
                                          top: 0,
                                          left: 0,
                                          child: const SpecialPriceBadge(
                                            showShimmer: true,
                                            width: 60,
                                            height: 60,
                                            margin: EdgeInsets.zero,
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  if (!isItemAvailable)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black
                                              .withOpacity(0.4),
                                          borderRadius:
                                          const BorderRadius.all(
                                              Radius.circular(16)),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: InkWell(
                                      onTap: () async {
                                        if (controller.favouriteItemList
                                            .where((p0) =>
                                        p0.productId ==
                                            productModel.id)
                                            .isNotEmpty) {
                                          FavouriteItemModel
                                          favouriteModel =
                                          FavouriteItemModel(
                                              productId:
                                              productModel.id,
                                              storeId: controller
                                                  .vendorModel
                                                  .value
                                                  .id,
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
                                          FavouriteItemModel
                                          favouriteModel =
                                          FavouriteItemModel(
                                              productId:
                                              productModel.id,
                                              storeId: controller
                                                  .vendorModel
                                                  .value
                                                  .id,
                                              userId: FireStoreUtils
                                                  .getCurrentUid());
                                          controller.favouriteItemList
                                              .add(favouriteModel);

                                          await FireStoreUtils
                                              .setFavouriteItem(
                                              favouriteModel);
                                        }
                                      },
                                      child: Obx(
                                            () =>
                                        controller.favouriteItemList
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
                                    ),
                                  ),
                                  controller.isOpen.value == false ||
                                      Constant.userModel == null
                                      ? const SizedBox()
                                      : Positioned(
                                    bottom: 10,
                                    left: 20,
                                    right: 20,
                                    child: isItemAvailable
                                        ? selectedVariants
                                        .isNotEmpty ||
                                        (productModel
                                            .addOnsTitle !=
                                            null &&
                                            productModel
                                                .addOnsTitle!
                                                .isNotEmpty)
                                        ? RoundedButtonFill(
                                      title: "Add".tr,
                                      width: 10,
                                      height: 4,
                                      color: themeChange
                                          .getThem()
                                          ? AppThemeData
                                          .grey900
                                          : AppThemeData
                                          .grey50,
                                      textColor:
                                      AppThemeData
                                          .primary300,
                                      onPress: () async {
                                        controller
                                            .selectedVariants
                                            .clear();
                                        controller
                                            .selectedIndexVariants
                                            .clear();
                                        controller
                                            .selectedIndexArray
                                            .clear();
                                        controller
                                            .selectedAddOns
                                            .clear();
                                        controller
                                            .quantity
                                            .value = 1;
                                        if (productModel
                                            .itemAttribute !=
                                            null) {
                                          if (productModel
                                              .itemAttribute!
                                              .attributes!
                                              .isNotEmpty) {
                                            for (var element
                                            in productModel
                                                .itemAttribute!
                                                .attributes!) {
                                              if (element
                                                  .attributeOptions!
                                                  .isNotEmpty) {
                                                controller.selectedVariants.add(
                                                    productModel
                                                        .itemAttribute!
                                                        .attributes![productModel
                                                        .itemAttribute!
                                                        .attributes!
                                                        .indexOf(element)]
                                                        .attributeOptions![0]
                                                        .toString());
                                                controller
                                                    .selectedIndexVariants
                                                    .add(
                                                    '${productModel
                                                        .itemAttribute!
                                                        .attributes!.indexOf(
                                                        element)} _${productModel
                                                        .itemAttribute!
                                                        .attributes![0]
                                                        .attributeOptions![0]
                                                        .toString()}');
                                                controller
                                                    .selectedIndexArray
                                                    .add(
                                                    '${productModel
                                                        .itemAttribute!
                                                        .attributes!.indexOf(
                                                        element)}_0');
                                              }
                                            }
                                          }
                                          final bool
                                          productIsInList =
                                          cartItem.any((product) =>
                                          product
                                              .id ==
                                              "${productModel.id}~${productModel
                                                  .itemAttribute!.variants!
                                                  .where((element) =>
                                              element.variantSku ==
                                                  controller.selectedVariants
                                                      .join('-')).isNotEmpty
                                                  ? productModel.itemAttribute!
                                                  .variants!.where((element) =>
                                              element.variantSku ==
                                                  controller.selectedVariants
                                                      .join('-')).first
                                                  .variantId.toString()
                                                  : ""}");

                                          if (productIsInList) {
                                            CartProductModel
                                            element =
                                            cartItem.firstWhere((product) =>
                                            product
                                                .id ==
                                                "${productModel
                                                    .id}~${productModel
                                                    .itemAttribute!.variants!
                                                    .where((element) =>
                                                element.variantSku ==
                                                    controller.selectedVariants
                                                        .join('-')).isNotEmpty
                                                    ? productModel
                                                    .itemAttribute!
                                                    .variants!
                                                    .where((element) =>
                                                element.variantSku == controller
                                                    .selectedVariants.join('-'))
                                                    .first.variantId.toString()
                                                    : ""}");
                                            controller
                                                .quantity
                                                .value =
                                            element
                                                .quantity!;
                                            if (element
                                                .extras !=
                                                null) {
                                              for (var element
                                              in element
                                                  .extras!) {
                                                controller
                                                    .selectedAddOns
                                                    .add(
                                                    element);
                                              }
                                            }
                                          }
                                        } else {
                                          if (cartItem
                                              .where((product) =>
                                          product
                                              .id ==
                                              "${productModel.id}")
                                              .isNotEmpty) {
                                            CartProductModel
                                            element =
                                            cartItem.firstWhere((product) =>
                                            product
                                                .id ==
                                                "${productModel.id}");
                                            controller
                                                .quantity
                                                .value =
                                            element
                                                .quantity!;
                                            if (element
                                                .extras !=
                                                null) {
                                              for (var element
                                              in element
                                                  .extras!) {
                                                controller
                                                    .selectedAddOns
                                                    .add(
                                                    element);
                                              }
                                            }
                                          }
                                        }
                                        controller
                                            .update();
                                        controller
                                            .calculatePrice(
                                            productModel);
                                        productDetailsBottomSheet(
                                            context,
                                            productModel);
                                      },
                                    )
                                        : Obx(
                                          () =>
                                      cartItem
                                          .where((p0) =>
                                      p0.id ==
                                          productModel
                                              .id)
                                          .isNotEmpty
                                          ? Container(
                                        width: Responsive
                                            .width(
                                            100,
                                            context),
                                        height: Responsive
                                            .height(
                                            4,
                                            context),
                                        decoration:
                                        ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData
                                              .grey900
                                              : AppThemeData
                                              .grey50,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(200),
                                          ),
                                        ),
                                        child:
                                        SingleChildScrollView(
                                          scrollDirection:
                                          Axis.horizontal,
                                          child:
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap:
                                                    () async {
                                                  // Check for promotional price
                                                  final promo = await FireStoreUtils
                                                      .getActivePromotionForProduct(
                                                    productId: productModel
                                                        .id ?? '',
                                                    restaurantId: productModel
                                                        .vendorID ?? '',
                                                  );

                                                  String finalPrice = price;
                                                  String finalDiscountPrice = disPrice;

                                                  if (promo != null) {
                                                    // Use promotional price
                                                    finalPrice =
                                                        (promo['special_price'] as num)
                                                            .toString();
                                                    finalDiscountPrice =
                                                        Constant
                                                            .productCommissionPrice(
                                                            controller
                                                                .vendorModel
                                                                .value,
                                                            productModel.price
                                                                .toString()); // original price for strikethrough
                                                  }

                                                  controller.addToCart(
                                                    productModel: productModel,
                                                    price: finalPrice,
                                                    discountPrice: finalDiscountPrice,
                                                    isIncrement: false,
                                                    quantity: cartItem
                                                        .where((p0) =>
                                                    p0.id == productModel.id)
                                                        .first
                                                        .quantity! - 1,
                                                  );
                                                },
                                                child:
                                                const Icon(Icons.remove),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 14),
                                                child:
                                                Text(
                                                  cartItem
                                                      .where((p0) =>
                                                  p0.id == productModel.id)
                                                      .first
                                                      .quantity
                                                      .toString(),
                                                  textAlign: TextAlign.start,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    fontFamily: AppThemeData
                                                        .medium,
                                                    fontWeight: FontWeight.w500,
                                                    color: themeChange.getThem()
                                                        ? AppThemeData.grey100
                                                        : AppThemeData.grey800,
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                onTap:
                                                    () async {
                                                  if ((cartItem
                                                      .where((p0) =>
                                                  p0.id == productModel.id)
                                                      .first
                                                      .quantity ?? 0) <=
                                                      (productModel.quantity ??
                                                          0) ||
                                                      (productModel.quantity ??
                                                          0) == -1) {
                                                    // Check for promotional price and limit
                                                    final promo = await FireStoreUtils
                                                        .getActivePromotionForProduct(
                                                      productId: productModel
                                                          .id ?? '',
                                                      restaurantId: productModel
                                                          .vendorID ?? '',
                                                    );

                                                    // Check promotional item limit using new helper method
                                                    if (promo != null) {
                                                      final isAllowed = controller
                                                          .isPromotionalItemQuantityAllowed(
                                                          productModel.id ?? '',
                                                          productModel
                                                              .vendorID ?? '',
                                                          cartItem
                                                              .where((p0) =>
                                                          p0.id ==
                                                              productModel.id)
                                                              .first
                                                              .quantity! + 1);

                                                      if (!isAllowed) {
                                                        final limit = controller
                                                            .getPromotionalItemLimit(
                                                            productModel.id ??
                                                                '', productModel
                                                            .vendorID ?? '');
                                                        ShowToastDialog
                                                            .showToast(
                                                            "Maximum $limit items allowed for this promotional offer"
                                                                .tr);
                                                        return;
                                                      }
                                                    }

                                                    String finalPrice = price;
                                                    String finalDiscountPrice = disPrice;

                                                    if (promo != null) {
                                                      // Use promotional price
                                                      finalPrice =
                                                          (promo['special_price'] as num)
                                                              .toString();
                                                      finalDiscountPrice =
                                                          Constant
                                                              .productCommissionPrice(
                                                              controller
                                                                  .vendorModel
                                                                  .value,
                                                              productModel.price
                                                                  .toString()); // original price for strikethrough
                                                    }

                                                    controller.addToCart(
                                                      productModel: productModel,
                                                      price: finalPrice,
                                                      discountPrice: finalDiscountPrice,
                                                      isIncrement: true,
                                                      quantity: cartItem
                                                          .where((p0) =>
                                                      p0.id == productModel.id)
                                                          .first
                                                          .quantity! + 1,
                                                    );
                                                  } else {
                                                    ShowToastDialog.showToast(
                                                        "Out of stock".tr);
                                                  }
                                                },
                                                child:
                                                const Icon(Icons.add),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                          : RoundedButtonFill(
                                        title: "Add"
                                            .tr,
                                        width: 10,
                                        height: 4,
                                        color: themeChange.getThem()
                                            ? AppThemeData
                                            .grey900
                                            : AppThemeData
                                            .grey50,
                                        textColor:
                                        AppThemeData
                                            .primary300,
                                        onPress:
                                            () async {
                                          if (1 <=
                                              (productModel.quantity ?? 0) ||
                                              (productModel.quantity ?? 0) ==
                                                  -1) {
                                            // Check for promotional price (ULTRA-FAST - ZERO ASYNC)
                                            final promo =
                                            controller
                                                .getActivePromotionForProduct(
                                              productId:
                                              productModel.id ?? '',
                                              restaurantId:
                                              productModel.vendorID ?? '',
                                            );

                                            String
                                            finalPrice =
                                                price;
                                            String
                                            finalDiscountPrice =
                                                disPrice;

                                            if (promo !=
                                                null) {
                                              // Use promotional price
                                              finalPrice =
                                                  (promo['special_price'] as num)
                                                      .toString();
                                              finalDiscountPrice = Constant
                                                  .productCommissionPrice(
                                                  controller.vendorModel.value,
                                                  productModel.price
                                                      .toString()); // original price for strikethrough
                                            }

                                            controller.addToCart(
                                                productModel:
                                                productModel,
                                                price:
                                                finalPrice,
                                                discountPrice:
                                                finalDiscountPrice,
                                                isIncrement:
                                                true,
                                                quantity:
                                                1);
                                          } else {
                                            ShowToastDialog.showToast(
                                                "Out of stock".tr);
                                          }
                                        },
                                      ),
                                    )
                                        : const SizedBox(), // Removed the grey button completely
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              )
            ],
          );
        },
      ),
    );
  }

  productDetailsBottomSheet(BuildContext context, ProductModel productModel) {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(30),
          ),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        builder: (context) =>
            FractionallySizedBox(
              heightFactor: 0.85,
              child: StatefulBuilder(builder: (context1, setState) {
                return ProductDetailsView(
                  productModel: productModel,
                );
              }),
            ));
  }

  infoDialog(RestaurantDetailsController controller, themeChange,
      ProductModel productModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem()
          ? AppThemeData.surfaceDark
          : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Food Information's".tr,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: AppThemeData.semiBold,
                      color: themeChange.getThem()
                          ? AppThemeData.grey50
                          : AppThemeData.grey900,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  productModel.description.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.regular,
                    fontWeight: FontWeight.w400,
                    color: themeChange.getThem()
                        ? AppThemeData.grey50
                        : AppThemeData.grey900,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Gram".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.grams.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Calories".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.calories.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Proteins".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.proteins.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        "Fats".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.regular,
                          color: themeChange.getThem()
                              ? AppThemeData.grey300
                              : AppThemeData.grey600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      productModel.fats.toString(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.bold,
                        color: themeChange.getThem()
                            ? AppThemeData.grey50
                            : AppThemeData.grey900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                productModel.productSpecification != null &&
                    productModel.productSpecification!.isNotEmpty
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        "Specification".tr,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontFamily: AppThemeData.semiBold,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ListView.builder(
                      itemCount:
                      productModel.productSpecification!.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productModel.productSpecification!.keys
                                    .elementAt(index),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.regular,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey300
                                      : AppThemeData.grey600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                productModel.productSpecification!.values
                                    .elementAt(index),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.bold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                )
                    : const SizedBox(),
                const SizedBox(
                  height: 20,
                ),
                RoundedButtonFill(
                  title: "Back".tr,
                  color: AppThemeData.primary300,
                  textColor: AppThemeData.grey50,
                  onPress: () async {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
                                            () =>
                                        controller.favouriteItemList
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
                                              controller.selectedVariants
                                                  .insert(
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
                                                  '$index _${productModel
                                                      .itemAttribute!
                                                      .attributes![index]
                                                      .attributeOptions![i]
                                                      .toString()}');
                                              controller
                                                  .selectedIndexArray
                                                  .add(
                                                  '${index}_$i');
                                            } else {
                                              controller
                                                  .selectedIndexArray
                                                  .remove(
                                                  '${index}_${productModel
                                                      .itemAttribute!
                                                      .attributes![index]
                                                      .attributeOptions
                                                      ?.indexOf(controller
                                                      .selectedIndexVariants
                                                      .where((element) =>
                                                      element.contains(
                                                          '$index _'))
                                                      .first
                                                      .replaceAll(
                                                      '$index _', ''))}');
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
                                              controller.selectedVariants
                                                  .insert(
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
                                                  '$index _${productModel
                                                      .itemAttribute!
                                                      .attributes![index]
                                                      .attributeOptions![i]
                                                      .toString()}');
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
                                                    "${productModel
                                                        .id}~${productModel
                                                        .itemAttribute!
                                                        .variants!
                                                        .where((element) =>
                                                    element.variantSku ==
                                                        controller
                                                            .selectedVariants
                                                            .join('-'))
                                                        .isNotEmpty
                                                        ? productModel
                                                        .itemAttribute!
                                                        .variants!.where((
                                                        element) =>
                                                    element.variantSku ==
                                                        controller
                                                            .selectedVariants
                                                            .join('-')).first
                                                        .variantId.toString()
                                                        : ""}");
                                            if (productIsInList) {
                                              CartProductModel
                                              element =
                                              cartItem.firstWhere(
                                                      (product) =>
                                                  product
                                                      .id ==
                                                      "${productModel
                                                          .id}~${productModel
                                                          .itemAttribute!
                                                          .variants!
                                                          .where((element) =>
                                                      element.variantSku ==
                                                          controller
                                                              .selectedVariants
                                                              .join('-'))
                                                          .isNotEmpty
                                                          ? productModel
                                                          .itemAttribute!
                                                          .variants!.where((
                                                          element) =>
                                                      element.variantSku ==
                                                          controller
                                                              .selectedVariants
                                                              .join('-')).first
                                                          .variantId.toString()
                                                          : ""}");
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
                                              () =>
                                              SizedBox(
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
                            "${'Add item'.tr} ${Constant.amountShow(
                                amount: price)}"
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
                                    element.variantSku ==
                                        controller.selectedVariants.join('-'))
                                        .first
                                        .variantImage ??
                                        '',
                                    variantId: productModel.itemAttribute!
                                        .variants!
                                        .where((element) =>
                                    element.variantSku ==
                                        controller.selectedVariants.join('-'))
                                        .first.variantId ?? '0');

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

Widget _buildProductsWithoutCategories(BuildContext context,
    DarkThemeProvider themeChange, RestaurantDetailsController controller) {
  return Obx(() =>
      ListView.builder(
        itemCount: controller.productList.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          ProductModel productModel = controller.productList[index];

          bool isItemAvailable = productModel.isAvailable ?? true;
          String price = "0.0";
          String disPrice = "0.0";
          List<String> selectedVariants = [];
          List<String> selectedIndexVariants = [];
          List<String> selectedIndexArray = [];
          if (productModel.itemAttribute != null) {
            if (productModel.itemAttribute!.attributes!.isNotEmpty) {
              for (var element in productModel.itemAttribute!.attributes!) {
                if (element.attributeOptions!.isNotEmpty) {
                  selectedVariants.add(productModel
                      .itemAttribute!
                      .attributes![productModel.itemAttribute!.attributes!
                      .indexOf(element)]
                      .attributeOptions![0]
                      .toString());
                  selectedIndexVariants.add(
                      '${productModel.itemAttribute!.attributes!.indexOf(
                          element)} _${productModel.itemAttribute!
                          .attributes![0].attributeOptions![0].toString()}');
                  selectedIndexArray.add(
                      '${productModel.itemAttribute!.attributes!.indexOf(
                          element)}_0');
                }
              }
            }
            if (productModel.itemAttribute!.variants!
                .where((element) =>
            element.variantSku == selectedVariants.join('-'))
                .isNotEmpty) {
              price = Constant.productCommissionPrice(
                  controller.vendorModel.value,
                  productModel.itemAttribute!.variants!
                      .where((element) =>
                  element.variantSku == selectedVariants.join('-'))
                      .first
                      .variantPrice ??
                      '0');
              disPrice = "0";
            }
          } else {
            price = Constant.productCommissionPrice(
                controller.vendorModel.value, productModel.price.toString());
            disPrice = double.parse(productModel.disPrice.toString()) <= 0
                ? "0"
                : Constant.productCommissionPrice(controller.vendorModel.value,
                productModel.disPrice.toString());
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          productModel.nonveg == true
                              ? SvgPicture.asset("assets/icons/ic_nonveg.svg")
                              : SvgPicture.asset("assets/icons/ic_veg.svg"),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            productModel.nonveg == true
                                ? "Non Veg.".tr
                                : "Pure veg.".tr,
                            style: TextStyle(
                              color: productModel.nonveg == true
                                  ? AppThemeData.danger300
                                  : AppThemeData.success400,
                              fontFamily: AppThemeData.semiBold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    productModel.name.toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: themeChange.getThem()
                                          ? AppThemeData.grey50
                                          : AppThemeData.grey900,
                                      fontFamily: AppThemeData.semiBold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FutureBuilder<Map<String, dynamic>?>(
                                  future: FireStoreUtils
                                      .getActivePromotionForProduct(
                                    productId: productModel.id ?? '',
                                    restaurantId: productModel.vendorID ?? '',
                                  ),
                                  builder: (context, promoSnapshot) {
                                    if (promoSnapshot.data != null) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'SPECIAL OFFER',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder<Map<String, dynamic>?>(
                            future: Future.value(
                                controller.getActivePromotionForProduct(
                                  productId: productModel.id ?? '',
                                  restaurantId: productModel.vendorID ?? '',
                                )),
                            builder: (context, promoSnapshot) {
                              final hasPromo = promoSnapshot.data != null;
                              final promoPrice = hasPromo
                                  ? (promoSnapshot.data!['special_price']
                              as num)
                                  .toString()
                                  : null;

                              if (hasPromo) {
                                // Special promotional price display
                                return Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        Constant.amountShow(
                                            amount: promoPrice!),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    // Show original price with strikethrough
                                    Flexible(
                                      child: Text(
                                        Constant.amountShow(
                                            amount:
                                            Constant.productCommissionPrice(
                                                controller
                                                    .vendorModel.value,
                                                productModel.price
                                                    .toString())),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration:
                                          TextDecoration.lineThrough,
                                          decorationColor: themeChange.getThem()
                                              ? AppThemeData.grey500
                                              : AppThemeData.grey400,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey500
                                              : AppThemeData.grey400,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else if (double.parse(disPrice) <= 0) {
                                // Normal price display
                                return Text(
                                  Constant.amountShow(amount: price),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              } else {
                                // Regular discount price display
                                return Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        Constant.amountShow(amount: disPrice),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey50
                                              : AppThemeData.grey900,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        Constant.amountShow(amount: price),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          decoration:
                                          TextDecoration.lineThrough,
                                          decorationColor: themeChange.getThem()
                                              ? AppThemeData.grey500
                                              : AppThemeData.grey400,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey500
                                              : AppThemeData.grey400,
                                          fontFamily: AppThemeData.semiBold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
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
                        ],
                      ),
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_star.svg",
                            colorFilter: const ColorFilter.mode(
                                AppThemeData.warning300, BlendMode.srcIn),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "${Constant.calculateReview(
                                reviewCount: productModel.reviewsCount!
                                    .toStringAsFixed(0),
                                reviewSum: productModel.reviewsSum
                                    .toString())} (${productModel.reviewsCount!
                                .toStringAsFixed(0)})",
                            style: TextStyle(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey50
                                  : AppThemeData.grey900,
                              fontFamily: AppThemeData.regular,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "${productModel.description}",
                        maxLines: 2,
                        style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: themeChange.getThem()
                              ? AppThemeData.grey50
                              : AppThemeData.grey900,
                          fontFamily: AppThemeData.regular,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: ColorFiltered(
                        colorFilter: isItemAvailable
                            ? const ColorFilter.mode(
                            Colors.transparent, BlendMode.multiply)
                            : const ColorFilter.mode(
                            Colors.grey, BlendMode.saturation),
                        child: NetworkImageWidget(
                          imageUrl: productModel.photo.toString(),
                          fit: BoxFit.cover,
                          height: Responsive.height(16, context),
                          width: Responsive.width(34, context),
                        ),
                      ),
                    ),
                    // Special promotional price badge
                    FutureBuilder<Map<String, dynamic>?>(
                      future:
                      Future.value(controller.getActivePromotionForProduct(
                        productId: productModel.id ?? '',
                        restaurantId: productModel.vendorID ?? '',
                      )),
                      builder: (context, promoSnapshot) {
                        print(
                            '[DEBUG] Product ${productModel
                                .id} - Promotion data: ${promoSnapshot.data}');
                        if (promoSnapshot.data != null) {
                          print(
                              '[DEBUG] Showing SPECIAL badge for product ${productModel
                                  .id}');
                          print(
                              '[DEBUG] Badge will be rendered with black background and white text');
                          return Positioned(
                            top: 0,
                            left: 0,
                            child: const SpecialPriceBadge(
                              showShimmer: true,
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.zero,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    if (!isItemAvailable)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 10,
                      top: 10,
                      child: InkWell(
                        onTap: () async {
                          if (controller.favouriteItemList
                              .where((p0) => p0.productId == productModel.id)
                              .isNotEmpty) {
                            FavouriteItemModel favouriteModel =
                            FavouriteItemModel(
                                productId: productModel.id,
                                storeId: controller.vendorModel.value.id,
                                userId: FireStoreUtils.getCurrentUid());
                            controller.favouriteItemList.removeWhere(
                                    (item) =>
                                item.productId == productModel.id);
                            await FireStoreUtils.removeFavouriteItem(
                                favouriteModel);
                          } else {
                            FavouriteItemModel favouriteModel =
                            FavouriteItemModel(
                                productId: productModel.id,
                                storeId: controller.vendorModel.value.id,
                                userId: FireStoreUtils.getCurrentUid());
                            controller.favouriteItemList.add(favouriteModel);

                            await FireStoreUtils.setFavouriteItem(
                                favouriteModel);
                          }
                        },
                        child: Obx(
                              () =>
                          controller.favouriteItemList
                              .where(
                                  (p0) => p0.productId == productModel.id)
                              .isNotEmpty
                              ? SvgPicture.asset(
                            "assets/icons/ic_like_fill.svg",
                          )
                              : SvgPicture.asset(
                            "assets/icons/ic_like.svg",
                          ),
                        ),
                      ),
                    ),
                    controller.isOpen.value == false ||
                        Constant.userModel == null
                        ? const SizedBox()
                        : Positioned(
                      bottom: 10,
                      left: 20,
                      right: 20,
                      child: isItemAvailable
                          ? selectedVariants.isNotEmpty ||
                          (productModel.addOnsTitle != null &&
                              productModel
                                  .addOnsTitle!.isNotEmpty)
                          ? RoundedButtonFill(
                        title: "Add".tr,
                        width: 10,
                        height: 4,
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        textColor: AppThemeData.primary300,
                        onPress: () async {
                          controller.selectedVariants.clear();
                          controller.selectedIndexVariants
                              .clear();
                          controller.selectedIndexArray.clear();
                          controller.selectedAddOns.clear();
                          controller.quantity.value = 1;
                          if (productModel.itemAttribute !=
                              null) {
                            if (productModel.itemAttribute!
                                .attributes!.isNotEmpty) {
                              for (var element in productModel
                                  .itemAttribute!.attributes!) {
                                if (element.attributeOptions!
                                    .isNotEmpty) {
                                  controller.selectedVariants
                                      .add(productModel
                                      .itemAttribute!
                                      .attributes![
                                  productModel
                                      .itemAttribute!
                                      .attributes!
                                      .indexOf(
                                      element)]
                                      .attributeOptions![0]
                                      .toString());
                                  controller
                                      .selectedIndexVariants
                                      .add(
                                      '${productModel.itemAttribute!.attributes!
                                          .indexOf(element)} _${productModel
                                          .itemAttribute!.attributes![0]
                                          .attributeOptions![0].toString()}');
                                  controller.selectedIndexArray.add(
                                      '${productModel.itemAttribute!.attributes!
                                          .indexOf(element)}_0');
                                }
                              }
                            }
                            final bool productIsInList =
                            cartItem.any((product) =>
                            product.id ==
                                "${productModel.id}~${productModel
                                    .itemAttribute!
                                    .variants!
                                    .where((element) =>
                                element.variantSku ==
                                    controller.selectedVariants.join('-'))
                                    .isNotEmpty ? productModel.itemAttribute!
                                    .variants!.where((element) =>
                                element.variantSku ==
                                    controller.selectedVariants.join('-')).first
                                    .variantId.toString() : ""}");

                            if (productIsInList) {
                              CartProductModel element = cartItem
                                  .firstWhere((product) =>
                              product.id ==
                                  "${productModel.id}~${productModel
                                      .itemAttribute!
                                      .variants!
                                      .where((element) =>
                                  element.variantSku ==
                                      controller.selectedVariants.join('-'))
                                      .isNotEmpty ? productModel.itemAttribute!
                                      .variants!
                                      .where((element) =>
                                  element.variantSku ==
                                      controller.selectedVariants.join('-'))
                                      .first.variantId.toString() : ""}");
                              controller.quantity.value =
                              element.quantity!;
                            } else {
                              controller.quantity.value = 1;
                            }
                          }

                          controller.update();
                          controller
                              .calculatePrice(productModel)
                              .then((_) {
                            controller.update();
                          });
                          // productDetailsBottomSheet(
                          //     context,
                          //     productModel);
                        },
                      )
                          : Obx(
                            () =>
                        cartItem
                            .where((p0) =>
                        p0.id == productModel.id)
                            .isNotEmpty
                            ? Container(
                          width: Responsive.width(
                              120, context),
                          height: Responsive.height(
                              4.5, context),
                          decoration: ShapeDecoration(
                            color: themeChange.getThem()
                                ? AppThemeData.grey900
                                : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  200),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            crossAxisAlignment:
                            CrossAxisAlignment.center,
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Flexible(
                                child: InkWell(
                                  onTap: () async {
                                    // Check for promotional price
                                    final promo =
                                    await FireStoreUtils
                                        .getActivePromotionForProduct(
                                      productId:
                                      productModel
                                          .id ??
                                          '',
                                      restaurantId:
                                      productModel
                                          .vendorID ??
                                          '',
                                    );

                                    String finalPrice =
                                        price;
                                    String
                                    finalDiscountPrice =
                                        disPrice;

                                    if (promo != null) {
                                      // Use promotional price
                                      finalPrice =
                                          (promo['special_price']
                                          as num)
                                              .toString();
                                      finalDiscountPrice =
                                          Constant.productCommissionPrice(
                                              controller
                                                  .vendorModel
                                                  .value,
                                              productModel
                                                  .price
                                                  .toString()); // original price for strikethrough
                                    }

                                    controller.addToCart(
                                      productModel:
                                      productModel,
                                      price: finalPrice,
                                      discountPrice:
                                      finalDiscountPrice,
                                      isIncrement: false,
                                      quantity: cartItem
                                          .where((p0) =>
                                      p0.id ==
                                          productModel
                                              .id)
                                          .first
                                          .quantity! -
                                          1,
                                    );
                                  },
                                  child: const Icon(
                                      Icons.remove),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal: 8),
                                  child: Text(
                                    cartItem
                                        .where((p0) =>
                                    p0.id ==
                                        productModel
                                            .id)
                                        .first
                                        .quantity
                                        .toString(),
                                    textAlign:
                                    TextAlign.center,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: cartItem
                                          .where((p0) =>
                                      p0.id ==
                                          productModel.id)
                                          .first
                                          .quantity
                                          .toString()
                                          .length >
                                          2
                                          ? 12
                                          : 16,
                                      overflow:
                                      TextOverflow
                                          .ellipsis,
                                      fontFamily:
                                      AppThemeData
                                          .medium,
                                      fontWeight:
                                      FontWeight.w500,
                                      color: themeChange
                                          .getThem()
                                          ? AppThemeData
                                          .grey100
                                          : AppThemeData
                                          .grey800,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: InkWell(
                                  onTap: () async {
                                    if ((cartItem
                                        .where((p0) =>
                                    p0.id ==
                                        productModel
                                            .id)
                                        .first
                                        .quantity ??
                                        0) <=
                                        (productModel
                                            .quantity ??
                                            0) ||
                                        (productModel
                                            .quantity ??
                                            0) ==
                                            -1) {
                                      // Check for promotional price and limit (ULTRA-FAST - ZERO ASYNC)
                                      final promo = controller
                                          .getActivePromotionForProduct(
                                        productId:
                                        productModel
                                            .id ??
                                            '',
                                        restaurantId:
                                        productModel
                                            .vendorID ??
                                            '',
                                      );

                                      // Check promotional item limit using new helper method
                                      if (promo != null) {
                                        final isAllowed = controller
                                            .isPromotionalItemQuantityAllowed(
                                            productModel.id ??
                                                '',
                                            productModel
                                                .vendorID ??
                                                '',
                                            cartItem
                                                .where((p0) =>
                                            p0.id ==
                                                productModel.id)
                                                .first
                                                .quantity! +
                                                1);

                                        if (!isAllowed) {
                                          final limit = controller
                                              .getPromotionalItemLimit(
                                              productModel
                                                  .id ??
                                                  '',
                                              productModel
                                                  .vendorID ??
                                                  '');
                                          ShowToastDialog
                                              .showToast(
                                              "Maximum $limit items allowed for this promotional offer"
                                                  .tr);
                                          return;
                                        }
                                      }

                                      String finalPrice =
                                          price;
                                      String
                                      finalDiscountPrice =
                                          disPrice;

                                      if (promo != null) {
                                        // Use promotional price
                                        finalPrice =
                                            (promo['special_price']
                                            as num)
                                                .toString();
                                        finalDiscountPrice =
                                            Constant.productCommissionPrice(
                                                controller
                                                    .vendorModel
                                                    .value,
                                                productModel
                                                    .price
                                                    .toString()); // original price for strikethrough
                                      }

                                      controller
                                          .addToCart(
                                        productModel:
                                        productModel,
                                        price: finalPrice,
                                        discountPrice:
                                        finalDiscountPrice,
                                        isIncrement: true,
                                        quantity: cartItem
                                            .where((p0) =>
                                        p0.id ==
                                            productModel
                                                .id)
                                            .first
                                            .quantity! +
                                            1,
                                      );
                                    } else {
                                      ShowToastDialog
                                          .showToast(
                                          "Out of stock"
                                              .tr);
                                    }
                                  },
                                  child: const Icon(
                                      Icons.add),
                                ),
                              ),
                            ],
                          ),
                        )
                        //changed here
                            : RoundedButtonFill(
                          title: "Add".tr,
                          width: 10,
                          height: 4,
                          color: themeChange.getThem()
                              ? AppThemeData.grey900
                              : AppThemeData.grey50,
                          textColor:
                          AppThemeData.primary300,
                          onPress: () async {
                            if (1 <=
                                (productModel
                                    .quantity ??
                                    0) ||
                                (productModel.quantity ??
                                    0) ==
                                    -1) {
                              // Check for promotional price and limit (ULTRA-FAST - ZERO ASYNC)
                              final promo = controller
                                  .getActivePromotionForProduct(
                                productId:
                                productModel.id ?? '',
                                restaurantId: productModel
                                    .vendorID ??
                                    '',
                              );

                              // Check promotional item limit using new helper method
                              if (promo != null) {
                                final isAllowed = controller
                                    .isPromotionalItemQuantityAllowed(
                                    productModel.id ??
                                        '',
                                    productModel
                                        .vendorID ??
                                        '',
                                    1);

                                if (!isAllowed) {
                                  final limit = controller
                                      .getPromotionalItemLimit(
                                      productModel
                                          .id ??
                                          '',
                                      productModel
                                          .vendorID ??
                                          '');
                                  ShowToastDialog.showToast(
                                      "Maximum $limit items allowed for this promotional offer"
                                          .tr);
                                  return;
                                }
                              }
                              String finalPrice = price;
                              String finalDiscountPrice =
                                  disPrice;

                              if (promo != null) {
                                // Use promotional price
                                finalPrice =
                                    (promo['special_price']
                                    as num)
                                        .toString();
                                finalDiscountPrice = Constant
                                    .productCommissionPrice(
                                    controller
                                        .vendorModel
                                        .value,
                                    productModel.price
                                        .toString()); // original price for strikethrough
                              }
                              controller.addToCart(
                                  productModel:
                                  productModel,
                                  price: finalPrice,
                                  discountPrice:
                                  finalDiscountPrice,
                                  isIncrement: true,
                                  quantity: 1);
                            } else {
                              ShowToastDialog.showToast(
                                  "Out of stock".tr);
                            }
                          },
                        ),
                      )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ));
}

/// Builds the "No products available" message widget
Widget _buildNoProductsMessage(BuildContext context,
    DarkThemeProvider themeChange) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.restaurant_menu_outlined,
          size: 80,
          color: themeChange.getThem()
              ? AppThemeData.grey400
              : AppThemeData.grey600,
        ),
        const SizedBox(height: 20),
        Text(
          "No products available here".tr,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: themeChange.getThem()
                ? AppThemeData.grey300
                : AppThemeData.grey700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "This restaurant doesn't have any items in their menu right now.".tr,
          style: TextStyle(
            fontSize: 14,
            color: themeChange.getThem()
                ? AppThemeData.grey400
                : AppThemeData.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}


// Menu Item Widget
Widget _buildMenuItem(String title, int count, {bool isNew = false}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.grey[900],
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8), // Small fixed spacing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          // decoration: BoxDecoration(
          //   color: Colors.grey[700],
          //   borderRadius: BorderRadius.circular(12),
          // ),
          child: Text(
            '$count items',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

