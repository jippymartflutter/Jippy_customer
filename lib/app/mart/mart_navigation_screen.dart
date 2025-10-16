import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer/controllers/mart_navigation_controller.dart';
import 'package:customer/services/cart_provider.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/mart_theme.dart';
import 'package:provider/provider.dart';

class MartNavigationScreen extends StatefulWidget {
  const MartNavigationScreen({super.key});

  @override
  State<MartNavigationScreen> createState() => _MartNavigationScreenState();
}

class _MartNavigationScreenState extends State<MartNavigationScreen> {
  bool _isScrollingDown = false;
  bool _isBottomNavVisible = true;
  double _lastScrollPosition = 0;

  @override
  void initState() {
    super.initState();
    print('\n🛒 [MART_NAVIGATION_SCREEN] ===== MART SCREEN LOADED =====');
    print('📍 [MART_NAVIGATION_SCREEN] Current Zone: ${Constant.selectedZone?.id ?? "NULL"} (${Constant.selectedZone?.name ?? "NULL"})');
    print('📍 [MART_NAVIGATION_SCREEN] User Location: ${Constant.selectedLocation.location?.latitude ?? "NULL"}, ${Constant.selectedLocation.location?.longitude ?? "NULL"}');
    print('🎯 [MART_NAVIGATION_SCREEN] Navigation: User successfully accessed Mart section');
    print('🛒 [MART_NAVIGATION_SCREEN] ===== MART SCREEN INITIALIZED =====\n');
  }

  void _onScroll(double scrollPosition) {
    // Determine scroll direction
    if (scrollPosition > _lastScrollPosition && !_isScrollingDown) {
      // Scrolling down - hide navigation
      _isScrollingDown = true;
      _hideBottomNav();
    } else if (scrollPosition < _lastScrollPosition && _isScrollingDown) {
      // Scrolling up - show navigation
      _isScrollingDown = false;
      _showBottomNav();
    }
    
    _lastScrollPosition = scrollPosition;
  }

  void _hideBottomNav() {
    if (_isBottomNavVisible) {
      setState(() {
        _isBottomNavVisible = false;
      });
    }
  }

  void _showBottomNav() {
    if (!_isBottomNavVisible) {
      setState(() {
        _isBottomNavVisible = true;
      });
    }
  }

  // Method to handle scroll events from child screens
  void handleScroll(double scrollPosition) {
    _onScroll(scrollPosition);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MartTheme.theme,
      child: GetBuilder<MartNavigationController>(
        init: MartNavigationController(),
        builder: (navController) {
          return PopScope(
            canPop: false, // Prevent default back behavior
            onPopInvoked: (didPop) async {
              if (didPop) return;
              
              // Handle system back button
              if (navController.selectedIndex.value == 0) {
                // If on home tab, go back to previous screen (Jippy Food)
                Get.back();
              } else {
                // If on other tabs, go back to home tab
                navController.goToHome();
              }
            },
            child: Scaffold(
          backgroundColor: const Color(0xFFF6F6FF),
          body: Stack(
            children: [
              // Main content with scroll detection
              Obx(() => NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo is ScrollUpdateNotification) {
                    handleScroll(scrollInfo.metrics.pixels);
                  }
                  return false;
                },
                child: IndexedStack(
                  index: navController.selectedIndex.value,
                  children: navController.pageList,
                ),
              )),
              
              // Floating navigation bar - hide when cart is selected
              Obx(() {
                if (navController.selectedIndex.value != 2) { // Hide for cart tab (index 2)
                  return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 300),
                    offset: _isBottomNavVisible ? Offset.zero : const Offset(0, 1.5),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _isBottomNavVisible ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, -3),
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: SafeArea(
                        // minimum: EdgeInsets.zero, // Removes extra SafeArea padding
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Reduced padding for smaller size
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildNavItem(
                                icon: Icons.home_outlined,
                                activeIcon: Icons.home,
                                label: 'Home',
                                index: 0,
                                controller: navController,
                              ),
                              _buildNavItem(
                                icon: Icons.category_outlined,
                                activeIcon: Icons.category,
                                label: 'Categories',
                                index: 1,
                                controller: navController,
                              ),
                              _buildNavItem(
                                icon: Icons.shopping_cart_outlined,
                                activeIcon: Icons.shopping_cart,
                                label: 'Cart',
                                index: 2,
                                controller: navController,
                                badge: Consumer<CartProvider>(
                                  builder: (context, cartProvider, _) {
                                    return StreamBuilder<List<CartProductModel>>(
                                      stream: cartProvider.cartStream,
                                      builder: (context, snapshot) {
                                        int cartItemCount = snapshot.data?.length ?? cartItem.length;
                                        return cartItemCount > 0
                                            ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            cartItemCount.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                            : const SizedBox.shrink();
                                      },
                                    );
                                  },
                                ),

                                // badge: StreamBuilder<List<CartProductModel>>(
                                //   stream: CartProvider().cartStream,
                                //   builder: (context, snapshot) {
                                //     int cartItemCount = snapshot.data?.length ?? cartItem.length;
                                //     return cartItemCount > 0
                                //         ? Container(
                                //             padding: const EdgeInsets.all(4),
                                //             decoration: const BoxDecoration(
                                //               color: Colors.red,
                                //               shape: BoxShape.circle,
                                //             ),
                                //             child: Text(
                                //               cartItemCount.toString(),
                                //               style: const TextStyle(
                                //                 color: Colors.white,
                                //                 fontSize: 10,
                                //                 fontWeight: FontWeight.bold,
                                //               ),
                                //             ),
                                //           )
                                //         : const SizedBox.shrink();
                                //   },
                                // ),
                              ),
                              _buildNavItem(
                                icon: Icons.person_outline,
                                activeIcon: Icons.person,
                                label: 'Profile',
                                index: 3,
                                controller: navController,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
                } else {
                  return const SizedBox.shrink(); // Hide navigation when cart is selected
                }
              }),
            ],
          ),
            ),
        );
      },
    ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required MartNavigationController controller,
    Widget? badge,
  }) {
    return Obx(() {
      final isActive = controller.selectedIndex.value == index;
      
      return GestureDetector(
        onTap: () => controller.changeIndex(index),
                  child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF00998a).withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  Icon(
                    isActive ? activeIcon : icon,
                    color: isActive ? const Color(0xFF00998a) : Colors.grey[600],
                    size: 24,
                  ),
                  if (badge != null && index == 2) // Cart badge
                    Positioned(
                      right: -4,
                      top: -4,
                      child: badge,
                    ),
                ],
                              ),
                const SizedBox(height: 3),
                                Text(
                    label,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF00998a) : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
            ],
          ),
        ),
      );
    });
  }
}