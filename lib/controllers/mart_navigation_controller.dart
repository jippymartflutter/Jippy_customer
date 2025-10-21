import 'package:customer/app/cart_screen/cart_screen.dart';
import 'package:customer/app/mart/screens/mart_categories_screen/mart_categories_screen.dart';
import 'package:customer/app/mart/mart_home_screen/mart_home_screen.dart';
import 'package:customer/app/mart/screens/mart_profile_screen/mart_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MartNavigationController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxList<Widget> pageList = <Widget>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializePages();
  }

  void _initializePages() {
    pageList.value = [
      const MartHomeScreen(),
      const MartCategoriesScreen(), // Using new MartCategoriesScreen with API data
      const CartScreen(
          hideBackButton: false, source: 'mart', isFromMartNavigation: true),
      const MartProfileScreen(),
    ];
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  // Get current page
  Widget get currentPage => pageList[selectedIndex.value];

  // Navigation methods
  void goToHome() => changeIndex(0);
  void goToCategories() => changeIndex(1); // Updated method name
  void goToCart() => changeIndex(2);
  void goToProfile() => changeIndex(3);
}
