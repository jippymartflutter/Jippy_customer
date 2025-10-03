import 'package:customer/app/mart/mart_product_details_screen.dart';
import 'package:customer/controllers/cart_controller.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlaytimeProductCard extends StatelessWidget {
  final String volume;
  final String productName;
  final String discount;
  final String currentPrice;
  final String originalPrice;
  final double screenWidth;
  final String? imageUrl;
  final MartItemModel? product; // Add product model for cart functionality

  const PlaytimeProductCard({
    super.key,
    required this.volume,
    required this.productName,
    required this.discount,
    required this.currentPrice,
    required this.originalPrice,
    required this.screenWidth,
    this.imageUrl,
    this.product, // Optional product model
  });

  void _handleAddToCart(BuildContext context) {
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product information not available'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading state
      // No need to show loading state - the toast will handle the feedback

      // Get the cart controller
      final cartController = Get.find<CartController>();

      // Convert MartItemModel to CartProductModel
      final martVendorID = "mart_${product!.vendorID ?? 'unknown'}";

      final cartProduct = CartProductModel(
        id: product!.id,
        name: product!.name,
        photo: product!.photo,
        price: product!.price?.toString() ?? '0',
        discountPrice:
            product!.disPrice?.toString() ?? product!.price?.toString() ?? '0',
        vendorID: martVendorID,
        vendorName: "Jippy Mart",
        categoryId: product!.categoryID,
        quantity: 1,
        extrasPrice: '0',
        extras: [],
        variantInfo: null,
        promoId: null,
      );

      // Add to cart
      cartController.addToCart(
        cartProductModel: cartProduct,
        isIncrement: true,
        quantity: 1,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${product!.name} added to cart successfully!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('[CART] Error adding to cart: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to cart: ${e.toString()}'),
          backgroundColor: Colors.red.shade600,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 101,
      height: 215,
      margin: const EdgeInsets.only(right: 16),
      child: Stack(
        children: [
          // Product image
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              onTap: () {
                // Navigate to product details screen if product model is available
                if (product != null) {
                  Get.to(() => MartProductDetailsScreen(
                        product: product!,
                      ));
                } else {
                  // Show message if product model is not available
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product details not available'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Container(
                width: 101,
                height: 131,
                decoration: BoxDecoration(
                  color: const Color(0xFFECEAFD),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? NetworkImageWidget(
                          imageUrl: imageUrl!,
                          width: 101,
                          height: 131,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            width: 101,
                            height: 131,
                            decoration: const BoxDecoration(
                              color: Color(0xFFECEAFD),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: 101,
                          height: 131,
                          decoration: const BoxDecoration(
                            color: Color(0xFFECEAFD),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Volume text (600 ml)
          // Positioned(
          //   left: 26, // 42 - 16 (container left offset)
          //   top: 8,
          //   child: Text(
          //     volume,
          //     style: const TextStyle(
          //       fontFamily: 'Montserrat',
          //       fontSize: 12,
          //       fontWeight: FontWeight.w500,
          //       height: 15 / 12, // line-height: 15px
          //       color: Color(0xFF1A1A1A),
          //     ),
          //   ),
          // ),

          // Add button with plus icon
          Positioned(
            left: 13, // 29 - 16 (container left offset)
            top: 100, // Moved up by 2px to add bottom padding
            child: Container(
              width: 76,
              height: 27,
              decoration: BoxDecoration(
                color: Colors.green,
                // color: const Color(0xFF595BD4), // Solid purple background
                borderRadius: BorderRadius.circular(7),
              ),
              child: GestureDetector(
                onTap: () => _handleAddToCart(context),
                child: const Center(
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 17 / 14, // line-height: 17px
                      color: Colors.white, // White text on purple background
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Product name
          Positioned(
            left: 0,
            top: 143,
            child: SizedBox(
              width: 101,
              height: 20,
              child: Text(
                productName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 15 / 12, // line-height: 15px
                  color: Color(0xFF000000),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Current price and Original price side by side
          Positioned(
            left: 0,
            top: 165,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Current price (in red)
                Text(
                  currentPrice,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 15 / 12, // line-height: 15px
                    color: Color(0xFFFF0000), // Red color
                  ),
                ),
                const SizedBox(width: 8), // Space between prices
                // Original price (struck through)
                Text(
                  originalPrice,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 15 / 12, // line-height: 15px
                    color: Color(0xFF444343),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),

          // Discount percentage
          Positioned(
            left: 0,
            top: 185,
            child: Text(
              discount,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 15 / 12, // line-height: 15px
                color: Color(0xFF3C720E),
              ),
            ),
          ),

          // Line separator
          // Positioned(
          //   left: 0,
          //   top: 194,
          //   child: Container(
          //     width: 44,
          //     height: 1,
          //     color: const Color(0xFF3B3B3B),
          //   ),
          // ),
        ],
      ),
    );
  }
}
