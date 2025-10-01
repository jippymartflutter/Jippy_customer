import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/app/mart/mart_product_details_screen.dart';

import 'package:customer/widget/cart_animation_widget.dart';
import 'package:provider/provider.dart';

class MartProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;
  final bool showAddButton;
  final GlobalKey? cartIconKey;

  const MartProductCard({
    Key? key,
    required this.product,
    this.onTap,
    this.showAddButton = true,
    this.cartIconKey,
  }) : super(key: key);

  @override
  State<MartProductCard> createState() => _MartProductCardState();
}

class _MartProductCardState extends State<MartProductCard>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isAddingToCart = false;
  int _currentQuantity = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Check current cart quantity
    _checkCurrentQuantity();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _checkCurrentQuantity() {
    final cartItems = cartItem.where((item) => item.id == widget.product.id).toList();
    if (cartItems.isNotEmpty) {
      setState(() {
        _currentQuantity = cartItems.first.quantity ?? 0;
      });
    }
  }

  Future<void> _addToCart() async {
    if (_isAddingToCart) return;
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Start scale animation
      await _scaleController.forward();
      
      // Create cart product model
      final cartProduct = CartProductModel(
        id: widget.product.id,
        name: widget.product.name,
        photo: widget.product.photo,
        price: widget.product.price,
        discountPrice: widget.product.disPrice,
        quantity: 1,
        vendorID: widget.product.vendorID,
        vendorName: "Vendor", // Default vendor name since ProductModel doesn't have it
        extras: [],
        extrasPrice: "0",
        promoId: null,
      );

      // Add to cart using existing cart provider
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final success = await cartProvider.addToCart(context, cartProduct, 1);

      if (success) {
        // Show success animation
        await _showAddToCartAnimation();
        
        // Trigger cart animation if cart icon key is provided
        if (widget.cartIconKey != null) {
          // Trigger flying animation to cart
          CartAnimationHelper.triggerAnimation(widget.product.id ?? 'default');
        }
        
        // Update quantity
        _checkCurrentQuantity();
        
        // Show success message
        ShowToastDialog.showToast("Added to cart successfully!".tr);
      } else {
        // Show error message for cart conflict
        ShowToastDialog.showToast("Can't add items while you have food in cart".tr);
      }
      
    } catch (e) {
      ShowToastDialog.showToast("Failed to add to cart".tr);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
      
      // Reset scale animation
      await _scaleController.reverse();
    }
  }

  Future<void> _showAddToCartAnimation() async {
    // Start the slide and fade animation
    _animationController.forward();
    
    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Reset animation
    _animationController.reset();
  }

  Future<void> _updateQuantity(bool isIncrement) async {
    if (_isAddingToCart) return;
    
    final newQuantity = isIncrement ? _currentQuantity + 1 : _currentQuantity - 1;
    
    if (newQuantity < 0) return;
    
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // Create cart product model
      final cartProduct = CartProductModel(
        id: widget.product.id,
        name: widget.product.name,
        photo: widget.product.photo,
        price: widget.product.price,
        discountPrice: widget.product.disPrice,
        quantity: newQuantity,
        vendorID: widget.product.vendorID,
        vendorName: "Vendor", // Default vendor name since ProductModel doesn't have it
        extras: [],
        extrasPrice: "0",
        promoId: null,
      );

      // Update cart using existing cart provider
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      if (newQuantity == 0) {
        await cartProvider.removeFromCart(cartProduct, 0);
      } else {
        final success = await cartProvider.addToCart(context, cartProduct, newQuantity);
        if (!success) {
          ShowToastDialog.showToast("Can't add items while you have food in cart".tr);
          return;
        }
      }

      // Update quantity
      _checkCurrentQuantity();
      
    } catch (e) {
      ShowToastDialog.showToast("Failed to update cart".tr);
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    
    Widget productCard = GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppThemeData.grey900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Add Button
            Stack(
              children: [
                // Product Image
                GestureDetector(
                  onTap: () {
                    // Navigate to product details screen
                    Get.to(() => MartProductDetailsScreen(
                      product: widget.product,
                    ));
                  },
                  child: Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: widget.product.photo != null && widget.product.photo!.isNotEmpty
                          ? Image.network(
                              widget.product.photo!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.grey, size: 50),
                              ),
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.grey, size: 50),
                            ),
                    ),
                  ),
                ),
                
                // Volume/Quantity Badge
                if (widget.product.quantity != null && widget.product.quantity! > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                                              child: Text(
                          "${widget.product.quantity} ml",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ),
                  ),
                
                // Add to Cart Button
                if (widget.showAddButton)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: _currentQuantity == 0
                              ? _buildAddButton(themeChange)
                              : _buildQuantityControl(themeChange),
                        );
                      },
                    ),
                  ),
                
                // Add to Cart Animation Overlay
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary300.withValues(alpha: 0.8),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Product Details
            Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    widget.product.name ?? "Product Name",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 3),
                  
                  // Price and Discount
                  Row(
                    children: [
                                             // Current Price
                       Text(
                         "₹${widget.product.disPrice ?? widget.product.price ?? "0"}",
                         style: TextStyle(
                           fontSize: 15,
                           fontWeight: FontWeight.bold,
                           color: AppThemeData.primary300,
                         ),
                       ),
                       
                       const SizedBox(width: 8),
                       
                       // Original Price (if discounted)
                       if (widget.product.disPrice != null && 
                           widget.product.disPrice != widget.product.price)
                         Text(
                           "₹${widget.product.price ?? "0"}",
                           style: TextStyle(
                             fontSize: 14,
                             decoration: TextDecoration.lineThrough,
                             color: Colors.grey[600],
                           ),
                         ),
                      
                      const Spacer(),
                      
                                             // Discount Badge
                       if (widget.product.disPrice != null && 
                           widget.product.disPrice != widget.product.price)
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(
                             color: Colors.green,
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: const Text(
                             "50% OFF",
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 9,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
    // Wrap with cart animation if cart icon key is provided
    if (widget.cartIconKey != null) {
      return CartAnimationWidget(
        cartIconKey: widget.cartIconKey!,
        onAnimationComplete: () {
          // Animation completed
        },
        child: productCard,
      );
    }
    
    return productCard;
  }

  Widget _buildAddButton(DarkThemeProvider themeChange) {
    return GestureDetector(
      onTap: _addToCart,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppThemeData.primary300,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppThemeData.primary300.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildQuantityControl(DarkThemeProvider themeChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease Button
          GestureDetector(
            onTap: () => _updateQuantity(false),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppThemeData.primary300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.remove,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          
          const SizedBox(width: 6),
          
          // Quantity
          Text(
            "$_currentQuantity",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(width: 6),
          
          // Increase Button
          GestureDetector(
            onTap: () => _updateQuantity(true),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppThemeData.primary300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

