import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/models/favourite_item_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/product_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FavouriteController extends GetxController {
  RxBool favouriteRestaurant = true.obs;
  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList<VendorModel> favouriteVendorList = <VendorModel>[].obs;

  RxList<FavouriteItemModel> favouriteItemList = <FavouriteItemModel>[].obs;
  RxList<ProductModel> favouriteFoodList = <ProductModel>[].obs;

  RxBool isLoading = true.obs;

  // **STREAMING VARIABLES FOR FAST LOADING**
  StreamSubscription<QuerySnapshot>? _favouriteRestaurantStream;
  StreamSubscription<QuerySnapshot>? _favouriteItemStream;
  Map<String, StreamSubscription<DocumentSnapshot>> _vendorStreams = {};
  Map<String, StreamSubscription<DocumentSnapshot>> _productStreams = {};

  @override
  void onInit() {
    // TODO: implement onInit
    // Ensure loading state is true when controller initializes
    isLoading.value = true;

    // Try streaming first, fallback to legacy if needed
    try {
      startStreamingData();
    } catch (e) {
      print('[ERROR] Streaming failed, falling back to legacy method: $e');
      getData();
    }

    super.onInit();
  }

  @override
  void onClose() {
    // Clean up all streams
    _favouriteRestaurantStream?.cancel();
    _favouriteItemStream?.cancel();
    _vendorStreams.values.forEach((stream) => stream.cancel());
    _productStreams.values.forEach((stream) => stream.cancel());
    _vendorStreams.clear();
    _productStreams.clear();
    super.onClose();
  }

  void refreshDataAfterUserLoaded() {
    print('[DEBUG] Refreshing favourites after user data loaded');
    startStreamingData();
  }

  // **ULTRA-FAST STREAMING DATA LOADING**
  void startStreamingData() {
    print('[DEBUG] FavouriteController: Starting streaming data loading...');
    isLoading.value = true;

    if (Constant.userModel == null) {
      print('[DEBUG] User not logged in, skipping data loading');
      isLoading.value = false;
      return;
    }

    // Clear existing data
    favouriteList.clear();
    favouriteItemList.clear();
    favouriteVendorList.clear();
    favouriteFoodList.clear();

    // Start streaming favourite restaurants
    _startFavouriteRestaurantStream();

    // Start streaming favourite items
    _startFavouriteItemStream();
  }

  void _startFavouriteRestaurantStream() {
    print('[DEBUG] Starting favourite restaurant stream...');
    print('[DEBUG] Current user ID: ${FireStoreUtils.getCurrentUid()}');
    _favouriteRestaurantStream = FirebaseFirestore.instance
        .collection(CollectionName.favoriteRestaurant)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .snapshots()
        .listen((snapshot) {
      print(
          '[DEBUG] Favourite restaurant stream update: ${snapshot.docs.length} items');

      favouriteList.clear();
      for (var doc in snapshot.docs) {
        print('[DEBUG] Processing favourite doc: ${doc.data()}');
        favouriteList.add(FavouriteModel.fromJson(doc.data()));
      }

      // Start streaming vendor data for each restaurant
      _startVendorStreams();

      // Hide loading after first data arrives
      if (isLoading.value) {
        isLoading.value = false;
        print('[DEBUG] Initial data loaded, hiding loading indicator');
      }
    }, onError: (error) {
      print('[ERROR] Favourite restaurant stream error: $error');
      isLoading.value = false;
    });
  }

  void _startFavouriteItemStream() {
    print('[DEBUG] Starting favourite item stream...');
    _favouriteItemStream = FirebaseFirestore.instance
        .collection(CollectionName.favoriteItem)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .snapshots()
        .listen((snapshot) {
      print(
          '[DEBUG] Favourite item stream update: ${snapshot.docs.length} items');

      favouriteItemList.clear();
      for (var doc in snapshot.docs) {
        favouriteItemList.add(FavouriteItemModel.fromJson(doc.data()));
      }

      // Start streaming product data for each item
      _startProductStreams();

      // Hide loading after first data arrives
      if (isLoading.value) {
        isLoading.value = false;
        print('[DEBUG] Initial data loaded, hiding loading indicator');
      }
    }, onError: (error) {
      print('[ERROR] Favourite item stream error: $error');
      isLoading.value = false;
    });
  }

  void _startVendorStreams() {
    print(
        '[DEBUG] Starting vendor streams for ${favouriteList.length} restaurants...');

    // Cancel existing vendor streams
    _vendorStreams.values.forEach((stream) => stream.cancel());
    _vendorStreams.clear();
    favouriteVendorList.clear();

    for (var favourite in favouriteList) {
      final restaurantId = favourite.restaurantId.toString();

      if (!_vendorStreams.containsKey(restaurantId)) {
        _vendorStreams[restaurantId] = FirebaseFirestore.instance
            .collection(CollectionName.vendors)
            .doc(restaurantId)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            final vendor = VendorModel.fromJson(snapshot.data()!);

            // Check subscription status
            if (_isVendorAvailable(vendor)) {
              // Remove if already exists and add new
              favouriteVendorList.removeWhere((v) => v.id == vendor.id);
              favouriteVendorList.add(vendor);
              print('[DEBUG] Added vendor: ${vendor.title}');
              update();
            }
          }
        }, onError: (error) {
          print('[ERROR] Vendor stream error for $restaurantId: $error');
        });
      }
    }
  }

  void _startProductStreams() {
    print(
        '[DEBUG] Starting product streams for ${favouriteItemList.length} items...');

    // Cancel existing product streams
    _productStreams.values.forEach((stream) => stream.cancel());
    _productStreams.clear();
    favouriteFoodList.clear();

    for (var favourite in favouriteItemList) {
      final productId = favourite.productId.toString();

      if (!_productStreams.containsKey(productId)) {
        _productStreams[productId] = FirebaseFirestore.instance
            .collection(CollectionName.vendorProducts)
            .doc(productId)
            .snapshots()
            .listen((snapshot) async {
          if (snapshot.exists) {
            final product = ProductModel.fromJson(snapshot.data()!);

            // Check vendor subscription status
            if (Constant.isSubscriptionModelApplied == true ||
                Constant.adminCommission?.isEnabled == true) {
              final vendorDoc = await FirebaseFirestore.instance
                  .collection(CollectionName.vendors)
                  .doc(product.vendorID.toString())
                  .get();

              if (vendorDoc.exists) {
                final vendor = VendorModel.fromJson(vendorDoc.data()!);
                if (_isVendorAvailable(vendor)) {
                  // Remove if already exists and add new
                  favouriteFoodList.removeWhere((p) => p.id == product.id);
                  favouriteFoodList.add(product);
                  update();
                  print('¸ ${product.name}');
                }
              }
            } else {
              // Remove if already exists and add new
              favouriteFoodList.removeWhere((p) => p.id == product.id);
              favouriteFoodList.add(product);
              update();
              print('[DEBUG] Added product: ${product.name}');
            }
          }
        }, onError: (error) {
          print('[ERROR] Product stream error for $productId: $error');
        });
      }
    }
  }

  bool _isVendorAvailable(VendorModel vendor) {
    if ((Constant.isSubscriptionModelApplied == true ||
            Constant.adminCommission?.isEnabled == true) &&
        vendor.subscriptionPlan != null) {
      if (vendor.subscriptionTotalOrders == "-1") {
        return true;
      } else {
        if ((vendor.subscriptionExpiryDate != null &&
                vendor.subscriptionExpiryDate!
                        .toDate()
                        .isBefore(DateTime.now()) ==
                    false) ||
            vendor.subscriptionPlan?.expiryDay == '-1') {
          return vendor.subscriptionTotalOrders != '0';
        }
      }
      return false;
    }
    return true;
  }

  // **LEGACY METHOD FOR BACKWARD COMPATIBILITY**
  getData() async {
    print('[DEBUG] FavouriteController: Using legacy getData method...');

    // Fallback to old implementation if streaming fails
    try {
      if (Constant.userModel != null) {
        print('[DEBUG] Using legacy getFavouriteRestaurant method...');
        final restaurantFavourites =
            await FireStoreUtils.getFavouriteRestaurant();
        favouriteList.value = restaurantFavourites;
        print(
            '[DEBUG] Legacy method found ${restaurantFavourites.length} restaurant favourites');

        final itemFavourites = await FireStoreUtils.getFavouriteItem();
        favouriteItemList.value = itemFavourites;
        print(
            '[DEBUG] Legacy method found ${itemFavourites.length} item favourites');

        // Load vendor and product data
        await _loadVendorAndProductData();
      }
    } catch (e) {
      print('[ERROR] Legacy method failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

/* <<<<<<<<<<<<<<  ✨ Windsurf Command ⭐ >>>>>>>>>>>>>>>> */
  /// Loads vendor and product data for the favourite items and restaurants.
  ///
  /// This method iterates over the favourite restaurants and items, loading
  /// vendor and product data respectively. It checks the vendor's
  /// subscription status before adding the product to the list.
  ///
  /// If the vendor's subscription status is unavailable, the product is
  /// not added to the list.
  ///
  /// If an error occurs while loading the vendor or product data, an
  /// error message is printed to the console.
  ///
  /// This method is used as a fallback when the streaming data method fails.
  ///
  /// Returns a Future<void> which completes when the vendor and product data
  /// has been loaded successfully.
  ///
/* <<<<<<<<<<  d1b16885-51cf-4603-bf78-4282c9a37cb5  >>>>>>>>>>> */
  Future<void> _loadVendorAndProductData() async {
    // Load vendor data for restaurants
    for (var element in favouriteList) {
      try {
        final vendor =
            await FireStoreUtils.getVendorById(element.restaurantId.toString());
        if (vendor != null && _isVendorAvailable(vendor)) {
          favouriteVendorList.add(vendor);
          update();
          print('[DEBUG] Added vendor: ${vendor.title}');
        }
      } catch (e) {
        print('[ERROR] Failed to load vendor ${element.restaurantId}: $e');
      }
    }

    // Load product data for items
    for (var element in favouriteItemList) {
      try {
        final product =
            await FireStoreUtils.getProductById(element.productId.toString());
        if (product != null) {
          // Check vendor subscription status
          if (Constant.isSubscriptionModelApplied == true ||
              Constant.adminCommission?.isEnabled == true) {
            final vendor =
                await FireStoreUtils.getVendorById(product.vendorID.toString());
            if (vendor != null && _isVendorAvailable(vendor)) {
              favouriteFoodList.add(product);
              print('[DEBUG] Added product: ${product.name}');
            }
          } else {
            favouriteFoodList.add(product);
            print('[DEBUG] Added product: ${product.name}');
          }
        }
      } catch (e) {
        print('[ERROR] Failed to load product ${element.productId}: $e');
      }
    }
  }
}
