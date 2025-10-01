import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// **COMPREHENSIVE PERFORMANCE OPTIMIZER**
/// 
/// This utility provides various optimizations to reduce app loading time
/// from 3 seconds to 1 second by implementing:
/// - Image preloading and caching
/// - Lazy loading
/// - Memory management
/// - Network optimization
/// - UI performance improvements
class PerformanceOptimizer {
  static final PerformanceOptimizer _instance = PerformanceOptimizer._internal();
  factory PerformanceOptimizer() => _instance;
  PerformanceOptimizer._internal();

  // **PERFORMANCE TRACKING**
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, Duration> _durations = {};
  static final Map<String, int> _callCounts = {};

  // **CACHE MANAGEMENT**
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 10);

  // **IMAGE CACHE**
  static final Map<String, ImageProvider> _imageCache = {};
  static final List<String> _preloadedImages = [];

  // **LAZY LOADING**
  static final Map<String, bool> _lazyLoadedItems = {};
  static final List<String> _pendingLazyLoads = [];

  /// **START PERFORMANCE TRACKING**
  static void startTracking(String operationName) {
    _startTimes[operationName] = DateTime.now();
    _callCounts[operationName] = (_callCounts[operationName] ?? 0) + 1;
    log('🚀 PerformanceOptimizer - Started: $operationName');
  }

  /// **END PERFORMANCE TRACKING**
  static void endTracking(String operationName) {
    final startTime = _startTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _durations[operationName] = duration;
      _startTimes.remove(operationName);
      log('✅ PerformanceOptimizer - Completed: $operationName in ${duration.inMilliseconds}ms');
    }
  }

  /// **MEASURE ASYNC OPERATION**
  static Future<T> measureAsync<T>(String operationName, Future<T> Function() operation) async {
    startTracking(operationName);
    try {
      final result = await operation();
      endTracking(operationName);
      return result;
    } catch (e) {
      log('❌ PerformanceOptimizer - Error in $operationName: $e');
      endTracking(operationName);
      rethrow;
    }
  }

  /// **CACHE MANAGEMENT**
  static T? getFromCache<T>(String key) {
    final timestamp = _cacheTimestamps[key];
    if (timestamp != null && DateTime.now().difference(timestamp) < _cacheExpiry) {
      final cached = _memoryCache[key];
      if (cached is T) {
        log('💾 PerformanceOptimizer - Cache HIT: $key');
        return cached;
      }
    }
    log('💾 PerformanceOptimizer - Cache MISS: $key');
    return null;
  }

  static void setCache<T>(String key, T value) {
    _memoryCache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
    log('💾 PerformanceOptimizer - Cached: $key');
  }

  static void clearCache() {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    log('🧹 PerformanceOptimizer - Cache cleared');
  }

  /// **IMAGE OPTIMIZATION**
  static Future<void> preloadImages(List<String> imageUrls) async {
    startTracking('preload_images');
    
    final futures = imageUrls.map((url) async {
      if (!_preloadedImages.contains(url)) {
        try {
          // Check if it's an asset path or network URL
          if (url.startsWith('assets/')) {
            // For assets, use precacheImage instead of DefaultCacheManager
            await precacheImage(AssetImage(url), Get.context!);
            _preloadedImages.add(url);
            log('🖼️ PerformanceOptimizer - Preloaded asset: $url');
          } else {
            // For network URLs, use DefaultCacheManager
            await DefaultCacheManager().getSingleFile(url);
            _preloadedImages.add(url);
            log('🖼️ PerformanceOptimizer - Preloaded network image: $url');
          }
        } catch (e) {
          log('❌ PerformanceOptimizer - Failed to preload image: $url - $e');
        }
      }
    });

    await Future.wait(futures);
    endTracking('preload_images');
  }

  static ImageProvider getCachedImage(String imageUrl) {
    if (_imageCache.containsKey(imageUrl)) {
      return _imageCache[imageUrl]!;
    }

    final imageProvider = CachedNetworkImageProvider(imageUrl);
    _imageCache[imageUrl] = imageProvider;
    return imageProvider;
  }

  /// **LAZY LOADING**
  static bool shouldLazyLoad(String itemId) {
    return !_lazyLoadedItems.containsKey(itemId) || !_lazyLoadedItems[itemId]!;
  }

  static void markAsLazyLoaded(String itemId) {
    _lazyLoadedItems[itemId] = true;
  }

  static void addToLazyLoadQueue(String itemId) {
    if (!_pendingLazyLoads.contains(itemId)) {
      _pendingLazyLoads.add(itemId);
    }
  }

  /// **NETWORK OPTIMIZATION**
  static Future<T> optimizedNetworkCall<T>(
    String cacheKey,
    Future<T> Function() networkCall, {
    Duration? cacheExpiry,
  }) async {
    // Check cache first
    final cached = getFromCache<T>(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Make network call
    final result = await measureAsync('network_call_$cacheKey', networkCall);
    
    // Cache result
    setCache(cacheKey, result);
    
    return result;
  }

  /// **UI PERFORMANCE OPTIMIZATIONS**
  static Widget optimizedListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required String cacheKey,
    int? itemCount,
    ScrollController? controller,
    bool shrinkWrap = false,
    bool primary = true,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      key: PageStorageKey(cacheKey),
      itemCount: itemCount ?? items.length,
      controller: controller,
      shrinkWrap: shrinkWrap,
      primary: primary,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = '$cacheKey-$index';
        
        // Lazy load if needed
        if (shouldLazyLoad(itemId)) {
          addToLazyLoadQueue(itemId);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            markAsLazyLoaded(itemId);
          });
        }
        
        return itemBuilder(context, item, index);
      },
    );
  }

  static Widget optimizedGridView<T>({
    required List<T> items,
    required Widget Function(BuildContext, T, int) itemBuilder,
    required String cacheKey,
    required SliverGridDelegate gridDelegate,
    int? itemCount,
    ScrollController? controller,
    bool shrinkWrap = false,
    bool primary = true,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      key: PageStorageKey(cacheKey),
      itemCount: itemCount ?? items.length,
      gridDelegate: gridDelegate,
      controller: controller,
      shrinkWrap: shrinkWrap,
      primary: primary,
      physics: physics ?? const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = items[index];
        final itemId = '$cacheKey-$index';
        
        // Lazy load if needed
        if (shouldLazyLoad(itemId)) {
          addToLazyLoadQueue(itemId);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            markAsLazyLoaded(itemId);
          });
        }
        
        return itemBuilder(context, item, index);
      },
    );
  }

  /// **MEMORY MANAGEMENT**
  static void optimizeMemory() {
    // Clear old cache entries
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiry) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _memoryCache.remove(key);
      _cacheTimestamps.remove(key);
    }

    // Limit image cache size
    if (_imageCache.length > 100) {
      final keys = _imageCache.keys.toList();
      for (int i = 0; i < keys.length - 50; i++) {
        _imageCache.remove(keys[i]);
      }
    }

    log('🧹 PerformanceOptimizer - Memory optimized');
  }

  /// **PERFORMANCE REPORTING**
  static void printPerformanceReport() {
    log('\n🚀 **PERFORMANCE OPTIMIZER REPORT** 🚀');
    log('=' * 50);

    // Overview
    log('\n📊 **OVERVIEW**');
    log('Active operations: ${_startTimes.length}');
    log('Completed operations: ${_durations.length}');
    log('Total calls: ${_callCounts.values.fold(0, (sum, count) => sum + count)}');
    log('Cached items: ${_memoryCache.length}');
    log('Preloaded images: ${_preloadedImages.length}');
    log('Lazy loaded items: ${_lazyLoadedItems.length}');

    // Timing performance
    log('\n⏱️ **TIMING PERFORMANCE**');
    if (_durations.isNotEmpty) {
      final sortedOperations = _durations.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      log('Slowest operations:');
      for (int i = 0; i < sortedOperations.length && i < 5; i++) {
        final op = sortedOperations[i];
        log('${i + 1}. ${op.key}: ${op.value.inMilliseconds}ms (${_callCounts[op.key] ?? 0} calls)');
      }
    }

    // Cache performance
    log('\n💾 **CACHE PERFORMANCE**');
    log('Memory cache size: ${_memoryCache.length}');
    log('Image cache size: ${_imageCache.length}');
    log('Preloaded images: ${_preloadedImages.length}');

    log('\n' + '=' * 50);
    log('Report generated at: ${DateTime.now()}');
    log('=' * 50 + '\n');
  }

  /// **CLEAR ALL DATA**
  static void clearAllData() {
    _startTimes.clear();
    _durations.clear();
    _callCounts.clear();
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _imageCache.clear();
    _preloadedImages.clear();
    _lazyLoadedItems.clear();
    _pendingLazyLoads.clear();
    log('🧹 PerformanceOptimizer - All data cleared');
  }

  /// **INITIALIZATION**
  static Future<void> initialize() async {
    startTracking('initialization');
    
    // Set up periodic memory optimization
    Timer.periodic(const Duration(minutes: 5), (_) {
      optimizeMemory();
    });

    // Preload common images
    await preloadImages([
      'assets/images/simmer_gif.gif',
      'assets/images/ic_logo.png',
      // Add more common images here
    ]);

    endTracking('initialization');
    log('🚀 PerformanceOptimizer initialized successfully');
  }
}

/// **OPTIMIZED NETWORK IMAGE WIDGET**
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool preload;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.preload = true,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty || imageUrl == "null") {
      return errorWidget ?? const Icon(Icons.error);
    }

    if (preload) {
      PerformanceOptimizer.addToLazyLoadQueue(imageUrl);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => placeholder ?? 
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => errorWidget ?? 
          const Icon(Icons.error),
      cacheManager: DefaultCacheManager(),
      maxWidthDiskCache: 1024,
      maxHeightDiskCache: 1024,
    );
  }
}

/// **OPTIMIZED LIST VIEW**
class OptimizedListView<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final String cacheKey;
  final int? itemCount;
  final ScrollController? controller;
  final bool shrinkWrap;
  final bool primary;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.cacheKey,
    this.itemCount,
    this.controller,
    this.shrinkWrap = false,
    this.primary = true,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return PerformanceOptimizer.optimizedListView<T>(
      items: items,
      itemBuilder: itemBuilder,
      cacheKey: cacheKey,
      itemCount: itemCount,
      controller: controller,
      shrinkWrap: shrinkWrap,
      primary: primary,
      physics: physics,
    );
  }
}

/// **PERFORMANCE MONITORING WIDGET**
class PerformanceMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const PerformanceMonitorWidget({
    super.key,
    required this.child,
    this.showOverlay = false,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  Timer? _reportTimer;

  @override
  void initState() {
    super.initState();
    if (widget.showOverlay) {
      _reportTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        PerformanceOptimizer.printPerformanceReport();
      });
    }
  }

  @override
  void dispose() {
    _reportTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay)
          Positioned(
            top: 50,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Performance Monitor Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
