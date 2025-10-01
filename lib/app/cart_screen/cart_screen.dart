import 'package:bottom_picker/bottom_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/cart_screen/coupon_list_screen.dart';
import 'package:customer/app/cart_screen/select_payment_screen.dart';
import 'package:customer/app/restaurant_details_screen/restaurant_details_screen.dart';
import 'package:customer/app/wallet_screen/wallet_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/controllers/mart_navigation_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/payment/createRazorPayOrderModel.dart';
import 'package:customer/payment/rozorpayConroller.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/themes/text_field_widget.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/mart_zone_utils.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/widget/my_separator.dart';
import 'package:customer/widget/special_price_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;
import 'package:customer/models/coupon_model.dart';

// Cart theme enum for different color schemes
enum CartTheme {
  food,   // Default food app theme
  mart,   // Green mart theme
  mixed   // Mixed cart theme
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

class CartScreen extends StatefulWidget {
  final bool hideBackButton;
  final String? source; // 'food' or 'mart' or null for auto-detect
  final bool isFromMartNavigation; // true if accessed from mart navigation tabs
  
  const CartScreen({Key? key, this.hideBackButton = false, this.source, this.isFromMartNavigation = false}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartController controller;

  @override
  void initState() {
    super.initState();
    print('🚀 DEBUG: CartScreen initState() called - Initializing CartController...');
    controller = Get.put(CartController());
    print('✅ DEBUG: CartController initialized successfully');
    // Force refresh cart data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartData();
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh cart data when dependencies change (navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshCartData();
    });
  }
  
  @override
  void dispose() {
    // Clean up any resources
    super.dispose();
  }
  
  void _refreshCartData() {
    print('DEBUG: Refreshing cart data...');
    // Use the enhanced force refresh method
    controller.forceRefreshCart();
    
    // **FIXED: Re-initialize address if not selected (for global cart controller)**
    if (controller.selectedAddress.value == null) {
      print('🏠 [CART_REFRESH] No address selected, re-initializing address...');
      // Trigger address initialization by calling the public method
      controller.initializeAddress();
    }
    
    // Ensure payment method is set correctly based on order total
    Future.delayed(const Duration(milliseconds: 500), () {
      controller.checkAndUpdatePaymentMethod();
      print('DEBUG: Cart refresh completed - Items: ${cartItem.length}, Total: ${controller.totalAmount.value}');
    });
  }

  // Get theme colors based on cart theme
  CartThemeColors _getThemeColors(CartTheme theme) {
    switch (theme) {
      case CartTheme.mart:
        return CartThemeColors(
          primary: MartTheme.jippyMartButton,
          primaryDark: const Color(0xFF005A52),
          accent: const Color(0xFF00A896),
          surface: Colors.white,
          onSurface: Colors.black87,
        );
      case CartTheme.food:
        return CartThemeColors(
          primary: const Color(0xFFFF6B35),
          primaryDark: const Color(0xFFE55A2B),
          accent: const Color(0xFFFF8A65),
          surface: AppThemeData.surface,
          onSurface: Colors.black87,
        );
      case CartTheme.mixed:
        return CartThemeColors(
          primary: const Color(0xFF607D8B),
          primaryDark: const Color(0xFF455A64),
          accent: const Color(0xFF78909C),
          surface: AppThemeData.surface,
          onSurface: Colors.black87,
        );
    }
  }

  // Determine cart theme based on source and content
  CartTheme _getCartTheme() {
    // If source is explicitly provided, use it
    if (widget.source != null) {
      if (widget.source == 'mart') {
        return CartTheme.mart;
      } else if (widget.source == 'food') {
        return CartTheme.food;
      }
    }
    
    // Auto-detect based on cart content
    bool hasMartItems = cartItem.any((item) => 
        item.vendorID?.contains('mart') == true || 
        item.vendorID?.startsWith('demo_') == true ||
        item.vendorID?.contains('vendor') == true);
    
    bool hasFoodItems = cartItem.any((item) => 
        !(item.vendorID?.contains('mart') == true || 
          item.vendorID?.startsWith('demo_') == true ||
          item.vendorID?.contains('vendor') == true));
    
    if (hasMartItems && !hasFoodItems) {
      return CartTheme.mart;
    } else if (hasFoodItems && !hasMartItems) {
      return CartTheme.food;
    } else {
      return CartTheme.mixed; // Both food and mart items
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final cartTheme = _getCartTheme();
    final themeColors = _getThemeColors(cartTheme);
    
    return GetX<CartController>(
        builder: (controller) {
          // Check payment method every time the UI is built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.checkAndUpdatePaymentMethod();
          });
          
          return Scaffold(
            backgroundColor: themeChange.getThem()
                ? AppThemeData.surfaceDark
                : themeColors.surface,
            appBar: AppBar(
              backgroundColor: themeChange.getThem()
                  ? AppThemeData.surfaceDark
                  : themeColors.primary,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: !widget.hideBackButton,
              leading: widget.hideBackButton ? null : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  // Check if we're in mart navigation system (cart tab)
                  if (widget.source == 'mart' && widget.isFromMartNavigation) {
                    // If accessed from mart navigation cart tab, go back to mart home
                    try {
                      final martNavController = Get.find<MartNavigationController>();
                      martNavController.goToHome();
                    } catch (e) {
                      // Fallback to regular back navigation
                      Get.back();
                    }
                  } else {
                    // Regular back navigation for other cases (product details, etc.)
                    Get.back();
                  }
                },
              ),
              title: Text(
                cartTheme == CartTheme.mart ? 'Mart Cart' : 'Cart',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              actions: [
                // Debug buttons removed - methods not available in current version
              ],
            ),
            body: cartItem.isEmpty
                ? Constant.showEmptyView(message: "Item Not available".tr)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        controller.selectedFoodType.value == 'TakeAway'
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(const AddressListScreen())!.then(
                                      (value) async {
                                        if (value != null) {
                                          ShippingAddress addressModel = value;
                                          
                                          // 🔑 ZONE DETECTION: Use the same zone system as restaurants
                                          if (addressModel.location?.latitude != null && 
                                              addressModel.location?.longitude != null) {
                                            try {
                                              print('🔍 [CART_ADDRESS_CHANGE] Using restaurant zone system for consistency...');
                                              
                                              // Use the same zone as restaurants (Constant.selectedZone)
                                              if (Constant.selectedZone != null) {
                                                addressModel.zoneId = Constant.selectedZone!.id;
                                                print('✅ [CART_ADDRESS_CHANGE] Using restaurant zone: ${Constant.selectedZone!.name} (${Constant.selectedZone!.id})');
                                              } else {
                                                // Fallback to mart zone detection if restaurant zone not available
                                                print('⚠️ [CART_ADDRESS_CHANGE] No restaurant zone available, trying mart zone detection...');
                                                final zoneId = await MartZoneUtils.getZoneIdForCoordinates(
                                                  addressModel.location!.latitude!,
                                                  addressModel.location!.longitude!,
                                                );
                                                
                                                if (zoneId.isNotEmpty) {
                                                  addressModel.zoneId = zoneId;
                                                  print('✅ [CART_ADDRESS_CHANGE] Mart zone detected: $zoneId');
                                                } else {
                                                  print('⚠️ [CART_ADDRESS_CHANGE] No zone detected for coordinates - leaving zoneId as null');
                                                }
                                              }
                                            } catch (e) {
                                              print('❌ [CART_ADDRESS_CHANGE] Error detecting zone: $e');
                                              // Continue without zone ID if detection fails
                                            }
                                          } else {
                                            print('⚠️ [CART_ADDRESS_CHANGE] No coordinates available for zone detection');
                                          }
                                          
                                          controller.selectedAddress.value = addressModel;
                                          controller.calculatePrice();
                                        }
                                      },
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_send_one.svg"),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      controller.selectedAddress
                                                          .value?.addressAs
                                                          ?.toString() ?? "No Address Selected",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .semiBold,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData
                                                                .primary300
                                                            : AppThemeData
                                                                .primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  SvgPicture.asset(
                                                      "assets/icons/ic_down.svg"),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                controller.selectedAddress.value
                                                    ?.getFullAddress() ?? "Please select a delivery address",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily:
                                                      AppThemeData.medium,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey400
                                                      : AppThemeData.grey500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem()
                                  ? AppThemeData.grey900
                                  : AppThemeData.grey50,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: cartItem.length,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  CartProductModel cartProductModel =
                                      cartItem[index];
                                  ProductModel? productModel;
                                  // Load product model asynchronously but ensure it's available for increment logic
                                  FireStoreUtils.getProductById(
                                          cartProductModel.id!.split('~').first)
                                      .then((value) {
                                    productModel = value;
                                  });
                                  dev.log('cartItem[index] :: ${cartProductModel.extras} ::${cartProductModel.extrasPrice}');
                                  Widget priceWidget;
                                  if (cartProductModel.promoId != null && cartProductModel.promoId!.isNotEmpty) {
                                    priceWidget = Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Offer -',
                                            style: TextStyle(
                                              color: Color(0xFFFFD700), // gold
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          Constant.amountShow(amount: cartProductModel.price),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                            fontFamily: AppThemeData.semiBold,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        if (cartProductModel.discountPrice != null &&
                                            double.tryParse(cartProductModel.discountPrice!) != null &&
                                            double.parse(cartProductModel.discountPrice!) > 0)
                                          Text(
                                            Constant.amountShow(amount: cartProductModel.discountPrice),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    );
                                  } else if (double.parse(cartProductModel.discountPrice.toString()) <= 0) {
                                    priceWidget = Text(
                                      Constant.amountShow(amount: cartProductModel.price),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                        fontFamily: AppThemeData.semiBold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  } else {
                                    priceWidget = Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            Constant.amountShow(amount: cartProductModel.discountPrice.toString()),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            Constant.amountShow(amount: cartProductModel.price),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              fontFamily: AppThemeData.semiBold,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return InkWell(
                                    onTap: () async {
                                      await FireStoreUtils.getVendorById(
                                              productModel!.vendorID.toString())
                                          .then(
                                        (value) {
                                          if (value != null) {
                                            Get.to(
                                                const RestaurantDetailsScreen(),
                                                arguments: {
                                                  "vendorModel": value
                                                });
                                          }
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          LayoutBuilder(
                                            builder: (context, constraints) {
                                              return IntrinsicHeight(
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                                    Flexible(
                                                      flex: 2,
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                                                        child: Stack(
                                                          children: [
                                                            NetworkImageWidget(
                                                              imageUrl: cartProductModel.photo.toString(),
                                                              height: Responsive.height(10, context),
                                                              width: Responsive.width(16, context),
                                                              fit: BoxFit.cover,
                                                            ),
                                                            // Promotional banner overlay
                                                            if (cartProductModel.promoId != null && cartProductModel.promoId!.isNotEmpty)
                                                              Positioned(
                                                                top: 0,
                                                                left: 0,
                                                                child: const SpecialPriceBadge(
                                                                  showShimmer: true,
                                                                  width: 50,
                                                                  height: 50,
                                                                  margin: EdgeInsets.zero,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      flex: 5,
                                                child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${cartProductModel.name}",
                                                            textAlign: TextAlign.start,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                              fontFamily: AppThemeData.regular,
                                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    // Check if this is a promotional item and show banner
                                                    cartProductModel.promoId != null && cartProductModel.promoId!.isNotEmpty
                                                        ? Padding(
                                                            padding: const EdgeInsets.only(top: 4),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  margin: const EdgeInsets.only(right: 6),
                                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    borderRadius: BorderRadius.circular(4),
                                                                  ),
                                                                  child: Text(
                                                                    'Offer',
                                                                    style: TextStyle(
                                                                      color: Color(0xFFFFD700), // gold
                                                                      fontWeight: FontWeight.bold,
                                                                      fontSize: 10,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : const SizedBox.shrink(),
                                                    // Check if this is a promotional item
                                                    cartProductModel.promoId != null && cartProductModel.promoId!.isNotEmpty
                                                        ? Row(
                                                            children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        Constant.amountShow(amount: cartProductModel.price),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                  fontSize: 16,
                                                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                          fontFamily: AppThemeData.semiBold,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                ),
                                                              ),
                                                                    const SizedBox(width: 5),
                                                                    Flexible(
                                                                      child: Text(
                                                                        Constant.amountShow(amount: cartProductModel.discountPrice.toString()),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                  fontSize: 14,
                                                                          decoration: TextDecoration.lineThrough,
                                                                          decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                          color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                          fontFamily: AppThemeData.semiBold,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : double.parse(cartProductModel.discountPrice.toString()) <= 0
                                                        ? Text(
                                                                  Constant.amountShow(amount: cartProductModel.price),
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                    fontFamily: AppThemeData.semiBold,
                                                                    fontWeight: FontWeight.w600,
                                                            ),
                                                          )
                                                        : Row(
                                                            children: [
                                                                    Flexible(
                                                                      child: Text(
                                                                        Constant.amountShow(amount: cartProductModel.discountPrice.toString()),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                  fontSize: 16,
                                                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                          fontFamily: AppThemeData.semiBold,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                ),
                                                              ),
                                                                    const SizedBox(width: 5),
                                                                    Flexible(
                                                                      child: Text(
                                                                        Constant.amountShow(amount: cartProductModel.price),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        style: TextStyle(
                                                                  fontSize: 14,
                                                                          decoration: TextDecoration.lineThrough,
                                                                          decorationColor: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                          color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                                          fontFamily: AppThemeData.semiBold,
                                                                          fontWeight: FontWeight.w600,
                                                                        ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ],
                                                ),
                                              ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      flex: 3,
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(maxWidth: 90),
                                                        child: Container(
                                                decoration: ShapeDecoration(
                                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                  shape: RoundedRectangleBorder(
                                                              side: const BorderSide(width: 1, color: Color(0xFFD1D5DB)),
                                                              borderRadius: BorderRadius.circular(200),
                                                  ),
                                                ),
                                                child: Padding(
                                                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                                            child: SingleChildScrollView(
                                                              scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      InkWell(
                                                          onTap: () async {
                                                            controller.addToCart(
                                                                        cartProductModel: cartProductModel,
                                                                        isIncrement: false,
                                                                        quantity: cartProductModel.quantity! - 1,
                                                                      );
                                                          },
                                                                    child: const Icon(Icons.remove),
                                                                  ),
                                                      Padding(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        child: Text(
                                                                      cartProductModel.quantity.toString(),
                                                                      textAlign: TextAlign.start,
                                                          maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                                        fontFamily: AppThemeData.medium,
                                                                        fontWeight: FontWeight.w500,
                                                                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                          ),
                                                        ),
                                                      ),
                                                      InkWell(
                                                          onTap: () async {
                                                            // Ensure productModel is loaded before proceeding
                                                            if (productModel == null) {
                                                              productModel = await FireStoreUtils.getProductById(
                                                                  cartProductModel.id!.split('~').first);
                                                            }
                                                            
                                                            // Check if this is a promotional item
                                                            if (cartProductModel.promoId != null && cartProductModel.promoId!.isNotEmpty) {
                                                              final isAllowed = await controller.isPromotionalItemQuantityAllowed(
                                                                cartProductModel.id ?? '',
                                                                cartProductModel.vendorID ?? '',
                                                                cartProductModel.quantity! + 1
                                                              );
                                                              
                                                              if (!isAllowed) {
                                                                final limit = await controller.getPromotionalItemLimit(
                                                                  cartProductModel.id ?? '',
                                                                  cartProductModel.vendorID ?? ''
                                                                );
                                                                ShowToastDialog.showToast("Maximum $limit items allowed for this promotional offer".tr);
                                                                return;
                                                              }
                                                            }
                                                            
                                                            if (productModel != null && productModel!
                                                                    .itemAttribute !=
                                                                null) {
                                                              if (productModel!
                                                                  .itemAttribute!
                                                                  .variants!
                                                                  .where((element) =>
                                                                      element
                                                                          .variantSku ==
                                                                      cartProductModel
                                                                          .variantInfo!
                                                                          .variantSku)
                                                                  .isNotEmpty) {
                                                                if (int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel
                                                                                    .variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) >=
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    int.parse(productModel!
                                                                            .itemAttribute!
                                                                            .variants!
                                                                            .where((element) =>
                                                                                element.variantSku ==
                                                                                cartProductModel.variantInfo!.variantSku)
                                                                            .first
                                                                            .variantQuantity
                                                                            .toString()) ==
                                                                        -1) {
                                                                  await controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock"
                                                                              .tr);
                                                                }
                                                              } 
                                                              else {
                                                                if ((productModel!.quantity ??
                                                                            0) >
                                                                        (cartProductModel.quantity ??
                                                                            0) ||
                                                                    productModel!
                                                                            .quantity ==
                                                                        -1) {
                                                                  await controller.addToCart(
                                                                      cartProductModel:
                                                                          cartProductModel,
                                                                      isIncrement:
                                                                          true,
                                                                      quantity:
                                                                          cartProductModel.quantity! +
                                                                              1);
                                                                } else {
                                                                  ShowToastDialog
                                                                      .showToast(
                                                                          "Out of stock"
                                                                              .tr);
                                                                }
                                                              }
                                                            } else if (productModel != null) {
                                                              if ((productModel!
                                                                              .quantity ??
                                                                          0) >
                                                                      (cartProductModel
                                                                              .quantity ??
                                                                          0) ||
                                                                  productModel!
                                                                          .quantity ==
                                                                      -1) {
                                                                await controller.addToCart(
                                                                    cartProductModel:
                                                                        cartProductModel,
                                                                    isIncrement:
                                                                        true,
                                                                    quantity:
                                                                        cartProductModel.quantity! +
                                                                            1);
                                                              } else {
                                                                ShowToastDialog
                                                                    .showToast(
                                                                        "Out of stock"
                                                                            .tr);
                                                              }
                                                            } else {
                                                              // Fallback: if productModel is null, allow increment for mart items
                                                              await controller.addToCart(
                                                                  cartProductModel: cartProductModel,
                                                                  isIncrement: true,
                                                                  quantity: cartProductModel.quantity! + 1);
                                                            }
                                                          },
                                                                    child: const Icon(Icons.add),
                                                                  ),
                                                      const SizedBox(width: 8),
                                                    ],
                                                  ),
                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                            ],
                                                ),
                                              );
                                            },
                                          ),
                                          cartProductModel.variantInfo ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                          .variantOptions ==
                                                      null ||
                                                  cartProductModel.variantInfo!
                                                      .variantOptions!.isEmpty
                                              ? Container()
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Variants".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .semiBold,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Wrap(
                                                        spacing: 6.0,
                                                        runSpacing: 6.0,
                                                        children: List.generate(
                                                          cartProductModel
                                                              .variantInfo!
                                                              .variantOptions!
                                                              .length,
                                                          (i) {
                                                            return Container(
                                                              decoration:
                                                                  ShapeDecoration(
                                                                color: themeChange.getThem()
                                                                    ? AppThemeData
                                                                        .grey800
                                                                    : AppThemeData
                                                                        .grey100,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        5),
                                                                child: Text(
                                                                  "${cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)} : ${cartProductModel.variantInfo!.variantOptions![cartProductModel.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        AppThemeData
                                                                            .medium,
                                                                    color: themeChange.getThem()
                                                                        ? AppThemeData
                                                                            .grey500
                                                                        : AppThemeData
                                                                            .grey400,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ).toList(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          cartProductModel.extras == null ||
                                                  cartProductModel
                                                      .extras!.isEmpty ||
                                                  cartProductModel
                                                          .extrasPrice ==
                                                      '0'
                                              ? const SizedBox()
                                              : Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            "Addons".tr,
                                                            textAlign:
                                                                TextAlign.start,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .semiBold,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey300
                                                                  : AppThemeData
                                                                      .grey600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          Constant.amountShow(
                                                              amount: (double.parse(cartProductModel
                                                                          .extrasPrice
                                                                          .toString()) *
                                                                      double.parse(cartProductModel
                                                                          .quantity
                                                                          .toString()))
                                                                  .toString()),
                                                          textAlign:
                                                              TextAlign.start,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AppThemeData
                                                                    .semiBold,
                                                            color: themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .primary300
                                                                : AppThemeData
                                                                    .primary300,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Wrap(
                                                      spacing: 6.0,
                                                      runSpacing: 6.0,
                                                      children: List.generate(
                                                        cartProductModel
                                                            .extras!.length,
                                                        (i) {
                                                          return Container(
                                                            decoration:
                                                                ShapeDecoration(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8)),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          5),
                                                              child: Text(
                                                                cartProductModel
                                                                    .extras![i]
                                                                    .toString(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .grey500
                                                                      : AppThemeData
                                                                          .grey400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ).toList(),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Visibility(
                          visible: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${'Delivery Type'.tr} (${controller.selectedFoodType.value})"
                                      .tr,
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontFamily: AppThemeData.semiBold,
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey50
                                        : AppThemeData.grey900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                controller.selectedFoodType.value == 'TakeAway'
                                    ? const SizedBox()
                                    : Container(
                                        width: Responsive.width(100, context),
                                        decoration: ShapeDecoration(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey900
                                              : AppThemeData.grey50,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Instant Delivery".tr,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppThemeData.medium,
                                                        color:
                                                            themeChange.getThem()
                                                                ? AppThemeData
                                                                    .primary300
                                                                : AppThemeData
                                                                    .primary300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                      "Standard".tr,
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AppThemeData.medium,
                                                        fontSize: 12,
                                                        color: themeChange
                                                                .getThem()
                                                            ? AppThemeData.grey400
                                                            : AppThemeData
                                                                .grey500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Radio(
                                                value:
                                                    controller.deliveryType.value,
                                                groupValue: "instant".tr,
                                                activeColor:
                                                    AppThemeData.primary300,
                                                onChanged: (value) {
                                                  controller.deliveryType.value =
                                                      "instant".tr;
                                                },
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Offstage(
                                    offstage: true,
                                    child: InkWell(
                                      onTap: () {
                                        controller.deliveryType.value =
                                            "schedule".tr;
                                        BottomPicker.dateTime(
                                          onSubmit: (index) {
                                            controller.scheduleDateTime.value =
                                                index;
                                          },
                                          minDateTime: DateTime.now(),
                                          displaySubmitButton: true,
                                          pickerTitle: Text('Schedule Time'.tr),
                                          buttonSingleColor:
                                              AppThemeData.primary300,
                                        ).show(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Schedule Time".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color: themeChange.getThem()
                                                          ? AppThemeData.primary300
                                                          : AppThemeData.primary300,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "${'Your preferred time'.tr} ${controller.deliveryType.value == "schedule" ? Constant.timestampToDateTime(Timestamp.fromDate(controller.scheduleDateTime.value)) : ""}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      fontSize: 12,
                                                      color: themeChange.getThem()
                                                          ? AppThemeData.grey400
                                                          : AppThemeData.grey500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Radio(
                                              value: controller.deliveryType.value,
                                              groupValue: "schedule".tr,
                                              activeColor: AppThemeData.primary300,
                                              onChanged: (value) {
                                                controller.deliveryType.value =
                                                    "schedule".tr;
                                                BottomPicker.dateTime(
                                                  initialDateTime: controller
                                                      .scheduleDateTime.value,
                                                  onSubmit: (index) {
                                                    controller.scheduleDateTime
                                                        .value = index;
                                                  },
                                                  minDateTime: controller
                                                      .scheduleDateTime.value,
                                                  displaySubmitButton: true,
                                                  pickerTitle:
                                                      Text('Schedule Time'.tr),
                                                  buttonSingleColor:
                                                      AppThemeData.primary300,
                                                ).show(context);
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Offers & Benefits".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  // Show loading indicator while fetching coupons
                                  ShowToastDialog.showLoader("Loading coupons...");
                                  await controller.getCartData();
                                  ShowToastDialog.closeLoader();
                                  Get.to(const CouponListScreen());
                                },
                                child: Container(
                                  width: Responsive.width(100, context),
                                  decoration: ShapeDecoration(
                                    color: themeChange.getThem()
                                        ? AppThemeData.grey900
                                        : AppThemeData.grey50,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x14000000),
                                        blurRadius: 52,
                                        offset: Offset(0, 0),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Apply Coupons".tr,
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
                                        const Icon(Icons.keyboard_arrow_right)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Bill Details".tr,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey50
                                      : AppThemeData.grey900,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: Responsive.width(100, context),
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem()
                                      ? AppThemeData.grey900
                                      : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x14000000),
                                      blurRadius: 52,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 14),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Item totals".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount: controller
                                                    .subTotal.value
                                                    .toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
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
                                      controller.selectedFoodType.value ==
                                              'TakeAway'
                                          ? const SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Delivery Fee".tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.regular,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                                                                                 // Check if cart has promotional items or mart items
                                                 Obx(() {
                                                   final hasPromotionalItems = controller.hasPromotionalItems();
                                                   final hasMartItems = controller.hasMartItemsInCart();
                                                  
                                                  // Self delivery check
                                                  if (controller.vendorModel.value.isSelfDelivery == true &&
                                                      Constant.isSelfDeliveryFeature == true) {
                                                    return Text(
                                                      'Free Delivery',
                                                      textAlign: TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData.regular,
                                                        color: AppThemeData.success400,
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  }
                                                  
                                                  // Promotional items delivery logic
                                                  if (hasPromotionalItems) {
                                                    // For promotional items, always show "Free Delivery" UI with strikethrough ₹23
                                                    // because promotional items are eligible for free delivery base
                                                    return _buildDeliveryFeeUI(
                                                      isFreeDelivery: true, // Always true for promotional items to show "Free Delivery"
                                                      originalFee: 23.0,
                                                      currentFee: controller.deliveryCharges.value,
                                                      themeChange: themeChange,
                                                    );
                                                  }
                                                  
                                                  // Mart items delivery logic - Check free delivery eligibility
                                                  if (hasMartItems) {
                                                    print('[CART_UI] 🛒 Building mart delivery UI...');
                                                    print('[CART_UI]   - Subtotal: ₹${controller.subTotal.value}');
                                                    print('[CART_UI]   - Distance: ${controller.totalDistance.value} km');
                                                    print('[CART_UI]   - Delivery charges: ₹${controller.deliveryCharges.value}');
                                                    print('[CART_UI]   - Original delivery fee: ₹${controller.originalDeliveryFee.value}');
                                                    
                                                    // For mart items, use the same logic as restaurant items
                                                    // Get mart delivery settings (static values like restaurant)
                                                    double itemThreshold = 199.0; // Default mart threshold
                                                    double freeDeliveryKm = 5.0; // Default mart free distance
                                                    double baseDeliveryCharge = 23.0; // Static base charge
                                                    
                                                    final subtotal = controller.subTotal.value;
                                                    final distance = controller.totalDistance.value;
                                                    
                                                    print('[CART_UI]   - Mart threshold: ₹$itemThreshold');
                                                    print('[CART_UI]   - Mart free distance: ${freeDeliveryKm} km');
                                                    print('[CART_UI]   - Base delivery charge: ₹$baseDeliveryCharge');
                                                    
                                                    // Determine delivery eligibility and charges (same logic as restaurant)
                                                    final isAboveThreshold = subtotal >= itemThreshold;
                                                    final isWithinFreeDistance = distance <= freeDeliveryKm;
                                                    
                                                    print('[CART_UI]   - Is above threshold: $isAboveThreshold');
                                                    print('[CART_UI]   - Is within free distance: $isWithinFreeDistance');
                                                    
                                                    if (isAboveThreshold) {
                                                      // Above threshold - eligible for free delivery logic
                                                      if (isWithinFreeDistance) {
                                                        // Standard free delivery: Green "Free Delivery" + strikethrough base charge + ₹0.00
                                                        print('[CART_UI]   - Mart standard free delivery');
                                                        return _buildDeliveryFeeUI(
                                                          isFreeDelivery: true,
                                                          originalFee: baseDeliveryCharge,
                                                          currentFee: 0.0,
                                                          themeChange: themeChange,
                                                        );
                                                      } else {
                                                        // Free delivery with extra charge: Green "Free Delivery" + strikethrough base charge + extra charge
                                                        print('[CART_UI]   - Mart free delivery with extra charge');
                                                        return _buildDeliveryFeeUI(
                                                          isFreeDelivery: true,
                                                          originalFee: baseDeliveryCharge,
                                                          currentFee: controller.deliveryCharges.value,
                                                          themeChange: themeChange,
                                                        );
                                                      }
                                                    } else {
                                                      // Below threshold - regular paid delivery
                                                      print('[CART_UI]   - Mart regular paid delivery');
                                                      return _buildDeliveryFeeUI(
                                                        isFreeDelivery: false,
                                                        originalFee: 0.0,
                                                        currentFee: controller.deliveryCharges.value,
                                                        themeChange: themeChange,
                                                      );
                                                    }
                                                  }
                                                  
                                                  // Regular items delivery logic
                                                  final threshold = controller.deliveryChargeModel.value.itemTotalThreshold ?? 299;
                                                  final freeKm = controller.deliveryChargeModel.value.freeDeliveryDistanceKm ?? 7;
                                                  final subtotal = controller.subTotal.value;
                                                  final distance = controller.totalDistance.value;
                                                  
                                                  print('[CART_UI] 🍽️ Building regular delivery UI...');
                                                  print('[CART_UI]   - Subtotal: ₹$subtotal');
                                                  print('[CART_UI]   - Threshold: ₹$threshold');
                                                  print('[CART_UI]   - Distance: ${distance} km');
                                                  print('[CART_UI]   - Free distance: ${freeKm} km');
                                                  print('[CART_UI]   - Delivery charges: ₹${controller.deliveryCharges.value}');
                                                  print('[CART_UI]   - Original delivery fee: ₹${controller.originalDeliveryFee.value}');
                                                  
                                                  // Determine delivery eligibility and charges
                                                  final isAboveThreshold = subtotal >= threshold;
                                                  final isWithinFreeDistance = distance <= freeKm;
                                                  final isEligibleForFreeDelivery = isAboveThreshold && isWithinFreeDistance;
                                                  
                                                  print('[CART_UI]   - Is above threshold: $isAboveThreshold');
                                                  print('[CART_UI]   - Is within free distance: $isWithinFreeDistance');
                                                  print('[CART_UI]   - Is eligible for free delivery: $isEligibleForFreeDelivery');
                                                  
                                                  // Get the base delivery charge for restaurant items (should be ₹23)
                                                  double baseDeliveryCharge = (controller.deliveryChargeModel.value.baseDeliveryCharge ?? 23.0).toDouble();
                                                  print('[CART_UI]   - Base delivery charge: ₹$baseDeliveryCharge');
                                                  
                                                  if (isAboveThreshold) {
                                                    // Above threshold - eligible for free delivery logic
                                                    if (isWithinFreeDistance) {
                                                      // Standard free delivery: Green "Free Delivery" + strikethrough base charge + ₹0.00
                                                      print('[CART_UI]   - Standard free delivery');
                                                      return _buildDeliveryFeeUI(
                                                        isFreeDelivery: true,
                                                        originalFee: baseDeliveryCharge, // Show base charge, not calculated total
                                                        currentFee: 0.0,
                                                        themeChange: themeChange,
                                                      );
                                                    } else {
                                                      // Free delivery with extra charge: Green "Free Delivery" + strikethrough base charge + extra charge
                                                      print('[CART_UI]   - Free delivery with extra charge');
                                                      return _buildDeliveryFeeUI(
                                                        isFreeDelivery: true,
                                                        originalFee: baseDeliveryCharge, // Show base charge, not calculated total
                                                        currentFee: controller.deliveryCharges.value,
                                                        themeChange: themeChange,
                                                      );
                                                    }
                                                  } else {
                                                    // Below threshold - regular paid delivery
                                                    print('[CART_UI]   - Regular paid delivery');
                                                    return _buildDeliveryFeeUI(
                                                      isFreeDelivery: false,
                                                      originalFee: 0.0,
                                                      currentFee: controller.deliveryCharges.value,
                                                      themeChange: themeChange,
                                                    );
                                                  }
                                                }),
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
                                              "Platform Fee".tr,
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
                                            '15.00',
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: AppThemeData.danger300,
                                              fontSize: 16,
                                              decoration: TextDecoration.lineThrough,
                                              decorationColor: AppThemeData.danger300,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Coupon Discount".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "- (" + Constant.amountShow(amount: controller.couponAmount.value.toString()) + ")",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.regular,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.danger300
                                                      : AppThemeData.danger300,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              controller.selectedCouponModel.value.id != null && controller.selectedCouponModel.value.id!.isNotEmpty
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(left: 8.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          controller.selectedCouponModel.value = CouponModel();
                                                          controller.couponCodeController.value.text = '';
                                                          controller.couponAmount.value = 0.0;
                                                          controller.calculatePrice();
                                                        },
                                                        child: Text(
                                                          "Remove",
                                                          style: TextStyle(
                                                            color: AppThemeData.danger300,
                                                            fontFamily: AppThemeData.medium,
                                                            fontSize: 14,
                                                            decoration: TextDecoration.underline,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox.shrink(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      controller.specialDiscountAmount.value > 0
                                          ? Column(
                                              children: [
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        "Special Discount".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "- (${Constant.amountShow(amount: controller.specialDiscountAmount.value.toString())})",
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontFamily: AppThemeData
                                                            .regular,
                                                        color:
                                                            themeChange
                                                                    .getThem()
                                                                ? AppThemeData
                                                                    .danger300
                                                                : AppThemeData
                                                                    .danger300,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : const SizedBox(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      controller.selectedFoodType.value ==
                                                  'TakeAway' ||
                                              (controller.vendorModel.value
                                                          .isSelfDelivery ==
                                                      true &&
                                                  Constant.isSelfDeliveryFeature ==
                                                      true)
                                          ? const SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Delivery Tips".tr,
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AppThemeData
                                                                  .regular,
                                                          color: themeChange
                                                                  .getThem()
                                                              ? AppThemeData
                                                                  .grey300
                                                              : AppThemeData
                                                                  .grey600,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      controller.deliveryTips
                                                                  .value ==
                                                              0
                                                          ? const SizedBox()
                                                          : InkWell(
                                                              onTap: () {
                                                                controller
                                                                    .deliveryTips
                                                                    .value = 0;
                                                                controller
                                                                    .calculatePrice();
                                                              },
                                                              child: Text(
                                                                "Remove".tr,
                                                                textAlign:
                                                                    TextAlign
                                                                        .start,
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      AppThemeData
                                                                          .medium,
                                                                  color: themeChange.getThem()
                                                                      ? AppThemeData
                                                                          .primary300
                                                                      : AppThemeData
                                                                          .primary300,
                                                                ),
                                                              ),
                                                            ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  Constant.amountShow(
                                                      amount: controller
                                                          .deliveryTips
                                                          .toString()),
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        AppThemeData.regular,
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
                                      MySeparator(
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey700
                                              : AppThemeData.grey200),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Taxes & Charges",
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount: controller
                                                    .taxAmount.value
                                                    .toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily:
                                                  AppThemeData.regular,
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
                                              "To Pay".tr,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.regular,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey300
                                                    : AppThemeData.grey600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            Constant.amountShow(
                                                amount: controller
                                                    .totalAmount.value
                                                    .toString()),
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontFamily: AppThemeData.regular,
                                              color: themeChange.getThem()
                                                  ? AppThemeData.grey50
                                                  : AppThemeData.grey900,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        controller.selectedFoodType.value == 'TakeAway' ||
                                (controller.vendorModel.value.isSelfDelivery ==
                                        true &&
                                    Constant.isSelfDeliveryFeature == true)
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "Thanks with a tip!".tr,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey50
                                            : AppThemeData.grey900,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Responsive.width(100, context),
                                      decoration: ShapeDecoration(
                                        color: themeChange.getThem()
                                            ? AppThemeData.grey900
                                            : AppThemeData.grey50,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        shadows: const [
                                          BoxShadow(
                                            color: Color(0x14000000),
                                            blurRadius: 52,
                                            offset: Offset(0, 0),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 14),
                                        child: Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "Around the clock, our delivery partners bring you your favorite meals. Show your appreciation with a tip."
                                                        .tr,
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AppThemeData.medium,
                                                      color: themeChange
                                                              .getThem()
                                                          ? AppThemeData.grey300
                                                          : AppThemeData
                                                              .grey600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SvgPicture.asset(
                                                    "assets/images/ic_tips.svg")
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 05;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      05
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "05"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 10;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      10
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "10"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.deliveryTips
                                                          .value = 15;
                                                      controller
                                                          .calculatePrice();
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: controller
                                                                          .deliveryTips
                                                                          .value ==
                                                                      15
                                                                  ? AppThemeData
                                                                      .primary300
                                                                  : themeChange
                                                                          .getThem()
                                                                      ? AppThemeData
                                                                          .grey800
                                                                      : AppThemeData
                                                                          .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            Constant.amountShow(
                                                                amount: "15"),
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return tipsDialog(
                                                              controller,
                                                              themeChange);
                                                        },
                                                      );
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          ShapeDecoration(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          side: BorderSide(
                                                              width: 1,
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey800
                                                                  : AppThemeData
                                                                      .grey100),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        child: Center(
                                                          child: Text(
                                                            'Other'.tr,
                                                            style: TextStyle(
                                                              color: themeChange
                                                                      .getThem()
                                                                  ? AppThemeData
                                                                      .grey50
                                                                  : AppThemeData
                                                                      .grey900,
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  AppThemeData
                                                                      .medium,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextFieldWidget(
                                title: 'Remarks'.tr,
                                controller: controller.reMarkController.value,
                                hintText: 'Write remarks for the restaurant'.tr,
                                maxLine: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: cartItem.isEmpty
                ? null
                : Container(
                    decoration: BoxDecoration(
                        color: themeChange.getThem()
                            ? AppThemeData.grey900
                            : AppThemeData.grey50,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: InkWell(
                              onTap: () {
                                Get.to(const SelectPaymentScreen());
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.selectedPaymentMethod.value == ''
                                      ? cardDecoration(
                                          controller,
                                          PaymentGateway.wallet,
                                          themeChange,
                                          "")
                                      : controller.selectedPaymentMethod.value ==
                                              PaymentGateway.wallet.name
                                          ? cardDecoration(
                                              controller,
                                              PaymentGateway.wallet,
                                              themeChange,
                                              "assets/images/ic_wallet.png")
                                          : controller.selectedPaymentMethod.value ==
                                                  PaymentGateway.cod.name
                                              ? cardDecoration(
                                                  controller,
                                                  PaymentGateway.cod,
                                                  themeChange,
                                                  "assets/images/ic_cash.png")
                                              : controller.selectedPaymentMethod
                                                          .value ==
                                                      PaymentGateway.stripe.name
                                                  ? cardDecoration(
                                                      controller,
                                                      PaymentGateway.stripe,
                                                      themeChange,
                                                      "assets/images/stripe.png")
                                                  : controller.selectedPaymentMethod
                                                              .value ==
                                                          PaymentGateway
                                                              .paypal.name
                                                      ? cardDecoration(
                                                          controller,
                                                          PaymentGateway.paypal,
                                                          themeChange,
                                                          "assets/images/paypal.png")
                                                      : controller.selectedPaymentMethod
                                                                  .value ==
                                                              PaymentGateway
                                                                  .payStack.name
                                                          ? cardDecoration(
                                                              controller,
                                                              PaymentGateway
                                                                  .payStack,
                                                              themeChange,
                                                              "assets/images/paystack.png")
                                                          : controller.selectedPaymentMethod
                                                                      .value ==
                                                                  PaymentGateway
                                                                      .mercadoPago
                                                                      .name
                                                              ? cardDecoration(
                                                                  controller,
                                                                  PaymentGateway
                                                                      .mercadoPago,
                                                                  themeChange,
                                                                  "assets/images/mercado-pago.png")
                                                              : controller.selectedPaymentMethod.value ==
                                                                      PaymentGateway.flutterWave
                                                                          .name
                                                                  ? cardDecoration(
                                                                      controller,
                                                                      PaymentGateway
                                                                          .flutterWave,
                                                                      themeChange,
                                                                      "assets/images/flutterwave_logo.png")
                                                                  : controller.selectedPaymentMethod.value ==
                                                                          PaymentGateway.payFast.name
                                                                      ? cardDecoration(controller, PaymentGateway.payFast, themeChange, "assets/images/payfast.png")
                                                                      : controller.selectedPaymentMethod.value == PaymentGateway.paytm.name
                                                                          ? cardDecoration(controller, PaymentGateway.paytm, themeChange, "assets/images/paytm.png")
                                                                          : controller.selectedPaymentMethod.value == PaymentGateway.midTrans.name
                                                                              ? cardDecoration(controller, PaymentGateway.midTrans, themeChange, "assets/images/midtrans.png")
                                                                              : controller.selectedPaymentMethod.value == PaymentGateway.orangeMoney.name
                                                                                  ? cardDecoration(controller, PaymentGateway.orangeMoney, themeChange, "assets/images/orange_money.png")
                                                                                  : controller.selectedPaymentMethod.value == PaymentGateway.xendit.name
                                                                                      ? cardDecoration(controller, PaymentGateway.xendit, themeChange, "assets/images/xendit.png")
                                                                                      : cardDecoration(controller, PaymentGateway.razorpay, themeChange, "assets/images/razorpay.png"),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pay Via".tr,
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem()
                                              ? AppThemeData.grey400
                                              : AppThemeData.grey500,
                                          fontSize: 12,
                                        ),
                                      ),
                                      controller.selectedPaymentMethod.value ==
                                              ''
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 4),
                                              child: Container(
                                                  width: 60,
                                                  height: 12,
                                                  color: themeChange.getThem()
                                                      ? AppThemeData.grey800
                                                      : AppThemeData.grey100),
                                            )
                                          : Text(
                                              controller
                                                  .selectedPaymentMethod.value,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily:
                                                    AppThemeData.semiBold,
                                                color: themeChange.getThem()
                                                    ? AppThemeData.grey50
                                                    : AppThemeData.grey900,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: RoundedButtonFill(
                              textColor: AppThemeData.surface, // Always use primary text color
                              isEnabled: true, // Always enable so user can see validation messages
                              title: controller.isProcessingOrder.value ? "Processing...".tr : "Pay Now".tr,
                              height: 5,
                              color: AppThemeData.primary300, // Always use primary color
                              fontSizes: 16,
                              onPress: () async {
                                print('DEBUG: Pay Now button pressed!');
                                print('DEBUG: Current profile valid state: ${controller.isProfileValid.value}');
                                print('DEBUG: Current user model: ${controller.userModel.value?.toJson()}');
                                
                                // TEMPORARY: Test validation method
                                print('DEBUG: Testing validateAndPlaceOrder()...');
                                final testResult = await controller.validateAndPlaceOrder();
                                print('DEBUG: validateAndPlaceOrder result: $testResult');
                                
                                // Prevent multiple rapid clicks
                                if (controller.isProcessingOrder.value) {
                                  ShowToastDialog.showToast("Please wait, order is being processed...".tr);
                                  return;
                                }
                                
                                // 🔑 BULLETPROOF VALIDATION - NEVER FAILS
                                print('💰 [PAYMENT_FLOW] ==========================================');
                                print('💰 [PAYMENT_FLOW] PAYMENT PROCESS STARTED');
                                print('💰 [PAYMENT_FLOW] Payment method: ${controller.selectedPaymentMethod.value}');
                                print('💰 [PAYMENT_FLOW] Cart items: ${cartItem.length}');
                                print('💰 [PAYMENT_FLOW] Total amount: ₹${controller.totalAmount.value}');
                                print('💰 [PAYMENT_FLOW] Starting bulletproof validation...');
                                
                                final validationStartTime = DateTime.now();
                                final canProceed = await controller.validateAndPlaceOrderBulletproof();
                                final validationDuration = DateTime.now().difference(validationStartTime);
                                
                                print('💰 [PAYMENT_FLOW] Bulletproof validation completed in ${validationDuration.inMilliseconds}ms');
                                
                                if (!canProceed) {
                                  print('💰 [PAYMENT_FLOW] ❌ VALIDATION FAILED - PAYMENT BLOCKED');
                                  print('💰 [PAYMENT_FLOW] User must complete validation before proceeding');
                                  print('💰 [PAYMENT_FLOW] ==========================================');
                                  return;
                                }
                                
                                // All validations passed - continue with existing payment logic
                                print('💰 [PAYMENT_FLOW] ✅ VALIDATION PASSED - PROCEEDING WITH PAYMENT');
                                print('💰 [PAYMENT_FLOW] Payment method: ${controller.selectedPaymentMethod.value}');
                                print('💰 [PAYMENT_FLOW] ==========================================');

                                if ((controller.couponAmount.value >= 1) &&
                                    (controller.couponAmount.value >
                                        controller.totalAmount.value)) {
                                  ShowToastDialog.showToast(
                                      "The total price must be greater than or equal to the coupon discount value for the code to apply. Please review your cart total."
                                          .tr);
                                  return;
                                }
                                if ((controller.specialDiscountAmount.value >=
                                        1) &&
                                    (controller.specialDiscountAmount.value >
                                        controller.totalAmount.value)) {
                                  ShowToastDialog.showToast(
                                      "The total price must be greater than or equal to the special discount value for the code to apply. Please review your cart total."
                                          .tr);
                                  return;
                                }
                                if (controller.selectedPaymentMethod.value ==
                                    PaymentGateway.stripe.name) {
                                  // controller.stripeMakePayment(
                                  //     amount: controller.totalAmount.value
                                  //         .toString());
                                  ShowToastDialog.showToast("Stripe payment is disabled".tr);
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.paypal.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayPal
                                  controller.paypalPaymentSheet(
                                      controller.totalAmount.value.toString(),
                                      context);
                                  
                                  /*
                                  // OLD PAYPAL VALIDATION CODE - COMMENTED OUT FOR REFERENCE
                                  // Comprehensive address validation for PayPal
                                  if (controller.selectedAddress.value == null) {
                                    ShowToastDialog.showToast("Please select a delivery address before placing your order.".tr);
                                    return;
                                  }
                                  
                                  // Check if address has required fields
                                  if (controller.selectedAddress.value!.address == null || 
                                      controller.selectedAddress.value!.address!.trim().isEmpty ||
                                      controller.selectedAddress.value!.address == 'null') {
                                    ShowToastDialog.showToast("Please select a valid delivery address with complete address details.".tr);
                                    return;
                                  }
                                  
                                  // Check if address has location coordinates
                                  if (controller.selectedAddress.value!.location == null ||
                                      controller.selectedAddress.value!.location!.latitude == null ||
                                      controller.selectedAddress.value!.location!.longitude == null) {
                                    ShowToastDialog.showToast("Please select a delivery address with valid location coordinates.".tr);
                                    return;
                                  }
                                  
                                  // Prevent order if fallback location is used
                                  if (controller.selectedAddress.value?.locality == 'Ongole, Andhra Pradesh, India') {
                                    ShowToastDialog.showToast("Please select your actual address or use current location to place order.".tr);
                                    return;
                                  }
                                  */
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.payStack.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayStack
                                  controller.payStackPayment(
                                      controller.totalAmount.value.toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.mercadoPago.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with MercadoPago
                                  controller.mercadoPagoMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.flutterWave.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with FlutterWave
                                  controller.flutterWaveInitiatePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.payFast.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with PayFast
                                  controller.payFastPayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.paytm.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Paytm
                                  controller.getPaytmCheckSum(context,
                                      amount: double.parse(controller
                                          .totalAmount.value
                                          .toString()));
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.cod.name) {
                                  controller.placeOrder();
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.wallet.name) {
                                  controller.placeOrder();
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.midTrans.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with MidTrans
                                  controller.midtransMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.orangeMoney.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Orange Money
                                  controller.orangeMakePayment(
                                      context: context,
                                      amount: controller.totalAmount.value
                                          .toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.xendit.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Xendit
                                  controller.xenditPayment(context,
                                      controller.totalAmount.value.toString());
                                } else if (controller
                                        .selectedPaymentMethod.value ==
                                    PaymentGateway.razorpay.name) {
                                  // 🔑 BULLETPROOF VALIDATION ALREADY COMPLETED - Proceed with Razorpay
                                  RazorPayController()
                                      .createOrderRazorPay(
                                          amount: double.parse(controller
                                              .totalAmount.value
                                              .toString()),
                                          razorpayModel:
                                              controller.razorPayModel.value)
                                      .then((value) {
                                    if (value == null) {
                                      Get.back();
                                      ShowToastDialog.showToast(
                                          "Something went wrong, please contact admin."
                                              .tr);
                                    } else {
                                      CreateRazorPayOrderModel result = value;
                                      controller.openCheckout(
                                          amount: controller.totalAmount.value
                                              .toString(),
                                          orderId: result.id);
                                    }
                                  });
                                  
                                  /*
                                  // OLD RAZORPAY VALIDATION CODE - COMMENTED OUT FOR REFERENCE
                                  // Comprehensive address validation for Razorpay
                                  if (controller.selectedAddress.value == null) {
                                    ShowToastDialog.showToast("Please select a delivery address before placing your order.".tr);
                                    return;
                                  }
                                  
                                  // Check if address has required fields
                                  if (controller.selectedAddress.value!.address == null || 
                                      controller.selectedAddress.value!.address!.trim().isEmpty ||
                                      controller.selectedAddress.value!.address == 'null') {
                                    ShowToastDialog.showToast("Please select a valid delivery address with complete address details.".tr);
                                    return;
                                  }
                                  
                                  // Check if address has location coordinates
                                  if (controller.selectedAddress.value!.location == null ||
                                      controller.selectedAddress.value!.location!.latitude == null ||
                                      controller.selectedAddress.value!.location!.longitude == null) {
                                    ShowToastDialog.showToast("Please select a delivery address with valid location coordinates.".tr);
                                    return;
                                  }
                                  
                                  // Prevent order if fallback location is used
                                  if (controller.selectedAddress.value?.locality == 'Ongole, Andhra Pradesh, India') {
                                    ShowToastDialog.showToast("Please select your actual address or use current location to place order.".tr);
                                    return;
                                  }
                                  
                                  // Validate mart minimum order value before proceeding with Razorpay payment
                                  try {
                                    await controller.validateMinimumOrderValue();
                                  } catch (e) {
                                    print('DEBUG: Mart minimum order validation failed for Razorpay: $e');
                                    return; // Stop the payment process
                                  }
                                  
                                  // 🔑 CRITICAL: Validate delivery zone before Razorpay payment
                                  bool validationPassed = await controller.validateOrderBeforePayment();
                                  if (!validationPassed) {
                                    print('DEBUG: Delivery zone validation failed for Razorpay - blocking payment');
                                    return; // Stop the payment process
                                  }
                                  */
                                } else {
                                  ShowToastDialog.showToast(
                                      "Please select payment method".tr);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
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

  tipsDialog(CartController controller, themeChange) {
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
                          controller.deliveryTips.value = double.parse(
                              controller.tipsController.value.text);
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

  /// Reusable method to build delivery fee UI for different order types
  /// 
  /// Parameters:
  /// - [isFreeDelivery]: Whether delivery is free or not
  /// - [originalFee]: Original delivery fee to show with strikethrough (for free delivery)
  /// - [currentFee]: Current delivery fee to display
  /// - [themeChange]: Theme controller for dark/light mode
  /// 
  /// Returns:
  /// - Row widget with appropriate delivery fee display
  Widget _buildDeliveryFeeUI({
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
    bool isFreeDeliveryWithExtraCharge = isFreeDelivery && currentFee > 0.0 && originalFee > 0.0;
    
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
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
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
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
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
              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Constant.amountShow(amount: currentFee.toString()),
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              fontSize: 16,
            ),
          ),
        ],
      );
    }
  }
}
