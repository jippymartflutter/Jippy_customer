import 'package:customer/constant/category_config.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/vendor_category_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class ViewAllCategoryController extends GetxController {
  RxBool isLoading = true.obs;

  RxList<VendorCategoryModel> vendorCategoryModel = <VendorCategoryModel>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getCategoryData();
    super.onInit();
  }

  getCategoryData() async {
    await FireStoreUtils.getVendorCategory().then(
      (value) {
        vendorCategoryModel.value = value;
        _filterCategories();
      },
    );

    isLoading.value = false;
  }

  void _filterCategories() {
    if (!CategoryConfig.enableCategoryFiltering) {
      return;
    }

    List<VendorCategoryModel> filteredCategories = [];

    if (CategoryConfig.useTitleFiltering) {
      // Filter by category titles
      filteredCategories = vendorCategoryModel.where((category) {
        return category.title != null && 
               CategoryConfig.allowedCategoryTitles.contains(category.title);
      }).toList();
    } else {
      // Filter by category IDs
      filteredCategories = vendorCategoryModel.where((category) {
        return category.id != null && 
               CategoryConfig.allowedCategoryIds.contains(category.id);
      }).toList();
    }

    // Apply maximum limit if specified
    if (CategoryConfig.maxCategoriesToShow != null) {
      filteredCategories = filteredCategories.take(CategoryConfig.maxCategoriesToShow!).toList();
    }

    // Show only categories with active vendors if enabled
    if (CategoryConfig.showOnlyCategoriesWithVendors && Constant.restaurantList != null) {
      List<String> usedCategoryIds = Constant.restaurantList!
          .expand((vendor) => vendor.categoryID ?? [])
          .whereType<String>()
          .toSet()
          .toList();
      
      filteredCategories = filteredCategories.where((category) {
        return category.id != null && usedCategoryIds.contains(category.id);
      }).toList();
    }

    vendorCategoryModel.value = filteredCategories;
    
    print('[CATEGORY_CONTROLLER] Total categories: ${vendorCategoryModel.length}');
    print('[CATEGORY_CONTROLLER] Filtered categories: ${filteredCategories.length}');
  }
}
