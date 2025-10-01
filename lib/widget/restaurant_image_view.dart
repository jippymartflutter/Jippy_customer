import 'dart:async';
import 'dart:ui';

import 'package:customer/models/vendor_model.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/restaurant_status_utils.dart';
import 'package:flutter/material.dart';

class RestaurantImageView extends StatefulWidget {
  final VendorModel vendorModel;

  const RestaurantImageView({super.key, required this.vendorModel});

  @override
  State<RestaurantImageView> createState() => _RestaurantImageViewState();
}

class _RestaurantImageViewState extends State<RestaurantImageView> {
  int currentPage = 0;
  Timer? _animationTimer;

  PageController pageController = PageController(initialPage: 1);

  @override
  void initState() {
    animateSlider();
    super.initState();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void animateSlider() {
    if (widget.vendorModel.photos != null && widget.vendorModel.photos!.isNotEmpty) {
      if (widget.vendorModel.photos!.length > 1) {
        _animationTimer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
          // Check if widget is still mounted
          if (!mounted) {
            timer.cancel();
            return;
          }
          
          if (currentPage < widget.vendorModel.photos!.length - 1) {
            currentPage++;
          } else {
            currentPage = 0;
          }

          // Only animate if attached
          try {
            if (pageController.hasClients) {
              pageController.animateToPage(
                currentPage,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            }
          } catch (e) {
            // If any error occurs, cancel the timer
            timer.cancel();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // **CHECK IF RESTAURANT IS CLOSED**
    final isRestaurantClosed = !RestaurantStatusUtils.canAcceptOrders(widget.vendorModel);
    
    return SizedBox(
      height: Responsive.height(20, context),
      child: widget.vendorModel.photos == null || widget.vendorModel.photos!.isEmpty
          ? _buildSingleImage(isRestaurantClosed)
          : _buildImageCarousel(isRestaurantClosed),
    );
  }
  
  /// **BUILD SINGLE IMAGE WITH CLOSED RESTAURANT FILTER**
  Widget _buildSingleImage(bool isClosed) {
    return isClosed 
        ? Stack(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.33, 0.33, 0.33, 0, 0,  // Red channel
                  0.33, 0.33, 0.33, 0, 0,  // Green channel  
                  0.33, 0.33, 0.33, 0, 0,  // Blue channel
                  0, 0, 0, 1, 0,           // Alpha channel
                ]),
                child: NetworkImageWidget(
                  imageUrl: widget.vendorModel.photo.toString(),
                  fit: BoxFit.cover,
                  height: Responsive.height(20, context),
                  width: Responsive.width(100, context),
                  fixOrientation: true,
                ),
              ),
              // **SUBTLE OVERLAY FOR CLOSED RESTAURANTS**
              Container(
                height: Responsive.height(20, context),
                width: Responsive.width(100, context),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ],
          )
        : NetworkImageWidget(
            imageUrl: widget.vendorModel.photo.toString(),
            fit: BoxFit.cover,
            height: Responsive.height(20, context),
            width: Responsive.width(100, context),
            fixOrientation: true,
          );
  }
  
  /// **BUILD IMAGE CAROUSEL WITH CLOSED RESTAURANT FILTER**
  Widget _buildImageCarousel(bool isClosed) {
    return isClosed
        ? Stack(
            children: [
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.33, 0.33, 0.33, 0, 0,  // Red channel
                  0.33, 0.33, 0.33, 0, 0,  // Green channel  
                  0.33, 0.33, 0.33, 0, 0,  // Blue channel
                  0, 0, 0, 1, 0,           // Alpha channel
                ]),
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: pageController,
                  scrollDirection: Axis.horizontal,
                  allowImplicitScrolling: true,
                  itemCount: widget.vendorModel.photos!.length,
                  padEnds: false,
                  pageSnapping: true,
                  itemBuilder: (BuildContext context, int index) {
                    String image = widget.vendorModel.photos![index];
                    return NetworkImageWidget(
                      imageUrl: image.toString(),
                      fit: BoxFit.cover,
                      height: Responsive.height(20, context),
                      width: Responsive.width(100, context),
                      fixOrientation: true,
                    );
                  },
                ),
              ),
              // **SUBTLE OVERLAY FOR CLOSED RESTAURANTS**
              Container(
                height: Responsive.height(20, context),
                width: Responsive.width(100, context),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ],
          )
        : PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: pageController,
            scrollDirection: Axis.horizontal,
            allowImplicitScrolling: true,
            itemCount: widget.vendorModel.photos!.length,
            padEnds: false,
            pageSnapping: true,
            itemBuilder: (BuildContext context, int index) {
              String image = widget.vendorModel.photos![index];
              return NetworkImageWidget(
                imageUrl: image.toString(),
                fit: BoxFit.cover,
                height: Responsive.height(20, context),
                width: Responsive.width(100, context),
                fixOrientation: true,
              );
            },
          );
  }
}
