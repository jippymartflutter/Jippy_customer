import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/performance_optimizer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:async';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;
  final bool fixOrientation;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.color,
    this.errorWidget,
    this.fixOrientation = false,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty URLs
    if (imageUrl.isEmpty || imageUrl == "null" || imageUrl == "Null" || imageUrl == "NULL") {
      return errorWidget ??
          Image.network(
            Constant.placeholderImage,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
          );
    }

    // Validate URL format to prevent FormatException
    String cleanImageUrl = imageUrl.trim();
    
    // Remove any extra quotes that might be causing issues
    if (cleanImageUrl.startsWith('"') && cleanImageUrl.endsWith('"')) {
      cleanImageUrl = cleanImageUrl.substring(1, cleanImageUrl.length - 1);
    }
    if (cleanImageUrl.startsWith("'") && cleanImageUrl.endsWith("'")) {
      cleanImageUrl = cleanImageUrl.substring(1, cleanImageUrl.length - 1);
    }
    
    // Check if URL is valid
    try {
      Uri.parse(cleanImageUrl);
    } catch (e) {
      print('[NETWORK_IMAGE] Invalid URL format: $imageUrl');
      return errorWidget ??
          Image.asset(
            Constant.placeholderImage,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
          );
    }

    // Add to performance tracking for optimization
    PerformanceOptimizer.addToLazyLoadQueue(cleanImageUrl);

    // If orientation fix is requested, use the oriented version
    if (fixOrientation) {
      return OrientedNetworkImage(
        imageUrl: cleanImageUrl,
        height: height,
        width: width,
        fit: fit,
        borderRadius: borderRadius,
        color: color,
        errorWidget: errorWidget,
      );
    }

    // Check if the image URL is AVIF format
    bool isAvifFormat = _isAvifFormat(cleanImageUrl);
    
    // For AVIF images, use a fallback approach since Flutter doesn't support AVIF natively
    if (isAvifFormat) {
      return AvifFallbackImage(
        imageUrl: cleanImageUrl,
        height: height,
        width: width,
        fit: fit,
        color: color,
        errorWidget: errorWidget,
      );
    }

    return CachedNetworkImage(
      imageUrl: cleanImageUrl,
      fit: fit ?? BoxFit.fitWidth,
      height: height ?? Responsive.height(8, context),
      width: width ?? Responsive.width(15, context),
      color: color,
      progressIndicatorBuilder: (context, url, downloadProgress) => _buildLoadingWidget(),
      errorWidget: (context, url, error) {
        print('[NETWORK_IMAGE] Error loading cached image: $error');
        return errorWidget ??
            Image.asset(
              Constant.placeholderImage,
              fit: fit ?? BoxFit.fitWidth,
              height: height ?? Responsive.height(8, context),
              width: width ?? Responsive.width(15, context),
            );
      },
    );
  }

  // Enhanced format detection
  bool _isAvifFormat(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('.avif') || 
           lowerUrl.contains('format=avif') ||
           lowerUrl.contains('&format=avif');
  }

  // Safe loading widget that handles missing assets gracefully
  Widget _buildLoadingWidget() {
    try {
      return Image.asset(
        "assets/images/simmer_gif.gif",
        height: height,
        width: width,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          print('[NETWORK_IMAGE] Error loading shimmer gif: $error');
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } catch (e) {
      print('[NETWORK_IMAGE] Error creating loading widget: $e');
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

// New widget specifically for handling AVIF images with fallback
class AvifFallbackImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final Color? color;

  const AvifFallbackImage({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.color,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getFallbackUrl(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        // If we have a fallback URL, use it
        if (snapshot.hasData && snapshot.data != null) {
          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
            color: color,
            progressIndicatorBuilder: (context, url, downloadProgress) => Image.asset(
              "assets/images/simmer_gif.gif",
              height: height,
              width: width,
              fit: BoxFit.fill,
            ),
            errorWidget: (context, url, error) {
              print('[AVIF_FALLBACK] Error loading fallback image: $error');
              return _buildErrorWidget(context);
            },
          );
        }

        // If no fallback available, show error widget
        print('[AVIF_FALLBACK] No fallback URL available for AVIF image: $imageUrl');
        return _buildErrorWidget(context);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return errorWidget ??
        Image.network(
          Constant.placeholderImage,
          fit: fit ?? BoxFit.fitWidth,
          height: height ?? Responsive.height(8, context),
          width: width ?? Responsive.width(15, context),
        );
  }

  // Safe loading widget that handles missing assets gracefully
  Widget _buildLoadingWidget() {
    try {
      return Image.asset(
        "assets/images/simmer_gif.gif",
        height: height,
        width: width,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          print('[AVIF_FALLBACK] Error loading shimmer gif: $error');
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } catch (e) {
      print('[AVIF_FALLBACK] Error creating loading widget: $e');
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Future<String?> _getFallbackUrl(String avifUrl) async {
    try {
      // Try to get a WebP or JPEG version of the same image
      String fallbackUrl = avifUrl;
      
      // Replace .avif with .webp
      if (fallbackUrl.toLowerCase().contains('.avif')) {
        fallbackUrl = fallbackUrl.replaceAll(RegExp(r'\.avif', caseSensitive: false), '.webp');
      }
      
      // If URL contains format parameter, try to change it
      if (fallbackUrl.contains('format=avif')) {
        fallbackUrl = fallbackUrl.replaceAll('format=avif', 'format=webp');
      }
      
      // Test if the fallback URL exists with timeout
      final response = await http.head(Uri.parse(fallbackUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 5));
        },
      );
      if (response.statusCode == 200) {
        print('[AVIF_FALLBACK] Using WebP fallback: $fallbackUrl');
        return fallbackUrl;
      }
      
      // Try JPEG fallback
      fallbackUrl = avifUrl;
      if (fallbackUrl.toLowerCase().contains('.avif')) {
        fallbackUrl = fallbackUrl.replaceAll(RegExp(r'\.avif', caseSensitive: false), '.jpg');
      }
      if (fallbackUrl.contains('format=avif')) {
        fallbackUrl = fallbackUrl.replaceAll('format=avif', 'format=jpeg');
      }
      
      final jpegResponse = await http.head(Uri.parse(fallbackUrl)).timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Request timeout', const Duration(seconds: 5));
        },
      );
      if (jpegResponse.statusCode == 200) {
        print('[AVIF_FALLBACK] Using JPEG fallback: $fallbackUrl');
        return fallbackUrl;
      }
      
      print('[AVIF_FALLBACK] No fallback URL found for: $avifUrl');
      return null;
    } catch (e) {
      print('[AVIF_FALLBACK] Error getting fallback URL: $e');
      return null;
    }
  }
}

// New widget for handling EXIF orientation properly
class OrientedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const OrientedNetworkImage({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.color,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty URLs
    if (imageUrl.isEmpty || imageUrl == "null" || imageUrl == "Null" || imageUrl == "NULL") {
      return errorWidget ??
          Image.network(
            Constant.placeholderImage,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
          );
    }

    // Validate URL format to prevent FormatException
    String cleanImageUrl = imageUrl.trim();
    
    // Remove any extra quotes that might be causing issues
    if (cleanImageUrl.startsWith('"') && cleanImageUrl.endsWith('"')) {
      cleanImageUrl = cleanImageUrl.substring(1, cleanImageUrl.length - 1);
    }
    if (cleanImageUrl.startsWith("'") && cleanImageUrl.endsWith("'")) {
      cleanImageUrl = cleanImageUrl.substring(1, cleanImageUrl.length - 1);
    }
    
    // Check if URL is valid
    try {
      Uri.parse(cleanImageUrl);
    } catch (e) {
      print('[ORIENTED_IMAGE] Invalid URL format: $imageUrl');
      return errorWidget ??
          Image.network(
            Constant.placeholderImage,
            fit: fit ?? BoxFit.fitWidth,
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
          );
    }

    return FutureBuilder<ui.Image?>(
      future: _loadImageWithOrientation(cleanImageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          print('[ORIENTED_IMAGE] Error loading image: ${snapshot.error}');
          return errorWidget ??
              Image.network(
                Constant.placeholderImage,
                fit: fit ?? BoxFit.fitWidth,
                height: height ?? Responsive.height(8, context),
                width: width ?? Responsive.width(15, context),
              );
        }

        return ClipRRect(
          borderRadius: borderRadius != null ? BorderRadius.circular(borderRadius!) : BorderRadius.zero,
          child: RawImage(
            image: snapshot.data,
            fit: fit ?? BoxFit.fitWidth,
            width: width,
            height: height,
            color: color,
          ),
        );
      },
    );
  }

  Future<ui.Image?> _loadImageWithOrientation(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final codec = await ui.instantiateImageCodec(
          response.bodyBytes,
          targetWidth: width?.toInt(),
          targetHeight: height?.toInt(),
        );
        final frame = await codec.getNextFrame();
        return frame.image;
      }
    } catch (e) {
      print('[ORIENTED_IMAGE] Error loading image: $e');
    }
    return null;
  }

  // Safe loading widget that handles missing assets gracefully
  Widget _buildLoadingWidget() {
    try {
      return Image.asset(
        "assets/images/simmer_gif.gif",
        height: height,
        width: width,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          print('[ORIENTED_IMAGE] Error loading shimmer gif: $error');
          return Container(
            height: height,
            width: width,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );
    } catch (e) {
      print('[ORIENTED_IMAGE] Error creating loading widget: $e');
      return Container(
        height: height,
        width: width,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
