import 'package:get/get.dart';
import 'package:customer/services/mart_firestore_service.dart';
import 'package:customer/models/mart_item_model.dart';

import '../services/mart_firestore_service.dart';

class MartProductController extends GetxController {
  final MartFirestoreService _firestoreService = Get.find<MartFirestoreService>();

  // Observable variables
  final RxList<MartItemModel> products = <MartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedVendorId = ''.obs;
  final RxString selectedCategoryId = ''.obs;

  // Pagination
  int currentPage = 1;
  static const int itemsPerPage = 20;

  // Filters
  final RxBool filterAvailableOnly = true.obs;
  final RxBool filterVegOnly = false.obs;
  final RxBool filterNonVegOnly = false.obs;
  final RxBool filterFeaturedOnly = false.obs;
  final RxBool filterOnSaleOnly = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('[MART PRODUCT CONTROLLER] Initialized');
  }

  /// Load products for a specific vendor
  Future<void> loadProducts({
    required String vendorId,
    String? categoryId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        currentPage = 1;
        products.clear();
        hasMore.value = true;
      }

      if (!hasMore.value || isLoading.value) return;

      isLoading.value = true;
      errorMessage.value = '';

      print('[MART PRODUCT CONTROLLER] Loading products for vendor: $vendorId');
      print('[MART PRODUCT CONTROLLER] Category filter: $categoryId');
      print('[MART PRODUCT CONTROLLER] Page: $currentPage');

      final items = await _firestoreService.getItemsByCategory(
        categoryId: categoryId ?? '',
        searchQuery: null,
        limit: itemsPerPage,
      );

      if (refresh) {
        products.clear();
      }

      products.addAll(items);
      hasMore.value = items.length == itemsPerPage;
      currentPage++;

      selectedVendorId.value = vendorId;
      selectedCategoryId.value = categoryId ?? '';

      print('[MART PRODUCT CONTROLLER] Loaded ${items.length} products');
      print('[MART PRODUCT CONTROLLER] Total products: ${products.length}');
      print('[MART PRODUCT CONTROLLER] Has more: ${hasMore.value}');

    } catch (e) {
      print('[MART PRODUCT CONTROLLER] Error loading products: $e');
      errorMessage.value = "Failed to load products: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    if (selectedVendorId.value.isEmpty) {
      errorMessage.value = "Please select a vendor first";
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';
      searchQuery.value = query;

      print('[MART PRODUCT CONTROLLER] Searching products: $query');

      final items = await _firestoreService.getItemsByCategory(
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : '',
        searchQuery: query,
        limit: itemsPerPage,
      );

      products.clear();
      products.addAll(items);
      hasMore.value = false; // Search results don't support pagination

      print('[MART PRODUCT CONTROLLER] Found ${items.length} products for query: $query');

    } catch (e) {
      print('[MART PRODUCT CONTROLLER] Error searching products: $e');
      errorMessage.value = "Failed to search products: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Load more products (pagination)
  Future<void> loadMoreProducts() async {
    if (selectedVendorId.value.isNotEmpty) {
      await loadProducts(
        vendorId: selectedVendorId.value,
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
      );
    }
  }

  /// Refresh products
  Future<void> refreshProducts() async {
    if (selectedVendorId.value.isNotEmpty) {
      await loadProducts(
        vendorId: selectedVendorId.value,
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
        refresh: true,
      );
    }
  }

  /// Apply filters
  Future<void> applyFilters() async {
    if (selectedVendorId.value.isNotEmpty) {
      await loadProducts(
        vendorId: selectedVendorId.value,
        categoryId: selectedCategoryId.value.isNotEmpty ? selectedCategoryId.value : null,
        refresh: true,
      );
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    if (selectedVendorId.value.isNotEmpty) {
      refreshProducts();
    }
  }

  /// Get featured products
  Future<List<MartItemModel>> getFeaturedProducts(String vendorId) async {
    try {
      print('[MART PRODUCT CONTROLLER] Loading featured products for vendor: $vendorId');
      
      final items = await _firestoreService.getFeaturedItems(limit: 20);
      
      print('[MART PRODUCT CONTROLLER] Loaded ${items.length} featured products');
      return items;
    } catch (e) {
      print('[MART PRODUCT CONTROLLER] Error loading featured products: $e');
      return [];
    }
  }

  /// Get products on sale
  Future<List<MartItemModel>> getProductsOnSale(String vendorId) async {
    try {
      print('[MART PRODUCT CONTROLLER] Loading products on sale for vendor: $vendorId');
      
      final items = await _firestoreService.getItemsOnSale(limit: 20);
      
      print('[MART PRODUCT CONTROLLER] Loaded ${items.length} products on sale');
      return items;
    } catch (e) {
      print('[MART PRODUCT CONTROLLER] Error loading products on sale: $e');
      return [];
    }
  }

  /// Get product by ID
  Future<MartItemModel?> getProductById(String productId) async {
    try {
      print('[MART PRODUCT CONTROLLER] Loading product details: $productId');
      
      final product = await _firestoreService.getItemById(productId);
      
      if (product != null) {
        print('[MART PRODUCT CONTROLLER] Loaded product: ${product.name}');
      } else {
        print('[MART PRODUCT CONTROLLER] Product not found: $productId');
      }
      
      return product;
    } catch (e) {
      print('[MART PRODUCT CONTROLLER] Error loading product details: $e');
      return null;
    }
  }

  /// Get filtered products
  List<MartItemModel> get filteredProducts {
    List<MartItemModel> filtered = products;

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        product.description.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }

    // Apply availability filter
    if (filterAvailableOnly.value) {
      filtered = filtered.where((product) => product.isAvailable).toList();
    }

    // Apply dietary filters
    if (filterVegOnly.value) {
      filtered = filtered.where((product) => product.veg).toList();
    }

    if (filterNonVegOnly.value) {
      filtered = filtered.where((product) => product.nonveg).toList();
    }

    // Apply featured filter
    if (filterFeaturedOnly.value) {
      filtered = filtered.where((product) => product.isFeaturedItem).toList();
    }

    // Apply on sale filter
    if (filterOnSaleOnly.value) {
      filtered = filtered.where((product) => product.isOnSaleItem).toList();
    }

    return filtered;
  }

  /// Reset all filters
  void resetFilters() {
    filterAvailableOnly.value = true;
    filterVegOnly.value = false;
    filterNonVegOnly.value = false;
    filterFeaturedOnly.value = false;
    filterOnSaleOnly.value = false;
    searchQuery.value = '';
    
    if (selectedVendorId.value.isNotEmpty) {
      applyFilters();
    }
  }

  /// Clear all data
  void clearData() {
    products.clear();
    isLoading.value = false;
    hasMore.value = true;
    errorMessage.value = '';
    searchQuery.value = '';
    selectedVendorId.value = '';
    selectedCategoryId.value = '';
    currentPage = 1;
    resetFilters();
  }
}
