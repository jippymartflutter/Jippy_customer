import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/network_image_widget.dart';
import 'package:customer/utils/restaurant_status_utils.dart';
import 'package:flutter/material.dart';

/// **HELPER WIDGET FOR RESTAURANT IMAGE WITH CLOSED STATUS FILTER**
class RestaurantImageWithStatus extends StatelessWidget {
  final VendorModel vendorModel;
  final double height;
  final double width;
  final BoxFit? fit;

  const RestaurantImageWithStatus({
    super.key,
    required this.vendorModel,
    required this.height,
    required this.width,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    // **CHECK IF RESTAURANT IS CLOSED**
    final isRestaurantClosed = !RestaurantStatusUtils.canAcceptOrders(vendorModel);
    
    return isRestaurantClosed 
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
                  imageUrl: vendorModel.photo.toString(),
                  fit: fit ?? BoxFit.cover,
                  height: height,
                  width: width,
                ),
              ),
              // **SUBTLE OVERLAY FOR CLOSED RESTAURANTS**
              Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
            ],
          )
        : NetworkImageWidget(
            imageUrl: vendorModel.photo.toString(),
            fit: fit ?? BoxFit.cover,
            height: height,
            width: width,
          );
  }
}
