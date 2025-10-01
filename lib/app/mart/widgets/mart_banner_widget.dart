import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:customer/models/mart_banner_model.dart';
import 'package:customer/controllers/mart_controller.dart';

class MartBannerWidget extends StatelessWidget {
  final String position;
  final int limit;
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MartBannerWidget({
    Key? key,
    required this.position,
    this.limit = 10,
    this.height = 200,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MartBannerModel>>(
      stream: Get.find<MartController>().streamBannersByPosition(position, limit: limit),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          print('ERROR: Banner stream error: ${snapshot.error}');
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('DEBUG: No banners found for position: $position');
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!;
        print('DEBUG: Displaying ${banners.length} banners for position: $position');

        return _buildBannerList(banners);
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5D56F3),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      child: const Center(
        child: Text(
          'Failed to load banners',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildBannerList(List<MartBannerModel> banners) {
    if (banners.length == 1) {
      // Single banner - full width
      return _buildSingleBanner(banners.first);
    } else {
      // Multiple banners - horizontal scroll
      return _buildBannerCarousel(banners);
    }
  }

  Widget _buildSingleBanner(MartBannerModel banner) {
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      child: GestureDetector(
        onTap: () => _handleBannerTap(banner),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Banner Image
              Positioned.fill(
                child: Image.network(
                  banner.photo ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF5D56F3),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF5D56F3),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Gradient overlay for better text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Banner content
              if ((banner.title?.isNotEmpty == true) || (banner.description?.isNotEmpty == true))
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (banner.title?.isNotEmpty == true)
                        Text(
                          banner.title!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      if (banner.description?.isNotEmpty == true && banner.description != '-')
                        const SizedBox(height: 4),
                      if (banner.description?.isNotEmpty == true && banner.description != '-')
                        Text(
                          banner.description!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerCarousel(List<MartBannerModel> banners) {
    return Container(
      height: height,
      margin: margin,
      padding: padding,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return Container(
            width: MediaQuery.of(context).size.width * 0.8,
            margin: EdgeInsets.only(
              right: index < banners.length - 1 ? 12 : 0,
            ),
            child: _buildSingleBanner(banner),
          );
        },
      ),
    );
  }

  void _handleBannerTap(MartBannerModel banner) {
    print('DEBUG: Banner tapped: ${banner.title} (${banner.redirectType})');
    Get.find<MartController>().handleBannerTap(banner);
  }
}

/// Specialized widget for top position banners (like the "Trending today" section)
class MartTopBannerWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MartTopBannerWidget({
    Key? key,
    this.height = 180,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MartBannerWidget(
      position: 'top',
      limit: 3,
      height: height,
      margin: margin,
      padding: padding,
    );
  }
}

/// Specialized widget for middle position banners
class MartMiddleBannerWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MartMiddleBannerWidget({
    Key? key,
    this.height = 160,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MartBannerWidget(
      position: 'middle',
      limit: 5,
      height: height,
      margin: margin,
      padding: padding,
    );
  }
}

/// Specialized widget for bottom position banners
class MartBottomBannerWidget extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const MartBottomBannerWidget({
    Key? key,
    this.height = 140,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MartBannerWidget(
      position: 'bottom',
      limit: 3,
      height: height,
      margin: margin,
      padding: padding,
    );
  }
}
