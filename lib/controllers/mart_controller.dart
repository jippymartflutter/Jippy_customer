import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/mart_banner_model.dart';
import 'package:customer/models/mart_category_model.dart';
import 'package:customer/models/mart_delivery_settings_model.dart';
import 'package:customer/models/mart_item_model.dart';
import 'package:customer/models/mart_subcategory_model.dart';
import 'package:customer/models/mart_vendor_model.dart';
import 'package:customer/services/mart_firestore_service.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MartController extends GetxController {
  // Service injection
  final MartFirestoreService _firestoreService =
      Get.find<MartFirestoreService>();

  // Observable variables
  RxBool isLoading = true.obs;
  RxBool isCategoryLoading = false.obs;
  RxBool isProductLoading = false.obs;
  RxBool isVendorLoading = false.obs;
  RxBool isHomepageCategoriesLoaded = false.obs;
  RxString selectedCategoryId = "".obs;
  RxString selectedVendorId = "".obs;
  RxString selectedVendorName = "".obs;
  RxString searchQuery = "".obs;
  RxString errorMessage = "".obs;

  // Data lists
  RxList<MartVendorModel> martVendors = <MartVendorModel>[].obs;
  RxList<MartCategoryModel> martCategories = <MartCategoryModel>[].obs;
  RxMap<String, List<MartSubcategoryModel>> subcategoriesMap =
      <String, List<MartSubcategoryModel>>{}.obs;
  RxList<MartItemModel> martItems = <MartItemModel>[].obs;
  RxList<MartItemModel> filteredItems = <MartItemModel>[].obs;
  RxList<MartItemModel> featuredItems = <MartItemModel>[].obs;
  RxList<MartItemModel> itemsOnSale = <MartItemModel>[].obs;
  RxList<MartCategoryModel> featuredCategories = <MartCategoryModel>[].obs;
  RxList<MartItemModel> cartItems = <MartItemModel>[].obs;
  RxList<Map<String, dynamic>> spotlightItems = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> stealsItems = <Map<String, dynamic>>[].obs;
  RxList<MartItemModel> trendingItems = <MartItemModel>[].obs;
  RxBool isTrendingLoading = false.obs;
  RxBool isSubcategoryLoading = false.obs;

  // Sections data
  RxList<String> availableSections = <String>[].obs;
  RxMap<String, List<MartItemModel>> sectionProducts =
      <String, List<MartItemModel>>{}.obs;
  RxBool isSectionsLoading = false.obs;
  bool _sectionsLoadingTriggered =
      false; // Flag to prevent multiple loading attempts
  RxList<MartSubcategoryModel> subcategories = <MartSubcategoryModel>[].obs;

  // Delivery settings
  Rx<MartDeliverySettingsModel?> deliverySettings =
      Rx<MartDeliverySettingsModel?>(null);

  // Banner functionality
  RxList<MartBannerModel> martTopBanners = <MartBannerModel>[].obs;
  RxList<MartBannerModel> martBottomBanners = <MartBannerModel>[].obs;
  Rx<PageController> martTopBannerController =
      PageController(viewportFraction: 1.0).obs;
  Rx<PageController> martBottomBannerController =
      PageController(viewportFraction: 1.0).obs;
  RxInt currentTopBannerPage = 0.obs;
  RxInt currentBottomBannerPage = 0.obs;
  Timer? _martBannerTimer;

  // Getter for trending items where isTrending is true
  List<MartItemModel> get filteredTrendingItems {
    final filtered =
        trendingItems.where((item) => item.isTrending == true).toList();
    print(
        '[MART CONTROLLER] 🔍 Filtered trending items: ${filtered.length}/${trendingItems.length} (isTrending=true)');
    if (trendingItems.isNotEmpty) {
      print('[MART CONTROLLER] 📊 Trending items breakdown:');
      for (int i = 0; i < trendingItems.length; i++) {
        final item = trendingItems[i];
        print(
            '[MART CONTROLLER]   ${i + 1}. ${item.name} - isTrending: ${item.isTrending}');
      }
    }
    return filtered;
  }

  // Current data
  Rx<MartVendorModel?> currentVendor = Rx<MartVendorModel?>(null);
  Rx<MartCategoryModel?> currentCategory = Rx<MartCategoryModel?>(null);

  // Pagination
  RxBool hasMoreItems = true.obs;
  RxBool hasMoreVendors = true.obs;
  int currentPage = 1;
  int currentVendorPage = 1;
  static const int itemsPerPage = 20;
  static const int vendorsPerPage = 10;

  // Search and filter
  Timer? _searchDebouncer;
  RxString selectedSortBy = "name".obs;
  RxBool sortAscending = true.obs;
  RxBool filterVegOnly = false.obs;
  RxBool filterNonVegOnly = false.obs;
  RxBool filterAvailableOnly = true.obs;

  @override
  void onInit() {
    super.onInit();
    print('[MART CONTROLLER] ==========================================');
    print('[MART CONTROLLER] 🚀 onInit() called');
    print('[MART CONTROLLER] 📊 Initial state:');
    print(
        '[MART CONTROLLER]   - featuredCategories: ${featuredCategories.length}');
    print(
        '[MART CONTROLLER]   - isCategoryLoading: ${isCategoryLoading.value}');
    print('[MART CONTROLLER]   - errorMessage: ${errorMessage.value}');
    print('[MART CONTROLLER] ==========================================');

    // Start sections loading immediately when controller is created
    _preloadSections();

    _initializeServices();
    setupSearchListener();
  }

  @override
  void onClose() {
    _searchDebouncer?.cancel();
    _martBannerTimer?.cancel();
    try {
      if (martTopBannerController.value.hasClients) {
        martTopBannerController.value.dispose();
      }
      if (martBottomBannerController.value.hasClients) {
        martBottomBannerController.value.dispose();
      }
    } catch (e) {
      // Ignore disposal errors
    }
    super.onClose();
  }

  // ==================== BANNER FUNCTIONALITY ====================

  /// Start mart banner auto-scroll timer
  void startMartBannerTimer() {
    _martBannerTimer?.cancel();
    _martBannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Check if controller is still valid and widget is mounted
      if (!Get.isRegistered<MartController>() ||
          !martTopBannerController.value.hasClients) {
        timer.cancel();
        return;
      }

      if (martTopBanners.isNotEmpty) {
        // For infinite scrolling, we need to get the current page and move to next
        try {
          if (martTopBannerController.value.hasClients) {
            int currentPage = martTopBannerController.value.page?.round() ?? 0;
            int nextPage = currentPage + 1;

            // Update the current page indicator (modulo for actual banner index)
            currentTopBannerPage.value = nextPage % martTopBanners.length;

            martTopBannerController.value.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        } catch (e) {
          // If any error occurs, cancel the timer
          timer.cancel();
        }
      }
    });
  }

  /// Stop mart banner auto-scroll timer
  void stopMartBannerTimer() {
    _martBannerTimer?.cancel();
  }

  /// Load mart banners using lazy loading streams
  void loadMartBannersStream() {
    print('[MART CONTROLLER] Starting lazy loading mart banners stream...');

    // Use lazy loading - only start streams when needed
    _initializeBannerStreams();
  }

  /// Initialize banner streams with lazy loading
  void _initializeBannerStreams() {
    // Stream for top banners - lazy loading
    FireStoreUtils.getMartTopBannersStream().listen(
      (banners) {
        print('[MART CONTROLLER] Lazy load - Top banners: ${banners.length}');
        martTopBanners.value = banners;

        // Initialize controllers if banners are available
        if (banners.isNotEmpty) {
          _initializeBannerControllers();
        }
      },
      onError: (error) {
        print('[MART CONTROLLER] Lazy load error for top banners: $error');
        martTopBanners.clear();
      },
    );

    // Stream for bottom banners - lazy loading
    FireStoreUtils.getMartBottomBannersStream().listen(
      (banners) {
        print(
            '[MART CONTROLLER] Lazy load - Bottom banners: ${banners.length}');
        martBottomBanners.value = banners;
      },
      onError: (error) {
        print('[MART CONTROLLER] Lazy load error for bottom banners: $error');
        martBottomBanners.clear();
      },
    );
  }

  /// Initialize banner PageControllers at middle position for infinite scrolling
  void _initializeBannerControllers() {
    // Initialize top banner controller at middle position
    if (martTopBanners.isNotEmpty && martTopBanners.length > 1) {
      int middlePosition = (martTopBanners.length * 1000) ~/
          2; // Start at middle of infinite list
      martTopBannerController.value =
          PageController(initialPage: middlePosition);
      currentTopBannerPage.value = 0; // Set indicator to first banner
    } else {
      martTopBannerController.value = PageController(initialPage: 0);
      currentTopBannerPage.value = 0;
    }

    // Initialize bottom banner controller at middle position
    if (martBottomBanners.isNotEmpty && martBottomBanners.length > 1) {
      int middlePosition = (martBottomBanners.length * 1000) ~/
          2; // Start at middle of infinite list
      martBottomBannerController.value =
          PageController(initialPage: middlePosition);
      currentBottomBannerPage.value = 0; // Set indicator to first banner
    } else {
      martBottomBannerController.value = PageController(initialPage: 0);
      currentBottomBannerPage.value = 0;
    }

    print(
        '[MART CONTROLLER] Banner controllers initialized for infinite scrolling');
  }

  // Initialize services with streaming data loading
  Future<void> _initializeServices() async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print(
          '[MART CONTROLLER] _initializeServices() called - FIREBASE ONLY MODE');
      print('[MART CONTROLLER] ==========================================');

      // Firestore is always available when the app is running
      print('[MART CONTROLLER] 🔥 Firestore service is available');

      // Start streaming data loading - each section loads independently
      print('[MART CONTROLLER] 🚀 Starting streaming data loading...');

      // 1. Load homepage categories first (highest priority - users see this immediately)
      print('[MART CONTROLLER] 🏠 Loading homepage categories first...');
      loadHomepageCategoriesStreaming(limit: 10);

      // 2. Load trending items in parallel (high priority)
      print('[MART CONTROLLER] 🔥 Loading trending items in parallel...');
      loadTrendingItemsStreaming();

      // 3. Load featured items in parallel (medium priority)
      print('[MART CONTROLLER] ⭐ Loading featured items in parallel...');
      loadFeaturedItemsStreaming();

      // 4. Load sections immediately in parallel (high priority - users expect to see them)
      print('[MART CONTROLLER] 📂 Loading sections immediately in parallel...');
      _loadSectionsInParallel();

      // 5. Load all categories in background (lower priority)
      print('[MART CONTROLLER] 📂 Loading all categories in background...');
      loadCategoriesStreaming();

      // 6. Load vendors in background (lowest priority)
      print('[MART CONTROLLER] 🏪 Loading vendors in background...');
      _loadVendorsStreaming();

      print(
          '[MART CONTROLLER] ✅ Streaming initialization started - data will load progressively');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error in _initializeServices: $e');
      errorMessage.value = 'Failed to initialize services: $e';
    }
  }

  /// Load vendors in background without blocking UI (Firebase only)
  Future<void> _loadVendorsInBackground() async {
    try {
      print(
          '[MART CONTROLLER] 🔄 Loading vendors in background from Firestore...');

      // Load vendors from Firestore
      final vendors = await _firestoreService.getMartVendors(
        isActive: true,
        enabledDelivery: false,
        limit: 10,
      );

      if (vendors.isNotEmpty) {
        print(
            '[MART CONTROLLER] ✅ Loaded ${vendors.length} vendors from Firestore');
        martVendors.clear();
        martVendors.addAll(vendors);

        // Auto-select first vendor
        if (selectedVendorId.value.isEmpty) {
          selectVendor(vendors.first.id!);
          print(
              '[MART CONTROLLER] 🎯 Auto-selected first vendor: ${vendors.first.name}');

          // Load additional data now that we have a vendor
          await _loadAdditionalData();

          // Load mart banners using streams
          loadMartBannersStream();
        }
      } else {
        print('[MART CONTROLLER] ⚠️ No vendors found in background loading');
        // Still try to load additional data with dummy vendor
        await _loadAdditionalData();
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading vendors in background: $e');
      // Don't show error to user since categories are already loaded
      // Still try to load additional data
      await _loadAdditionalData();
    }
  }

  /// Load additional data (featured items, items on sale, etc.)
  Future<void> _loadAdditionalData() async {
    try {
      print('[MART CONTROLLER] 📦 Loading additional data...');

      // Load featured items if we have a vendor
      if (selectedVendorId.value.isNotEmpty) {
        await loadFeaturedItems();
        await loadItemsOnSale();
      }

      print('[MART CONTROLLER] ✅ Additional data loaded');
    } catch (e) {
      print('[MART CONTROLLER] ⚠️ Error loading additional data: $e');
      // Don't show error to user
    }
  }

  /// Get user location from shipping address or use default
  Future<({double? latitude, double? longitude})> _getUserLocation() async {
    try {
      // Try to get location from user model or preferences
      if (Constant.userModel?.shippingAddress != null &&
          Constant.userModel!.shippingAddress!.isNotEmpty) {
        final defaultAddress = Constant.userModel!.shippingAddress!
            .firstWhereOrNull((addr) => addr.isDefault == true);
        if (defaultAddress?.location != null) {
          return (
            latitude: defaultAddress!.location!.latitude,
            longitude: defaultAddress.location!.longitude,
          );
        }
      }

      // Fallback to default coordinates (Ongole)
      return (
        latitude: 15.486434,
        longitude: 80.049588,
      );
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error getting user location: $e');
      // Fallback to default coordinates
      return (
        latitude: 15.486434,
        longitude: 80.049588,
      );
    }
  }

  // Setup search debouncer
  void setupSearchListener() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (searchQuery.value.isNotEmpty) {
        performSearch();
      } else {
        clearSearch();
      }
    });
  }

  /// Load mart vendors
  Future<void> loadMartVendors({bool refresh = false}) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🏪 loadMartVendors() called');
      print('[MART CONTROLLER] ==========================================');

      if (refresh) {
        print('[MART CONTROLLER] 🔄 Refresh mode - clearing existing vendors');
        martVendors.clear();
      }

      // Set loading state with timeout
      isVendorLoading.value = true;
      errorMessage.value = "";

      // Add timeout to prevent infinite loading
      bool timeoutReached = false;
      Timer? timeoutTimer;

      timeoutTimer = Timer(const Duration(seconds: 15), () {
        timeoutReached = true;
        print('[MART CONTROLLER] ⏰ Vendor loading timeout reached');
        isVendorLoading.value = false;
        errorMessage.value = "Vendor loading timed out. Please try again.";
      });

      try {
        // Get user location
        print('[MART CONTROLLER] 📍 Getting user location...');
        final location = await _getUserLocation();
        print(
            '[MART CONTROLLER] 📍 Found user location: ${location.latitude}, ${location.longitude}');

        if (timeoutReached) return;

        print(
            '[MART CONTROLLER] 📞 Calling _martService.getMartVendors() with:');
        print('[MART CONTROLLER]    - isActive: true');
        print('[MART CONTROLLER]    - page: 1');
        print('[MART CONTROLLER]    - limit: 10');
        print('[MART CONTROLLER]    - latitude: ${location.latitude}');
        print('[MART CONTROLLER]    - longitude: ${location.longitude}');
        print('[MART CONTROLLER]    - radius: 10.0');

        final vendors = await _firestoreService.getMartVendors(
          isActive: true,
          limit: 10,
        );

        if (timeoutReached) return;

        print(
            '[MART CONTROLLER] ✅ Vendors loaded successfully: ${vendors.length} vendors');

        if (refresh) {
          martVendors.clear();
        }

        martVendors.addAll(vendors);

        // Auto-select first vendor if none selected
        if (selectedVendorId.value.isEmpty && vendors.isNotEmpty) {
          final firstVendor = vendors.first;
          selectedVendorId.value = firstVendor.id!;
          print(
              '[MART CONTROLLER] 🎯 Auto-selected first vendor: ${firstVendor.name} (${firstVendor.id})');
        }

        print('[MART CONTROLLER] ✅ Vendor loading completed successfully');
      } catch (e) {
        if (timeoutReached) return;

        print('[MART CONTROLLER] ❌ Error loading vendors: $e');
        errorMessage.value =
            "Unable to load stores. Please check your connection and try again.";

        // If no vendors loaded, try to continue with empty state
        if (martVendors.isEmpty) {
          print(
              '[MART CONTROLLER] ⚠️ No vendors available, continuing with empty state');
        }
      } finally {
        timeoutTimer.cancel();
        if (!timeoutReached) {
          isVendorLoading.value = false;
        }
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Unexpected error in loadMartVendors: $e');
      isVendorLoading.value = false;
      errorMessage.value = "Something went wrong. Please try again later.";
    }
  }

  /// Load more vendors (pagination)
  Future<void> loadMoreVendors() async {
    if (!hasMoreVendors.value || isVendorLoading.value) return;

    currentVendorPage++;
    await loadMartVendors();
  }

  /// Select a vendor
  void selectVendor(String vendorId) {
    selectedVendorId.value = vendorId;
    final vendor = martVendors.firstWhereOrNull((v) => v.id == vendorId);
    currentVendor.value = vendor;
    selectedVendorName.value = vendor?.name ?? "Unknown Vendor";

    // Load vendor-specific data
    loadVendorCategories(vendorId);
    loadVendorItems(vendorId);
  }

  /// Search vendors
  Future<void> searchVendors(String query) async {
    try {
      isVendorLoading.value = true;
      errorMessage.value = "";

      // Get user's current location or use default coordinates
      double? userLatitude;
      double? userLongitude;

      // Try to get location from user model or preferences
      if (Constant.userModel?.shippingAddress != null &&
          Constant.userModel!.shippingAddress!.isNotEmpty) {
        final defaultAddress = Constant.userModel!.shippingAddress!
            .firstWhereOrNull((addr) => addr.isDefault == true);
        if (defaultAddress?.location != null) {
          userLatitude = defaultAddress!.location!.latitude;
          userLongitude = defaultAddress.location!.longitude;
        }
      }

      final vendors = await _firestoreService.getMartVendors(
        search: query,
        isActive: true,
        limit: 20,
      );
      martVendors.clear();
      martVendors.addAll(vendors);
    } catch (e) {
      print('[MART] Error searching vendors: $e');
      errorMessage.value = "Failed to search vendors: $e";
    } finally {
      isVendorLoading.value = false;
    }
  }

  // ==================== MART CATEGORIES ====================

  /// Load mart categories (Firebase only)
  Future<void> loadMartCategories({bool refresh = false}) async {
    if (isCategoryLoading.value && !refresh) return;

    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 📂 loadMartCategories() called - FIREBASE ONLY');
      print('[MART CONTROLLER] ==========================================');

      if (refresh) {
        print(
            '[MART CONTROLLER] 🔄 Refresh mode - clearing existing categories');
        martCategories.clear();
      }

      isCategoryLoading.value = true;
      errorMessage.value = '';

      print('[MART CONTROLLER] 🔥 Loading categories from Firestore...');

      // Load categories from Firestore
      final categories =
          await _firestoreService.getHomepageCategories(limit: 50);
      print(
          '[MART CONTROLLER] ✅ Categories loaded from Firestore: ${categories.length} categories');

      if (categories.isNotEmpty) {
        // ✅ Load categories FIRST - show them immediately
        martCategories.assignAll(categories);
        print(
            '[MART CONTROLLER] ✅ Categories loaded successfully: ${categories.length} categories');

        // ✅ Set loading to false immediately after categories are loaded
        isCategoryLoading.value = false;

        // 🔄 Load item counts in background (non-blocking)
        _loadItemCountsInBackground(categories.take(3).toList());
      } else {
        errorMessage.value = 'No categories found.';
        print('[MART CONTROLLER] ⚠️ No categories found');
        isCategoryLoading.value = false;
      }
    } catch (e) {
      isCategoryLoading.value = false;
      errorMessage.value = 'Unable to load categories. Please try again.';
      print('[MART CONTROLLER] ❌ Error loading categories: $e');
    }
  }

  /// Load item counts in background without blocking UI (Firebase only)
  Future<void> _loadItemCountsInBackground(
      List<MartCategoryModel> categoriesToLoad) async {
    try {
      print(
          '[MART CONTROLLER] 🔄 Loading item counts in background from Firestore...');

      for (int i = 0; i < categoriesToLoad.length; i++) {
        final category = categoriesToLoad[i];
        try {
          // Get item count from Firestore
          final itemCount =
              await _firestoreService.getItemCountForCategory(category.id!);
          category.itemCount = itemCount;
          print(
              '[MART CONTROLLER] ✅ Category "${category.title}" has $itemCount items');

          // Update the UI for this specific category
          martCategories
              .firstWhereOrNull((c) => c.id == category.id)
              ?.itemCount = itemCount;
        } catch (e) {
          print(
              '[MART CONTROLLER] ⚠️ Failed to get item count for category "${category.title}": $e');
          martCategories
              .firstWhereOrNull((c) => c.id == category.id)
              ?.itemCount = 0;
        }
      }

      print('[MART CONTROLLER] ✅ All item counts loaded in background');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading item counts in background: $e');
    }
  }

  /// Load sub-categories for all categories that have them
  Future<void> loadSubcategoriesForCategories() async {
    try {
      print(
          '[MART CONTROLLER] 🔄 Loading sub-categories for all categories...');
      isSubcategoryLoading.value = true;

      // Clear existing subcategories
      subcategoriesMap.clear();

      for (final category in featuredCategories) {
        if (category.id != null) {
          try {
            print(
                '[MART CONTROLLER] 🔄 Loading subcategories for category: ${category.title} (ID: ${category.id})');
            await loadSubcategoriesForCategory(category.id!);
          } catch (e) {
            print(
                '[MART CONTROLLER] ⚠️ Error loading subcategories for ${category.title}: $e');
          }
        }
      }

      print(
          '[MART CONTROLLER] ✅ Sub-categories loading completed. Total categories processed: ${featuredCategories.length}');
      print(
          '[MART CONTROLLER] 📊 Subcategories map contains: ${subcategoriesMap.length} category entries');
      subcategoriesMap.forEach((categoryId, subcategoryList) {
        print(
            '[MART CONTROLLER] 📊 Category $categoryId: ${subcategoryList.length} subcategories');
      });
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading sub-categories: $e');
    } finally {
      isSubcategoryLoading.value = false;
    }
  }

  /// Load all homepage subcategories directly from Firestore
  Future<void> loadAllHomepageSubcategories() async {
    try {
      print(
          '[MART CONTROLLER] 🔄 Loading all homepage subcategories directly from Firestore...');
      isSubcategoryLoading.value = true;

      // Clear existing subcategories
      subcategoriesMap.clear();

      // Get all homepage subcategories directly
      final allSubcategories =
          await _firestoreService.getAllHomepageSubcategories();

      if (allSubcategories.isNotEmpty) {
        // Group subcategories by parent category for the map
        final Map<String, List<MartSubcategoryModel>> groupedSubcategories = {};

        for (final subcategory in allSubcategories) {
          final parentId = subcategory.parentCategoryId ?? 'unknown';
          if (!groupedSubcategories.containsKey(parentId)) {
            groupedSubcategories[parentId] = [];
          }
          groupedSubcategories[parentId]!.add(subcategory);
        }

        // Update the subcategories map
        subcategoriesMap.addAll(groupedSubcategories);

        print(
            '[MART CONTROLLER] ✅ Loaded ${allSubcategories.length} homepage subcategories from ${groupedSubcategories.length} parent categories');
        print(
            '[MART CONTROLLER] 📊 Subcategories map contains: ${subcategoriesMap.length} category entries');
        subcategoriesMap.forEach((categoryId, subcategoryList) {
          print(
              '[MART CONTROLLER] 📊 Category $categoryId: ${subcategoryList.length} subcategories');
        });

        // Force UI update
        subcategoriesMap.refresh();
      } else {
        print('[MART CONTROLLER] ⚠️ No homepage subcategories found');
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading homepage subcategories: $e');
    } finally {
      isSubcategoryLoading.value = false;
    }
  }

  /// Debug method to load ALL subcategories (no filters)
  Future<void> loadAllSubcategoriesDebug() async {
    try {
      print(
          '[MART CONTROLLER] 🔍 DEBUG: Loading ALL subcategories from Firestore (no filters)...');
      isSubcategoryLoading.value = true;

      // Clear existing subcategories
      subcategoriesMap.clear();

      // Get all subcategories directly (no filters)
      final allSubcategories =
          await _firestoreService.getAllSubcategoriesDebug();

      if (allSubcategories.isNotEmpty) {
        // Group subcategories by parent category for the map
        final Map<String, List<MartSubcategoryModel>> groupedSubcategories = {};

        for (final subcategory in allSubcategories) {
          final parentId = subcategory.parentCategoryId ?? 'unknown';
          if (!groupedSubcategories.containsKey(parentId)) {
            groupedSubcategories[parentId] = [];
          }
          groupedSubcategories[parentId]!.add(subcategory);
        }

        // Update the subcategories map
        subcategoriesMap.addAll(groupedSubcategories);

        print(
            '[MART CONTROLLER] 🔍 DEBUG: Loaded ${allSubcategories.length} total subcategories from ${groupedSubcategories.length} parent categories');
        print(
            '[MART CONTROLLER] 🔍 DEBUG: Subcategories map contains: ${subcategoriesMap.length} category entries');
        subcategoriesMap.forEach((categoryId, subcategoryList) {
          print(
              '[MART CONTROLLER] 🔍 DEBUG: Category $categoryId: ${subcategoryList.length} subcategories');
        });

        // Force UI update
        subcategoriesMap.refresh();
      } else {
        print('[MART CONTROLLER] 🔍 DEBUG: No subcategories found at all');
      }
    } catch (e) {
      print('[MART CONTROLLER] 🔍 DEBUG: Error loading all subcategories: $e');
    } finally {
      isSubcategoryLoading.value = false;
    }
  }

  /// Load sub-categories for a specific category
  Future<void> loadSubcategoriesForCategory(String categoryId) async {
    try {
      print(
          '[MART CONTROLLER] 🔄 Loading sub-categories for category: $categoryId');

      final subcategories = await _firestoreService.getSubcategoriesByParent(
        parentCategoryId: categoryId,
        publish: true,
        sortBy: 'subcategory_order',
        sortOrder: 'asc',
      );

      subcategoriesMap[categoryId] = subcategories;
      print(
          '[MART CONTROLLER] ✅ Loaded ${subcategories.length} sub-categories for category: $categoryId');
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Error loading sub-categories for category $categoryId: $e');
      subcategoriesMap[categoryId] = [];
    }
  }

  /// Load vendor-specific categories
  Future<void> loadVendorCategories(String vendorId) async {
    try {
      isCategoryLoading.value = true;
      errorMessage.value = "";

      final categories =
          await _firestoreService.getPublishedCategories(martId: vendorId);
      martCategories.clear();
      martCategories.addAll(categories);

      // Reset category selection
      if (categories.isNotEmpty) {
        final firstCategory = categories.first;
        if (firstCategory.id != null) {
          selectCategory(firstCategory.id!);
        }
      } else {
        selectedCategoryId.value = "";
        currentCategory.value = null;
      }
    } catch (e) {
      print('[MART] Error loading vendor categories: $e');
      errorMessage.value = "Failed to load vendor categories: $e";
    } finally {
      isCategoryLoading.value = false;
    }
  }

  /// Select a category
  void selectCategory(String categoryId) {
    selectedCategoryId.value = categoryId;
    currentCategory.value =
        martCategories.firstWhereOrNull((c) => c.id == categoryId);

    // Load category items
    loadCategoryItems(categoryId);
  }

  /// Load featured categories
  Future<void> loadFeaturedCategories() async {
    try {
      final categories = await _firestoreService.getFeaturedCategories(
        martId:
            selectedVendorId.value.isNotEmpty ? selectedVendorId.value : null,
      );
      featuredCategories.clear();
      featuredCategories.addAll(categories);
    } catch (e) {
      print('[MART] Error loading featured categories: $e');
    }
  }

  // ==================== MART ITEMS ====================

  /// Load mart items
  Future<void> loadMartItems({bool refresh = false}) async {
    try {
      isProductLoading.value = true;
      errorMessage.value = "";

      if (refresh) {
        martItems.clear();
        filteredItems.clear();
        currentPage = 1;
        hasMoreItems.value = true;
      }

      print('[MART] Loading mart items...');

      if (selectedVendorId.value.isEmpty) {
        print('[MART] No vendor selected, skipping item load');
        return;
      }

      final items = await _firestoreService.getMartItems(
        search: null,
        limit: itemsPerPage,
      );

      if (refresh) {
        martItems.clear();
        filteredItems.clear();
      }

      martItems.addAll(items);
      filteredItems.addAll(items);
      hasMoreItems.value = items.length == itemsPerPage;

      print('[MART] Loaded ${items.length} items');
    } catch (e) {
      print('[MART] Error loading items: $e');
      errorMessage.value = "Failed to load items: $e";
    } finally {
      isProductLoading.value = false;
    }
  }

  /// Load vendor-specific items
  Future<void> loadVendorItems(String vendorId) async {
    try {
      isProductLoading.value = true;
      errorMessage.value = "";

      final items = await _firestoreService.getItemsByVendor(
        vendorId: vendorId,
        categoryId: selectedCategoryId.value.isNotEmpty
            ? selectedCategoryId.value
            : null,
        limit: itemsPerPage,
      );

      martItems.clear();
      filteredItems.clear();
      martItems.addAll(items);
      filteredItems.addAll(items);
      hasMoreItems.value = items.length == itemsPerPage;
      currentPage = 1;
    } catch (e) {
      print('[MART] Error loading vendor items: $e');
      errorMessage.value = "Failed to load vendor items: $e";
    } finally {
      isProductLoading.value = false;
    }
  }

  /// Load category-specific items
  Future<void> loadCategoryItems(String categoryId) async {
    try {
      isProductLoading.value = true;
      errorMessage.value = "";

      print(
          '[MART CONTROLLER] 📂 loadCategoryItems() called for category: $categoryId');

      // Load items for the category without requiring a specific vendor
      final items = await _firestoreService.getItemsByCategoryOnly(
        categoryId: categoryId,
        isAvailable: true,
        limit: 50,
      );

      print(
          '[MART CONTROLLER] ✅ Loaded ${items.length} items for category $categoryId');

      // Clear existing items and add new ones
      martItems.clear();
      filteredItems.clear();
      martItems.addAll(items);
      filteredItems.addAll(items);

      // Update selected category
      selectedCategoryId.value = categoryId;
      currentCategory.value =
          martCategories.firstWhereOrNull((c) => c.id == categoryId);

      print(
          '[MART CONTROLLER] ✅ Category items loading completed successfully');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading category items: $e');
      errorMessage.value = "Unable to load products. Please try again later.";
    } finally {
      isProductLoading.value = false;
    }
  }

  /// Load more items (pagination)
  Future<void> loadMoreItems() async {
    if (!hasMoreItems.value || isProductLoading.value) return;

    currentPage++;
    await loadMartItems();
  }

  /// Load featured items
  Future<void> loadFeaturedItems() async {
    try {
      if (selectedVendorId.value.isEmpty) {
        print('[MART] No vendor selected, skipping featured items load');
        return;
      }

      final items = await _firestoreService.getFeaturedItems(
        limit: 20,
      );
      featuredItems.clear();
      featuredItems.addAll(items);
    } catch (e) {
      print('[MART] Error loading featured items: $e');
    }
  }

  /// Load items on sale
  Future<void> loadItemsOnSale() async {
    try {
      if (selectedVendorId.value.isEmpty) {
        print('[MART] No vendor selected, skipping items on sale load');
        return;
      }

      final items = await _firestoreService.getItemsOnSale(
        limit: 20,
      );
      itemsOnSale.clear();
      itemsOnSale.addAll(items);
    } catch (e) {
      print('[MART] Error loading items on sale: $e');
    }
  }

  // ==================== LEGACY METHODS (for backward compatibility) ====================

  /// Load products by category (legacy method)
  Future<void> loadProductsByCategory(String categoryId,
      {bool refresh = false}) async {
    selectCategory(categoryId);
  }

  /// Load spotlight items (legacy method)
  Future<void> loadSpotlightItems() async {
    try {
      // For now, we'll use featured items as spotlight items
      await loadFeaturedItems();
      spotlightItems.clear();
      spotlightItems.addAll(featuredItems
          .map((item) => {
                'id': item.id,
                'name': item.displayName,
                'image': item.mainImage,
                'price': item.currentPrice,
                'description': item.displayDescription,
              })
          .toList());
    } catch (e) {
      print('[MART] Error loading spotlight items: $e');
    }
  }

  /// Load steals items (legacy method)
  Future<void> loadStealsItems() async {
    try {
      // For now, we'll use items on sale as steals items
      await loadItemsOnSale();
      stealsItems.clear();
      stealsItems.addAll(itemsOnSale
          .map((item) => {
                'id': item.id,
                'name': item.displayName,
                'image': item.mainImage,
                'price': item.currentPrice,
                'originalPrice': item.originalPrice,
                'discount': item.calculatedDiscountPercentage,
                'description': item.displayDescription,
              })
          .toList());
    } catch (e) {
      print('[MART] Error loading steals items: $e');
    }
  }

  // ==================== SEARCH AND FILTERS ====================

  /// Perform search
  Future<void> performSearch() async {
    if (searchQuery.value.isEmpty) return;

    try {
      isProductLoading.value = true;
      errorMessage.value = "";

      if (selectedVendorId.value.isEmpty) {
        print('[MART] No vendor selected, cannot search items');
        errorMessage.value = "Please select a vendor first";
        return;
      }

      final items = await _firestoreService.searchItems(
        searchQuery: searchQuery.value,
        limit: itemsPerPage,
      );

      filteredItems.clear();
      filteredItems.addAll(items);
    } catch (e) {
      print('[MART] Error searching items: $e');
      errorMessage.value = "Failed to search items: $e";
    } finally {
      isProductLoading.value = false;
    }
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = "";
    filteredItems.clear();
    filteredItems.addAll(martItems);
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    _searchDebouncer?.cancel();
    setupSearchListener();
  }

  /// Apply filters
  void applyFilters({
    bool? vegOnly,
    bool? nonVegOnly,
    bool? availableOnly,
    String? sortBy,
    bool? sortAscending,
  }) {
    if (vegOnly != null) filterVegOnly.value = vegOnly;
    if (nonVegOnly != null) filterNonVegOnly.value = nonVegOnly;
    if (availableOnly != null) filterAvailableOnly.value = availableOnly;
    if (sortBy != null) selectedSortBy.value = sortBy;
    if (sortAscending != null) this.sortAscending.value = sortAscending;

    // Reload items with new filters
    loadMartItems(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    filterVegOnly.value = false;
    filterNonVegOnly.value = false;
    filterAvailableOnly.value = true;
    selectedSortBy.value = "name";
    sortAscending.value = true;

    loadMartItems(refresh: true);
  }

  // ==================== UTILITY METHODS ====================

  /// Refresh all data
  Future<void> refreshData() async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🔄 refreshData() called');
      print('[MART CONTROLLER] ==========================================');

      isLoading.value = true;
      errorMessage.value = "";

      // Reset homepage categories flag to allow reloading
      isHomepageCategoriesLoaded.value = false;

      await Future.wait([
        loadMartVendors(refresh: true),
        loadHomepageCategoriesStreaming(limit: 10),
        loadFeaturedItems(),
        loadItemsOnSale(),
        loadFeaturedCategories(),
        loadSpotlightItems(),
        loadStealsItems(),
      ]);
    } catch (e) {
      print('[MART] Error refreshing data: $e');
      errorMessage.value = "Failed to refresh data: $e";
    } finally {
      isLoading.value = false;
    }
  }

  /// Get item by ID
  Future<MartItemModel?> getItemById(String itemId) async {
    try {
      return await _firestoreService.getItemById(itemId);
    } catch (e) {
      print('[MART] Error getting item by ID: $e');
      return null;
    }
  }

  /// Get vendor details
  Future<MartVendorModel?> getVendorDetails(String vendorId) async {
    try {
      return await _firestoreService.getMartVendorDetails(vendorId);
    } catch (e) {
      print('[MART] Error getting vendor details: $e');
      return null;
    }
  }

  /// Get category details
  Future<MartCategoryModel?> getCategoryDetails(String categoryId) async {
    try {
      return await _firestoreService.getCategoryDetails(categoryId);
    } catch (e) {
      print('[MART] Error getting category details: $e');
      return null;
    }
  }

  // ==================== LEGACY COMPATIBILITY METHODS ====================

  /// Add to cart (legacy method)
  void addToCart(MartItemModel item, {int quantity = 1}) {
    final existingIndex =
        cartItems.indexWhere((cartItem) => cartItem.id == item.id);

    if (existingIndex >= 0) {
      // Update quantity if already in cart
      // For now, we'll just add another instance
      cartItems.add(item);
    } else {
      cartItems.add(item);
    }

    print(
        '[MART] Added ${item.displayName} to cart. Total items: ${cartItems.length}');
  }

  /// Remove from cart (legacy method)
  void removeFromCart(String itemId) {
    cartItems.removeWhere((item) => item.id == itemId);
    print(
        '[MART] Removed item $itemId from cart. Total items: ${cartItems.length}');
  }

  /// Clear cart (legacy method)
  void clearCart() {
    cartItems.clear();
    print('[MART] Cart cleared');
  }

  /// Update sort (legacy method)
  void updateSort(String sortBy, bool ascending) {
    selectedSortBy.value = sortBy;
    sortAscending.value = ascending;
    loadMartItems(refresh: true);
  }

  // ==================== GETTERS ====================

  /// Get current vendor name
  String get currentVendorName =>
      currentVendor.value?.displayName ?? 'All Marts';

  /// Get current category name
  String get currentCategoryName =>
      currentCategory.value?.displayName ?? 'All Categories';

  /// Get total items count
  int get totalItemsCount => filteredItems.length;

  /// Get total vendors count
  int get totalVendorsCount => martVendors.length;

  /// Get total categories count
  int get totalCategoriesCount => martCategories.length;

  /// Check if any filters are active
  bool get hasActiveFilters =>
      filterVegOnly.value ||
      filterNonVegOnly.value ||
      !filterAvailableOnly.value ||
      searchQuery.value.isNotEmpty;

  // ==================== LEGACY COMPATIBILITY GETTERS ====================

  /// Legacy: filteredProducts (maps to filteredItems)
  List<MartItemModel> get filteredProducts => filteredItems;

  /// Legacy: hasMoreProducts (maps to hasMoreItems)
  RxBool get hasMoreProducts => hasMoreItems;

  /// Legacy: loadMoreProducts (maps to loadMoreItems)
  Future<void> loadMoreProducts() => loadMoreItems();

  /// Legacy: cartItemCount
  int get cartItemCount => cartItems.length;

  /// Legacy: cartTotal
  double get cartTotal {
    return cartItems.fold(0.0, (total, item) {
      return total + item.currentPrice;
    });
  }

  /// Legacy: getProductById (maps to getItemById)
  Future<MartItemModel?> getProductById(String productId) async {
    return await getItemById(productId);
  }

  /// Legacy: getCategoryById
  MartCategoryModel? getCategoryById(String categoryId) {
    try {
      return martCategories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Retry vendor loading in background
  Future<void> retryVendorLoading() async {
    try {
      print('[MART CONTROLLER] 🔄 Retrying vendor loading in background...');

      // Clear any vendor-related error messages
      if (errorMessage.value.contains("Vendor loading timed out") ||
          errorMessage.value.contains("No vendors available")) {
        errorMessage.value = "";
      }

      // Try to load vendors in background
      await loadMartVendors(refresh: true);

      if (martVendors.isNotEmpty) {
        print(
            '[MART CONTROLLER] ✅ Vendor retry successful: ${martVendors.length} vendors found');
        // Load additional data if vendors are now available
        await loadFeaturedItems();
        await loadItemsOnSale();
      } else {
        print(
            '[MART CONTROLLER] ⚠️ Vendor retry completed but no vendors found');
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Vendor retry failed: $e');
      // Don't show error message, let categories continue working
    }
  }

  // ==================== ENHANCED API METHODS ====================

  /// Load mart categories with enhanced filtering and sorting
  Future<void> loadMartCategoriesEnhanced({
    bool refresh = false,
    String? martId,
    bool? publish,
    bool? showInHomepage,
    bool? hasSubcategories,
    String? search,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 📂 loadMartCategoriesEnhanced() called');
      print(
          '[MART CONTROLLER] 📋 Parameters: refresh=$refresh, martId=$martId, publish=$publish');
      print(
          '[MART CONTROLLER] 📋 Parameters: showInHomepage=$showInHomepage, hasSubcategories=$hasSubcategories');
      print(
          '[MART CONTROLLER] 📋 Parameters: search=$search, sortBy=$sortBy, sortOrder=$sortOrder');
      print('[MART CONTROLLER] 📋 Parameters: page=$page, limit=$limit');
      print('[MART CONTROLLER] ==========================================');

      if (refresh) {
        print(
            '[MART CONTROLLER] 🔄 Refresh mode - clearing existing categories');
        martCategories.clear();
      }

      isCategoryLoading.value = true;
      errorMessage.value = '';

      List<MartCategoryModel> categories;

      // Use appropriate API method based on parameters
      if (search != null && search.isNotEmpty) {
        print('[MART CONTROLLER] 🔍 Using REST API for search query: $search');
        // Use REST API for search instead of Firestore
        try {
          final uri =
              Uri.parse('https://jippymart.in/api/search/categories').replace(
            queryParameters: {
              'q': search,
              'limit': limit.toString(),
            },
          );

          final response = await http.get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['success'] == true) {
              final categoriesList = (data['data'] as List);
              categories = categoriesList
                  .map((cat) => MartCategoryModel.fromJson(cat))
                  .toList();
              print(
                  '[MART CONTROLLER] ✅ API search returned ${categories.length} categories');
            } else {
              categories = [];
              print(
                  '[MART CONTROLLER] ⚠️ API returned success=false: ${data['message']}');
            }
          } else {
            categories = [];
            print(
                '[MART CONTROLLER] ❌ API request failed with status: ${response.statusCode}');
          }
        } catch (e) {
          print(
              '[MART CONTROLLER] ❌ API search failed: $e, falling back to Firestore');
          // Fallback to Firestore if API fails
          categories = await _firestoreService.getFilteredCategories(
            search: search,
            limit: limit,
          );
        }
      } else if (hasSubcategories == true) {
        print('[MART CONTROLLER] 📂 Using categories with subcategories API');
        categories = await _firestoreService.getCategoriesWithSubcategories(
          limit: limit,
        );
      } else {
        print('[MART CONTROLLER] 📞 Using filtered categories API');
        categories = await _firestoreService.getFilteredCategories(
          search: search,
          limit: limit,
        );
      }

      if (categories.isNotEmpty) {
        // ✅ Load categories FIRST - show them immediately
        if (page == 1) {
          martCategories.assignAll(categories);
        } else {
          martCategories.addAll(categories);
        }
        print(
            '[MART CONTROLLER] ✅ Categories loaded successfully: ${categories.length} categories');

        // ✅ Set loading to false immediately after categories are loaded
        isCategoryLoading.value = false;

        // 🔄 Load item counts in background (non-blocking)
        _loadItemCountsInBackground(categories.take(3).toList());
      } else {
        errorMessage.value = 'No categories found.';
        print('[MART CONTROLLER] ⚠️ No categories found');
        isCategoryLoading.value = false;
      }
    } catch (e) {
      isCategoryLoading.value = false;
      errorMessage.value = 'Unable to load categories. Please try again later.';
      print('[MART CONTROLLER] ❌ Error loading categories: $e');
    }
  }

  /// Load homepage categories (optimized for homepage display)
  Future<void> loadHomepageCategories({int limit = 10}) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🏠 loadHomepageCategories() called');
      print('[MART CONTROLLER] 📋 Parameters: limit=$limit');
      print(
          '[MART CONTROLLER] 🔍 Already loaded: ${isHomepageCategoriesLoaded.value}');
      print(
          '[MART CONTROLLER] 🔍 Currently loading: ${isCategoryLoading.value}');
      print('[MART CONTROLLER] ==========================================');

      // Prevent multiple simultaneous calls
      if (isCategoryLoading.value) {
        print('[MART CONTROLLER] ⚠️ Already loading categories, skipping...');
        return;
      }

      // If already loaded and we have categories, don't reload
      if (isHomepageCategoriesLoaded.value && featuredCategories.isNotEmpty) {
        print('[MART CONTROLLER] ✅ Categories already loaded, skipping...');
        return;
      }

      isCategoryLoading.value = true;
      errorMessage.value = '';

      print(
          '[MART CONTROLLER] 📞 Calling _martService.getHomepageCategories()...');
      final categories =
          await _firestoreService.getHomepageCategories(limit: limit);

      if (categories.isNotEmpty) {
        // Filter for categories that should be shown on homepage
        final homepageCategories = categories
            .where((category) =>
                category.showInHomepage == true && category.publish == true)
            .toList();

        if (homepageCategories.isNotEmpty) {
          featuredCategories.assignAll(homepageCategories);
          print(
              '[MART CONTROLLER] ✅ Homepage categories loaded successfully: ${homepageCategories.length} categories');
        } else {
          // If no homepage categories, use all categories
          featuredCategories.assignAll(categories);
          print(
              '[MART CONTROLLER] ⚠️ No homepage categories found, using all categories: ${categories.length} categories');
        }
      } else {
        print('[MART CONTROLLER] ⚠️ No categories found at all');
      }

      // Mark as loaded
      isHomepageCategoriesLoaded.value = true;
      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      isHomepageCategoriesLoaded.value = false; // Reset flag on error
      errorMessage.value =
          'Unable to load homepage categories. Please try again later.';
      print('[MART CONTROLLER] ❌ Error loading homepage categories: $e');
    }
  }

  /// Load trending items from API
  Future<void> loadTrendingItems() async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🚀 loadTrendingItems() called');
      print('[MART CONTROLLER] ==========================================');

      // Prevent multiple simultaneous calls
      if (isTrendingLoading.value) {
        print(
            '[MART CONTROLLER] ⚠️ Already loading trending items, skipping...');
        return;
      }

      isTrendingLoading.value = true;
      errorMessage.value = '';

      print(
          '[MART CONTROLLER] 📞 Calling _firestoreService.getTrendingItems()...');
      final items = await _firestoreService.getTrendingItems();

      if (items.isNotEmpty) {
        trendingItems.assignAll(items);
        print(
            '[MART CONTROLLER] ✅ Trending items loaded successfully: ${items.length} items');

        // Log the isTrending status of loaded items
        final trendingCount =
            items.where((item) => item.isTrending == true).length;
        print(
            '[MART CONTROLLER] 📊 Loaded items breakdown: ${trendingCount} trending out of ${items.length} total');
      } else {
        trendingItems.clear();
        print('[MART CONTROLLER] ⚠️ No trending items found from API');
      }

      isTrendingLoading.value = false;
    } catch (e) {
      isTrendingLoading.value = false;
      errorMessage.value =
          'Unable to load trending items. Please try again later.';
      print('[MART CONTROLLER] ❌ Error loading trending items: $e');
    }
  }

  /// Comprehensive search across categories, items, and subcategories
  Future<Map<String, dynamic>> performComprehensiveSearch(String query) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🔍 performComprehensiveSearch() called');
      print('[MART CONTROLLER] 📋 Query: $query');
      print('[MART CONTROLLER] ==========================================');

      if (query.isEmpty) {
        return {
          'categories': <MartCategoryModel>[],
          'items': <MartItemModel>[],
          'subcategories': <MartSubcategoryModel>[],
        };
      }

      if (query.length < 2) {
        print(
            '[MART CONTROLLER] ⚠️ Search query too short (minimum 2 characters)');
        return {
          'categories': <MartCategoryModel>[],
          'items': <MartItemModel>[],
          'subcategories': <MartSubcategoryModel>[],
        };
      }

      // Perform parallel searches
      final futures = await Future.wait([
        _firestoreService.searchCategories(searchQuery: query, limit: 10),
        _firestoreService.searchItems(searchQuery: query, limit: 20),
        _firestoreService.searchSubcategories(searchQuery: query, limit: 10),
      ]);

      final categories = futures[0] as List<MartCategoryModel>;
      final items = futures[1] as List<MartItemModel>;
      final subcategories = futures[2] as List<MartSubcategoryModel>;

      print('[MART CONTROLLER] ✅ Comprehensive search completed:');
      print('[MART CONTROLLER]   - Categories: ${categories.length}');
      print('[MART CONTROLLER]   - Items: ${items.length}');
      print('[MART CONTROLLER]   - Subcategories: ${subcategories.length}');

      return {
        'categories': categories,
        'items': items,
        'subcategories': subcategories,
      };
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error in comprehensive search: $e');
      return {
        'categories': <MartCategoryModel>[],
        'items': <MartItemModel>[],
        'subcategories': <MartSubcategoryModel>[],
      };
    }
  }

  /// Search categories with debouncing
  Future<void> searchCategories(String query) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🔍 searchCategories() called');
      print('[MART CONTROLLER] 📋 Query: $query');
      print('[MART CONTROLLER] ==========================================');

      if (query.isEmpty) {
        // If search is empty, load all categories from Firestore
        await loadCategoriesStreaming();
        return;
      }

      if (query.length < 2) {
        print(
            '[MART CONTROLLER] ⚠️ Search query too short (minimum 2 characters)');
        return;
      }

      isCategoryLoading.value = true;
      errorMessage.value = '';

      print(
          '[MART CONTROLLER] 📞 Calling _firestoreService.searchCategories()...');
      final categories = await _firestoreService.searchCategories(
        searchQuery: query,
        limit: 20,
      );

      if (categories.isNotEmpty) {
        martCategories.assignAll(categories);
        print(
            '[MART CONTROLLER] ✅ Search results loaded: ${categories.length} categories');
      } else {
        martCategories.clear();
        print('[MART CONTROLLER] ⚠️ No search results found');
      }

      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      errorMessage.value = 'Search failed. Please try again later.';
      print('[MART CONTROLLER] ❌ Error searching categories: $e');
    }
  }

  /// Load categories with subcategories
  Future<void> loadCategoriesWithSubcategories({
    bool? publish,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 📂 loadCategoriesWithSubcategories() called');
      print(
          '[MART CONTROLLER] 📋 Parameters: publish=$publish, page=$page, limit=$limit');
      print('[MART CONTROLLER] ==========================================');

      isCategoryLoading.value = true;
      errorMessage.value = '';

      print(
          '[MART CONTROLLER] 📞 Calling _firestoreService.getCategoriesWithSubcategories()...');
      final categories = await _firestoreService.getCategoriesWithSubcategories(
        limit: limit,
      );

      if (categories.isNotEmpty) {
        if (page == 1) {
          martCategories.assignAll(categories);
        } else {
          martCategories.addAll(categories);
        }
        print(
            '[MART CONTROLLER] ✅ Categories with subcategories loaded: ${categories.length} categories');
      } else {
        print('[MART CONTROLLER] ⚠️ No categories with subcategories found');
      }

      isCategoryLoading.value = false;
    } catch (e) {
      isCategoryLoading.value = false;
      errorMessage.value = 'Unable to load categories. Please try again later.';
      print(
          '[MART CONTROLLER] ❌ Error loading categories with subcategories: $e');
    }
  }

  /// Load more categories (pagination)
  Future<void> loadMoreCategories({
    String? martId,
    bool? publish,
    bool? showInHomepage,
    bool? hasSubcategories,
    String? search,
    String? sortBy,
    String? sortOrder,
    int limit = 20,
  }) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 📄 loadMoreCategories() called');
      print('[MART CONTROLLER] 📋 Current page: $currentPage');
      print('[MART CONTROLLER] ==========================================');

      currentPage++;

      // For now, use the streaming method instead of pagination
      await loadCategoriesStreaming();

      print('[MART CONTROLLER] ✅ More categories loaded successfully');
    } catch (e) {
      currentPage--; // Revert page number on error
      print('[MART CONTROLLER] ❌ Error loading more categories: $e');
      errorMessage.value =
          'Unable to load more categories. Please try again later.';
    }
  }

  /// Reset pagination
  void resetPagination() {
    currentPage = 1;
    print('[MART CONTROLLER] 🔄 Pagination reset to page 1');
  }

  /// Filter categories by various criteria
  void filterCategories({
    String? searchQuery,
    bool? publish,
    bool? showInHomepage,
    bool? hasSubcategories,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 🔍 filterCategories() called');
      print(
          '[MART CONTROLLER] 📋 Parameters: searchQuery=$searchQuery, publish=$publish');
      print(
          '[MART CONTROLLER] 📋 Parameters: showInHomepage=$showInHomepage, hasSubcategories=$hasSubcategories');
      print(
          '[MART CONTROLLER] 📋 Parameters: sortBy=$sortBy, sortOrder=$sortOrder');
      print('[MART CONTROLLER] ==========================================');

      // Reset pagination for new filter
      resetPagination();

      // Update search query
      this.searchQuery.value = searchQuery ?? '';

      // Load filtered categories from Firestore
      await loadCategoriesStreaming();

      print('[MART CONTROLLER] ✅ Categories filtered successfully');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error filtering categories: $e');
      errorMessage.value =
          'Unable to filter categories. Please try again later.';
    }
  }

  /// Get category by ID from API
  Future<MartCategoryModel?> getCategoryByIdFromAPI(String categoryId) async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print('[MART CONTROLLER] 📄 getCategoryByIdFromAPI() called');
      print('[MART CONTROLLER] 📋 Parameters: categoryId=$categoryId');
      print('[MART CONTROLLER] ==========================================');

      print(
          '[MART CONTROLLER] 📞 Calling _firestoreService.getCategoryById()...');
      final category = await _firestoreService.getCategoryById(categoryId);

      if (category != null) {
        print(
            '[MART CONTROLLER] ✅ Category loaded successfully: ${category.title}');
        return category;
      } else {
        print('[MART CONTROLLER] ⚠️ Category not found: $categoryId');
        return null;
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error getting category by ID: $e');
      errorMessage.value = 'Unable to load category. Please try again later.';
      return null;
    }
  }

  // ==================== STREAMING DATA LOADING METHODS ====================

  /// Load homepage categories with streaming updates using Firestore
  Future<void> loadHomepageCategoriesStreaming({int limit = 10}) async {
    try {
      print(
          '[MART CONTROLLER] 🏠 Streaming: Loading homepage categories from Firestore...');
      isCategoryLoading.value = true;

      // Try Firestore first (fastest path)
      try {
        print(
            '[MART CONTROLLER] 🔥 Calling Firestore service for homepage categories...');
        final categories =
            await _firestoreService.getHomepageCategories(limit: limit);

        if (categories.isNotEmpty) {
          // Stream the data as it becomes available
          featuredCategories.clear();
          featuredCategories.addAll(categories);

          // Clear any previous error messages
          errorMessage.value = '';

          print(
              '[MART CONTROLLER] ✅ Streaming: Homepage categories loaded from Firestore (${categories.length})');
          isCategoryLoading.value = false;
          isHomepageCategoriesLoaded.value = true;
          return;
        } else {
          print('[MART CONTROLLER] ⚠️ No homepage categories from Firestore');
        }
      } catch (e) {
        print(
            '[MART CONTROLLER] ❌ Firestore failed: $e, trying API fallback...');
      }

      // No API fallback - Firestore only
      print('[MART CONTROLLER] ❌ Firestore failed, no API fallback available');
      errorMessage.value =
          'Unable to load categories from Firestore. Please check your connection.';
      isCategoryLoading.value = false;
      isHomepageCategoriesLoaded.value = false;
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Streaming: Error loading homepage categories: $e');
      isCategoryLoading.value = false;
    }
  }

  /// Load trending items with streaming updates using Firestore
  Future<void> loadTrendingItemsStreaming() async {
    try {
      print(
          '[MART CONTROLLER] 🔥 Streaming: Loading trending items from Firestore...');
      isTrendingLoading.value = true;

      // Try to get trending items from existing data first (fastest)
      if (martItems.isNotEmpty) {
        print(
            '[MART CONTROLLER] 🚀 Fast path: Filtering trending items from existing data');
        final trendingFromExisting =
            martItems.where((item) => item.isTrending == true).toList();
        if (trendingFromExisting.isNotEmpty) {
          trendingItems.clear();
          trendingItems.addAll(trendingFromExisting);
          print(
              '[MART CONTROLLER] ✅ Fast path: Found ${trendingFromExisting.length} trending items from existing data');
          isTrendingLoading.value = false;
          return;
        }
      }

      // Load trending items from Firestore (primary method)
      print('[MART CONTROLLER] 🔥 Firestore: Fetching trending items...');
      try {
        final items = await _firestoreService.getTrendingItems(limit: 20);

        if (items.isNotEmpty) {
          // Stream the data as it becomes available
          trendingItems.clear();
          trendingItems.addAll(items);
          print(
              '[MART CONTROLLER] ✅ Firestore: Trending items loaded (${items.length})');
        } else {
          // Fallback: Load all items and filter for trending
          print(
              '[MART CONTROLLER] 🔄 Fallback: Loading all items and filtering for trending...');
          await _loadAllItemsAndFilterTrending();
        }
      } catch (e) {
        print('[MART CONTROLLER] ❌ Firestore failed: $e');
        // No API fallback - Firestore only
        print(
            '[MART CONTROLLER] ❌ No API fallback available for trending items');
        trendingItems.clear();
      }

      isTrendingLoading.value = false;
    } catch (e) {
      print('[MART CONTROLLER] ❌ Streaming: Error loading trending items: $e');
      // No API fallback - Firestore only
      print('[MART CONTROLLER] ❌ No API fallback available for trending items');
      trendingItems.clear();
      isTrendingLoading.value = false;
    }
  }

  /// Fast fallback: Load all items and filter for trending
  Future<void> _loadAllItemsAndFilterTrending() async {
    try {
      print('[MART CONTROLLER] 🔄 Fallback: Loading all items...');

      // Load items with API-compliant limit to avoid validation errors
      final allItems = await _firestoreService.getMartItems(
        search: null,
        limit: 50, // API requires limit <= 50
      );

      // Filter for trending items
      final trendingFromAll =
          allItems.where((item) => item.isTrending == true).toList();

      // Update trending items
      trendingItems.clear();
      trendingItems.addAll(trendingFromAll);

      print(
          '[MART CONTROLLER] ✅ Fallback: Found ${trendingFromAll.length} trending items from all items');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Fallback: Error loading all items: $e');
      trendingItems.clear();
    }
  }

  /// Test if trending endpoint is working
  Future<bool> _testTrendingEndpoint() async {
    try {
      print(
          '[MART CONTROLLER] 🔍 Testing trending endpoint: Firestore collection mart_items');

      // Use the service to test the endpoint instead of direct HTTP call
      try {
        final items = await _firestoreService.getTrendingItems();
        print(
            '[MART CONTROLLER] ✅ Trending endpoint is working - returned ${items.length} items');
        return true;
      } catch (e) {
        if (e.toString().contains('timeout') || e.toString().contains('slow')) {
          print(
              '[MART CONTROLLER] ⏰ Trending endpoint is slow - will use fallback');
          return false;
        } else {
          print('[MART CONTROLLER] ❌ Trending endpoint error: $e');
          return false;
        }
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Trending endpoint test failed: $e');
      return false;
    }
  }

  /// Preload items for trending fallback (runs in background)
  Future<void> _preloadItemsForTrending() async {
    try {
      print('[MART CONTROLLER] 📦 Preloading items for trending fallback...');

      // Load items in background without blocking UI
      final allItems = await _firestoreService.getMartItems(
        search: null,
        limit: 50, // API-compliant limit
      );

      // Store items for potential trending fallback
      martItems.clear();
      martItems.addAll(allItems);

      print(
          '[MART CONTROLLER] ✅ Preloaded ${allItems.length} items for trending fallback');

      // If we have items, check if any are trending
      final trendingFromPreloaded =
          allItems.where((item) => item.isTrending == true).toList();
      if (trendingFromPreloaded.isNotEmpty && trendingItems.isEmpty) {
        print(
            '[MART CONTROLLER] 🎯 Found ${trendingFromPreloaded.length} trending items from preloaded data');
        trendingItems.clear();
        trendingItems.addAll(trendingFromPreloaded);
      }
    } catch (e) {
      print('[MART CONTROLLER] ⚠️ Preloading failed (non-critical): $e');
      // Don't show error - this is background loading
    }
  }

  /// Load featured items with streaming updates using Firestore
  Future<void> loadFeaturedItemsStreaming() async {
    try {
      print(
          '[MART CONTROLLER] ⭐ Streaming: Loading featured items from Firestore...');
      isProductLoading.value = true;

      // Load featured items from Firestore
      final items = await _firestoreService.getFeaturedItems(limit: 20);

      // Stream the data as it becomes available
      featuredItems.clear();
      featuredItems.addAll(items);

      print(
          '[MART CONTROLLER] ✅ Streaming: Featured items loaded from Firestore (${items.length})');
      isProductLoading.value = false;
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Streaming: Error loading featured items from Firestore: $e');
      // No API fallback - Firestore only
      print('[MART CONTROLLER] ❌ No API fallback available for featured items');
      featuredItems.clear();
      isProductLoading.value = false;
    }
  }

  /// Load categories with streaming updates using Firestore
  Future<void> loadCategoriesStreaming() async {
    try {
      print(
          '[MART CONTROLLER] 📂 Streaming: Loading all categories from Firestore...');

      // Try Firestore first (fastest path)
      try {
        final categories = await _firestoreService.getCategories(limit: 100);

        if (categories.isNotEmpty) {
          // Stream the data as it becomes available
          martCategories.clear();
          martCategories.addAll(categories);

          print(
              '[MART CONTROLLER] ✅ Streaming: All categories loaded from Firestore (${categories.length})');

          // Load subcategories for categories that have them
          await _loadSubcategoriesStreaming();
          return;
        } else {
          print(
              '[MART CONTROLLER] ⚠️ No categories from Firestore, trying API fallback...');
        }
      } catch (e) {
        print(
            '[MART CONTROLLER] ❌ Firestore failed: $e, trying API fallback...');
      }

      // No API fallback - Firestore only
      print('[MART CONTROLLER] ❌ Firestore failed, no API fallback available');
      errorMessage.value =
          'Unable to load categories from Firestore. Please check your connection.';
    } catch (e) {
      print('[MART CONTROLLER] ❌ Streaming: Error loading categories: $e');
    }
  }

  /// Load subcategories with streaming updates
  Future<void> _loadSubcategoriesStreaming() async {
    try {
      print('[MART CONTROLLER] 📋 Streaming: Loading subcategories...');

      for (final category in martCategories) {
        if (category.hasSubcategories == true) {
          try {
            final subcategories =
                await _firestoreService.getSubcategoriesByParent(
              parentCategoryId: category.id!,
              publish: true,
              sortBy: 'subcategory_order',
              sortOrder: 'asc',
            );

            subcategoriesMap[category.id!] = subcategories;
            print(
                '[MART CONTROLLER] ✅ Streaming: Subcategories loaded for ${category.title} (${subcategories.length})');
          } catch (e) {
            print(
                '[MART CONTROLLER] ⚠️ Streaming: Error loading subcategories for ${category.title}: $e');
          }
        }
      }

      print('[MART CONTROLLER] ✅ Streaming: Subcategories loading completed');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Streaming: Error loading subcategories: $e');
    }
  }

  /// Load subcategories for a specific category with streaming
  Future<void> loadSubcategoriesStreaming(String categoryId) async {
    try {
      print(
          '[MART CONTROLLER] 📋 Loading subcategories for category: $categoryId');
      isSubcategoryLoading.value = true;

      final subcategories = await _firestoreService.getSubcategoriesByParent(
        parentCategoryId: categoryId,
        publish: true,
        sortBy: 'subcategory_order',
        sortOrder: 'asc',
      );

      this.subcategories.value = subcategories;
      print(
          '[MART CONTROLLER] ✅ Loaded ${subcategories.length} subcategories for category: $categoryId');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading subcategories: $e');
      errorMessage.value =
          'Unable to load subcategories. Please try again later.';
    } finally {
      isSubcategoryLoading.value = false;
    }
  }

  /// Load vendors with streaming updates
  Future<void> _loadVendorsStreaming() async {
    try {
      print('[MART CONTROLLER] 🏪 Streaming: Loading vendors...');

      // Get user location
      final location = await _getUserLocation();

      // Load vendors
      final vendors = await _firestoreService.getMartVendors(
        isActive: true,
        enabledDelivery: false,
        limit: 10,
      );

      if (vendors.isNotEmpty) {
        // Stream the data as it becomes available
        martVendors.clear();
        martVendors.addAll(vendors);

        // Auto-select first vendor
        if (selectedVendorId.value.isEmpty) {
          selectVendor(vendors.first.id!);
          print(
              '[MART CONTROLLER] 🎯 Streaming: Auto-selected first vendor: ${vendors.first.name}');

          // Load additional data now that we have a vendor
          await _loadAdditionalDataStreaming();
        }

        print(
            '[MART CONTROLLER] ✅ Streaming: Vendors loaded (${vendors.length})');
      } else {
        print('[MART CONTROLLER] ⚠️ Streaming: No vendors found');
        // Still try to load additional data with dummy vendor
        await _loadAdditionalDataStreaming();
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Streaming: Error loading vendors: $e');
      // Still try to load additional data
      await _loadAdditionalDataStreaming();
    }
  }

  /// Load additional data with streaming updates
  Future<void> _loadAdditionalDataStreaming() async {
    try {
      print('[MART CONTROLLER] 📦 Streaming: Loading additional data...');

      // Load items on sale if we have a vendor
      if (selectedVendorId.value.isNotEmpty) {
        await _loadItemsOnSaleStreaming();
      }

      print('[MART CONTROLLER] ✅ Streaming: Additional data loaded');
    } catch (e) {
      print(
          '[MART CONTROLLER] ⚠️ Streaming: Error loading additional data: $e');
    }
  }

  /// Load items on sale with streaming updates
  Future<void> _loadItemsOnSaleStreaming() async {
    try {
      print('[MART CONTROLLER] 🏷️ Streaming: Loading items on sale...');

      final items = await _firestoreService.getMartItems(
        search: null,
        limit: 20,
      );

      final saleItems = items.where((item) => item.isOnSale == true).toList();

      // Stream the data as it becomes available
      itemsOnSale.clear();
      itemsOnSale.addAll(saleItems);

      print(
          '[MART CONTROLLER] ✅ Streaming: Items on sale loaded (${saleItems.length})');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Streaming: Error loading items on sale: $e');
    }
  }

  /// Manually trigger streaming data refresh
  Future<void> refreshStreamingData() async {
    try {
      print('[MART CONTROLLER] 🔄 Manual streaming refresh triggered...');

      // Refresh all data streams in parallel
      await Future.wait([
        loadHomepageCategoriesStreaming(limit: 10),
        loadTrendingItemsStreaming(),
        loadFeaturedItemsStreaming(),
        loadCategoriesStreaming(),
        _loadVendorsStreaming(),
      ]);

      print('[MART CONTROLLER] ✅ Manual streaming refresh completed');
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error in manual streaming refresh: $e');
    }
  }

  // ==================== SIMILAR PRODUCTS STREAM ====================

  /// Stream similar products for a given product
  Stream<List<MartItemModel>> streamSimilarProducts({
    required String categoryId,
    String? subcategoryId,
    String? excludeProductId,
    bool? isAvailable,
    int limit = 6,
  }) {
    try {
      print(
          '[MART CONTROLLER] 📡 Starting similar products stream for category: $categoryId');
      if (subcategoryId != null) {
        print('[MART CONTROLLER] 📡 Subcategory filter: $subcategoryId');
      }
      if (excludeProductId != null) {
        print('[MART CONTROLLER] 📡 Excluding product: $excludeProductId');
      }

      // Use the Firestore service stream method
      return _firestoreService.streamSimilarProducts(
        categoryId: categoryId,
        subcategoryId: subcategoryId,
        excludeProductId: excludeProductId,
        isAvailable: isAvailable,
        limit: limit,
      );
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating similar products stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream all products from mart_items collection
  Stream<List<MartItemModel>> streamAllProducts({
    String? excludeProductId,
    bool? isAvailable,
    int limit = 10,
  }) {
    try {
      print('[MART CONTROLLER] 📡 Starting all products stream');
      if (excludeProductId != null) {
        print('[MART CONTROLLER] 📡 Excluding product: $excludeProductId');
      }

      // Use the Firestore service stream method for all products
      return _firestoreService.streamAllProducts(
        excludeProductId: excludeProductId,
        isAvailable: isAvailable,
        limit: limit,
      );
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating all products stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  // ==================== SECTION-SPECIFIC PRODUCT STREAMS ====================

  /// Stream products for Product Deals section
  Stream<List<MartItemModel>> streamProductDeals({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Product Deals stream');
      return _firestoreService.streamProductDeals(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Product Deals stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Hair Care section
  Stream<List<MartItemModel>> streamHairCareProducts({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Hair Care stream');
      return _firestoreService.streamHairCareProducts(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Hair Care stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Chocolates section
  Stream<List<MartItemModel>> streamChocolateProducts({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Chocolates stream');
      return _firestoreService.streamChocolateProducts(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Chocolates stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Playtime section
  Stream<List<MartItemModel>> streamPlaytimeProducts({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Playtime stream');
      return _firestoreService.streamPlaytimeProducts(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Playtime stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Baby Care section
  Stream<List<MartItemModel>> streamBabyCareProducts({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Baby Care stream');
      return _firestoreService.streamBabyCareProducts(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Baby Care stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  /// Stream products for Local Grocery section
  Stream<List<MartItemModel>> streamLocalGroceryProducts({int limit = 10}) {
    try {
      print('[MART CONTROLLER] 📡 Starting Local Grocery stream');
      return _firestoreService.streamLocalGroceryProducts(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating Local Grocery stream: $e');
      return Stream.value(<MartItemModel>[]);
    }
  }

  // ==================== BANNER METHODS ====================

  /// Stream banners by position (top, middle, bottom)
  Stream<List<MartBannerModel>> streamBannersByPosition(String position,
      {int limit = 10}) {
    try {
      print('[MART CONTROLLER] 🎯 Streaming banners for position: $position');
      return _firestoreService.streamBannersByPosition(position, limit: limit);
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Error creating banner stream for position $position: $e');
      return Stream.value(<MartBannerModel>[]);
    }
  }

  /// Stream all published banners
  Stream<List<MartBannerModel>> streamAllBanners({int limit = 20}) {
    try {
      print('[MART CONTROLLER] 🎯 Streaming all published banners');
      return _firestoreService.streamAllBanners(limit: limit);
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error creating all banners stream: $e');
      return Stream.value(<MartBannerModel>[]);
    }
  }

  /// Get banners by position (one-time fetch)
  Future<List<MartBannerModel>> getBannersByPosition(String position,
      {int limit = 10}) async {
    try {
      print('[MART CONTROLLER] 🎯 Fetching banners for position: $position');
      return await _firestoreService.getBannersByPosition(position,
          limit: limit);
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Error fetching banners for position $position: $e');
      return <MartBannerModel>[];
    }
  }

  /// Handle banner tap based on redirect type
  void handleBannerTap(MartBannerModel banner) {
    try {
      print(
          '[MART CONTROLLER] 🎯 Banner tapped: ${banner.title} (${banner.redirectType})');

      switch (banner.redirectType?.toLowerCase()) {
        case 'product':
          if (banner.productId != null && banner.productId!.isNotEmpty) {
            // Navigate to product details
            print(
                '[MART CONTROLLER] 🎯 Navigating to product: ${banner.productId}');
            // TODO: Implement product navigation
            // Get.to(() => MartProductDetailsScreen(productId: banner.productId!));
          }
          break;

        case 'category':
          if (banner.storeId != null && banner.storeId!.isNotEmpty) {
            // Navigate to category
            print(
                '[MART CONTROLLER] 🎯 Navigating to category: ${banner.storeId}');
            // TODO: Implement category navigation
            // Get.to(() => MartCategoryDetailScreen(categoryId: banner.storeId!));
          }
          break;

        case 'external':
          if (banner.externalLink != null && banner.externalLink!.isNotEmpty) {
            // Open external link
            print(
                '[MART CONTROLLER] 🎯 Opening external link: ${banner.externalLink}');
            // TODO: Implement external link opening
            // launchUrl(Uri.parse(banner.externalLink!));
          }
          break;

        default:
          print(
              '[MART CONTROLLER] ⚠️ Unknown redirect type: ${banner.redirectType}');
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error handling banner tap: $e');
    }
  }

  /// Fetch delivery settings from Firestore (DEPRECATED - Use settings/martDeliveryCharge instead)
  @Deprecated('Use settings/martDeliveryCharge collection instead')
  Future<void> fetchDeliverySettings() async {
    try {
      print(
          '[MART CONTROLLER] 🚚 Fetching delivery settings from Firestore (DEPRECATED)');

      // Fetch from settings/martDeliveryCharge collection
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('martDeliveryCharge')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        deliverySettings.value = MartDeliverySettingsModel(
          freeDeliveryThreshold:
              (data['item_total_threshold'] as num?)?.toDouble() ?? 99.0,
          deliveryPromotionText: data['delivery_promotion_text'] ?? 'Daily',
          isActive: data['is_active'] ?? true,
          minOrderValue:
              (data['item_total_threshold'] as num?)?.toDouble() ?? 99.0,
          minOrderMessage: data['min_order_message'] ?? 'Min Item value is ₹99',
        );

        print(
            '[MART CONTROLLER] 🚚 Delivery settings loaded from martDeliveryCharge:');
        print(
            '  - Free delivery threshold: ₹${deliverySettings.value?.freeDeliveryThreshold}');
        print(
            '  - Promotion text: ${deliverySettings.value?.deliveryPromotionText}');
        print('  - Is active: ${deliverySettings.value?.isActive}');
      } else {
        print(
            '[MART CONTROLLER] ⚠️ martDeliveryCharge document not found, using defaults');
        // Set default values
        deliverySettings.value = MartDeliverySettingsModel(
          freeDeliveryThreshold: 99.0,
          deliveryPromotionText: 'Daily',
          isActive: true,
          minOrderValue: 99.0,
          minOrderMessage: 'Min Item value is ₹99',
        );
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error fetching delivery settings: $e');
      // Set default values on error
      deliverySettings.value = MartDeliverySettingsModel(
        freeDeliveryThreshold: 99.0,
        deliveryPromotionText: 'Daily',
        isActive: true,
        minOrderValue: 99.0,
        minOrderMessage: 'Min Item value is ₹99',
      );
    }
  }

  /// Get formatted delivery message
  String get deliveryMessage {
    final threshold = deliverySettings.value?.freeDeliveryThreshold ?? 199.0;
    return 'Spend ₹${threshold.toInt()} to unlock FREE delivery';
  }

  /// Get delivery promotion text
  String get deliveryPromotionText {
    return deliverySettings.value?.deliveryPromotionText ?? 'daily';
  }

  /// Check if delivery settings are active
  bool get isDeliverySettingsActive {
    return deliverySettings.value?.isActive ?? true;
  }

  /// Get minimum order value for mart items
  double get minOrderValue {
    return deliverySettings.value?.minOrderValue ?? 99.0;
  }

  /// Check if minimum order is enabled
  bool get isMinOrderEnabled {
    return deliverySettings.value?.minOrderEnabled ?? true;
  }

  /// Get minimum order message
  String get minOrderMessage {
    return deliverySettings.value?.minOrderMessage ??
        'Minimum order value is ₹99. Please add more items to your cart.';
  }

  /// Check if app is in maintenance mode
  bool get isMaintenanceMode {
    return deliverySettings.value?.maintenanceMode ?? false;
  }

  /// Get maintenance message
  String get maintenanceMessage {
    return deliverySettings.value?.maintenanceMessage ??
        'App is under maintenance. Please try again later.';
  }

  // ==================== SECTIONS LOADING ====================

  /// Preload sections immediately when controller is created
  void _preloadSections() {
    print('[MART CONTROLLER] 🚀 Preloading sections immediately...');
    print(
        '[MART CONTROLLER] 📊 Controller state: availableSections=${availableSections.length}');
    // Start loading sections in background immediately
    _loadSectionsInParallel();
  }

  /// Load sections in true parallel (immediate and fast)
  Future<void> _loadSectionsInParallel() async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print(
          '[MART CONTROLLER] 📂 _loadSectionsInParallel() called - TRUE PARALLEL LOADING');
      print('[MART CONTROLLER] ==========================================');

      // Start loading sections and products in parallel immediately
      final sectionsFuture = _firestoreService.getUniqueSections();

      // Get sections first
      final sections = await sectionsFuture;
      print(
          '[MART CONTROLLER] 📂 Found ${sections.length} unique sections: $sections');

      if (sections.isNotEmpty) {
        // Clear and add sections immediately
        availableSections.clear();
        availableSections.addAll(sections);

        // Safely trigger UI update
        Future.microtask(() {
          update();
        });

        // Load products for ALL sections in parallel simultaneously
        final productFutures =
            sections.map((section) => _loadProductsForSectionAsync(section));

        // Don't wait for all products - let them load in background
        Future.wait(productFutures).then((_) {
          print(
              '[MART CONTROLLER] ✅ All section products loaded in parallel: ${sections.length} sections');
          // Trigger UI update when products are loaded
          Future.microtask(() {
            update();
          });
        }).catchError((e) {
          print('[MART CONTROLLER] ❌ Error loading some section products: $e');
        });

        print(
            '[MART CONTROLLER] ✅ Sections loaded immediately: ${sections.length} sections');
      } else {
        print('[MART CONTROLLER] ⚠️ No sections found');
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading sections in parallel: $e');
    }
  }

  /// Load sections progressively (silent streaming - no loading state)
  Future<void> _loadSectionsProgressively() async {
    try {
      print('[MART CONTROLLER] ==========================================');
      print(
          '[MART CONTROLLER] 📂 _loadSectionsProgressively() called - SILENT STREAMING');
      print('[MART CONTROLLER] ==========================================');

      // Get all unique sections from mart_items collection
      final sections = await _firestoreService.getUniqueSections();
      print(
          '[MART CONTROLLER] 📂 Found ${sections.length} unique sections: $sections');

      if (sections.isNotEmpty) {
        availableSections.clear();
        availableSections.addAll(sections);

        // Load products for each section in parallel (silent streaming)
        final futures =
            sections.map((section) => _loadProductsForSectionAsync(section));
        await Future.wait(futures);

        print(
            '[MART CONTROLLER] ✅ Sections loaded silently: ${sections.length} sections');
      } else {
        print('[MART CONTROLLER] ⚠️ No sections found');
      }
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading sections silently: $e');
    }
  }

  /// Load products for a specific section (async, non-blocking)
  Future<void> _loadProductsForSectionAsync(String section) async {
    try {
      print('[MART CONTROLLER] 📂 Loading products for section: $section');

      final products = await _firestoreService.getItemsBySection(
        section: section,
        limit: 15,
      );

      sectionProducts[section] = products;
      print(
          '[MART CONTROLLER] ✅ Loaded ${products.length} products for section: $section');
    } catch (e) {
      print(
          '[MART CONTROLLER] ❌ Error loading products for section $section: $e');
      sectionProducts[section] = [];
    }
  }

  /// Get products for a specific section
  List<MartItemModel> getProductsForSection(String section) {
    return sectionProducts[section] ?? [];
  }

  /// Stream products by brand ID
  Stream<List<MartItemModel>> streamProductsByBrand(String brandID) {
    try {
      print('[MART CONTROLLER] 🔍 Streaming products for brand: $brandID');

      return _firestoreService.streamItemsByBrand(brandID).map((products) {
        print(
            '[MART CONTROLLER] 📦 Received ${products.length} products for brand: $brandID');
        return products;
      });
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error streaming products by brand: $e');
      return Stream.value([]);
    }
  }

  /// Load sections from Firebase (public method for manual refresh)
  Future<void> loadSectionsFromFirebase() async {
    await _loadSectionsProgressively();
  }

  /// Load sections immediately (true parallel loading - no loading state)
  Future<void> loadSectionsImmediately() async {
    try {
      // Prevent multiple loading attempts
      if (_sectionsLoadingTriggered) {
        print(
            '[MART CONTROLLER] ⚠️ Sections loading already triggered, skipping...');
        return;
      }

      _sectionsLoadingTriggered = true;
      print('[MART CONTROLLER] 🚀 Loading sections in true parallel...');

      // Use the new parallel loading method
      await _loadSectionsInParallel();
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error loading sections in parallel: $e');
      _sectionsLoadingTriggered = false; // Reset flag on error
    }
  }

  /// Force load sections (silent fallback method)
  Future<void> forceLoadSections() async {
    try {
      print('[MART CONTROLLER] 🔄 Force loading sections silently...');
      availableSections.clear();
      sectionProducts.clear();

      await loadSectionsImmediately();
    } catch (e) {
      print('[MART CONTROLLER] ❌ Error force loading sections: $e');
    }
  }

  /// Test method to manually add some sections for debugging
  void addTestSections() {
    // Only add test sections if no sections are loaded yet
    if (availableSections.isNotEmpty) {
      print(
          '[MART CONTROLLER] 🧪 Sections already loaded, skipping test sections');
      return;
    }

    print('[MART CONTROLLER] 🧪 Adding test sections for debugging...');
    availableSections.clear();
    availableSections
        .addAll(['Pet Care', 'General', 'Essentials & Daily Needs']);
    print(
        '[MART CONTROLLER] 🧪 Test sections added: ${availableSections.length} sections');

    // Use Future.microtask to safely trigger UI update
    Future.microtask(() {
      update();
    });
  }
}
