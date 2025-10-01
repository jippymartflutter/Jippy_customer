import 'package:customer/app/address_screens/address_list_screen.dart';
import 'package:customer/app/dash_board_screens/dash_board_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controllers/location_permission_controller.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/services/location_service.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/themes/responsive.dart';
import 'package:customer/themes/round_button_fill.dart';
import 'package:customer/utils/dark_theme_provider.dart';
import 'package:customer/widget/osm_map/map_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:provider/provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:customer/utils/fire_store_utils.dart';

class LocationPermissionScreen extends StatelessWidget {
  const LocationPermissionScreen({super.key});

  // Helper to update location in GetStorage
  Future<void> updateLocationInLocal(UserLocation location) async {
    final box = GetStorage();
    box.write('user_location', {
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder(
      init: LocationPermissionController(),
      builder: (controller) {
        return Scaffold(
          body: Container(
            height: Responsive.height(100, context),
            width: Responsive.width(100, context),
            decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/location_bg.png"), fit: BoxFit.cover)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Enable Location Services 📍".tr,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                  ),
                  Text(
                    "To provide the best shopping experience, allow JippyMart to access your location.".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 16, fontFamily: AppThemeData.regular),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  RoundedButtonFill(
                    title: "Use Current Location".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      Constant.checkPermission(
                        context: context,
                        onTap: () async {
                          try {
                            bool success = await LocationService.updateLocationAndNavigate(
                              showLoader: true,
                              showError: true,
                            );
                            
                            if (success) {
                              Get.offAll(const DashBoardScreen());
                            }
                          } catch (e) {
                            print('[LOCATION_PERMISSION] Error: $e');
                            ShowToastDialog.showToast("Failed to get location. Please try again.".tr);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  RoundedButtonFill(
                    title: "Set From Map".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    icon: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: SvgPicture.asset(
                        "assets/icons/ic_location_pin.svg",
                        colorFilter: const ColorFilter.mode(AppThemeData.grey50, BlendMode.srcIn),
                      ),
                    ),
                    isRight: false,
                    onPress: () async {
                      Constant.checkPermission(
                        context: context,
                        onTap: () async {
                          try {
                            if (Constant.selectedMapType == 'osm') {
                              final result = await Get.to(() => MapPickerPage());
                              if (result != null) {
                                final firstPlace = result;
                                final lat = firstPlace.coordinates.latitude;
                                final lng = firstPlace.coordinates.longitude;
                                final address = firstPlace.address;

                                ShippingAddress addressModel = ShippingAddress();
                                addressModel.addressAs = "Home";
                                addressModel.locality = address.toString();
                                addressModel.location = UserLocation(latitude: lat, longitude: lng);
                                Constant.selectedLocation = addressModel;
                                await updateLocationInLocal(addressModel.location!);
                                Get.offAll(const DashBoardScreen());
                              }
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlacePicker(
                                    apiKey: Constant.mapAPIKey,
                                    onPlacePicked: (result) {
                                      ShippingAddress addressModel = ShippingAddress();
                                      addressModel.addressAs = "Home";
                                      addressModel.locality = result.formattedAddress!.toString();
                                      addressModel.location = UserLocation(latitude: result.geometry!.location.lat, longitude: result.geometry!.location.lng);
                                      Constant.selectedLocation = addressModel;
                                      updateLocationInLocal(addressModel.location!).then((_) {
                                        Get.offAll(const DashBoardScreen());
                                      });
                                    },
                                    initialPosition: const LatLng(-33.8567844, 151.213108),
                                    useCurrentLocation: true,
                                    selectInitialPosition: true,
                                    usePinPointingSearch: true,
                                    usePlaceDetailSearch: true,
                                    zoomGesturesEnabled: true,
                                    zoomControlsEnabled: true,
                                    resizeToAvoidBottomInset: false,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            print('[LOCATION_PERMISSION] Error in Add Location: $e');
                            ShowToastDialog.showToast("Failed to add location. Please try again.".tr);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Constant.userModel == null
                      ? const SizedBox()
                      : RoundedButtonFill(
                          title: "Enter Manually location".tr,
                          color: AppThemeData.primary300,
                          textColor: AppThemeData.grey50,
                          isRight: false,
                          onPress: () async {
                            Get.to(const AddressListScreen())!.then(
                              (value) async {
                                if (value != null) {
                                  ShippingAddress addressModel = value;
                                  Constant.selectedLocation = addressModel;
                                  await updateLocationInLocal(addressModel.location!);
                                  Get.offAll(const DashBoardScreen());
                                }
                              },
                            );
                          },
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  // Add a button for changing location
                  RoundedButtonFill(
                    title: "Change Location".tr,
                    color: AppThemeData.primary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      Constant.checkPermission(
                        context: context,
                        onTap: () async {
                          try {
                            bool success = await LocationService.updateLocationAndNavigate(
                              showLoader: true,
                              showError: true,
                            );
                            
                            if (success) {
                              Get.offAll(const DashBoardScreen());
                            }
                          } catch (e) {
                            print('[LOCATION_PERMISSION] Error in Change Location: $e');
                            ShowToastDialog.showToast("Failed to change location. Please try again.".tr);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
