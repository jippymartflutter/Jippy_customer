import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/app/dine_in_booking/dine_in_booking_screen.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/send_notification.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/dine_in_booking_model.dart';
import 'package:customer/models/favourite_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/restaurant_status_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DineInRestaurantDetailsController extends GetxController {
  Rx<TextEditingController> searchEditingController = TextEditingController().obs;

  Rx<TextEditingController> additionRequestController = TextEditingController().obs;

  RxBool isLoading = true.obs;
  RxBool firstVisit = false.obs;
  Rx<PageController> pageController = PageController().obs;
  RxInt currentPage = 0.obs;
  RxInt noOfQuantity = 1.obs;

  RxList<FavouriteModel> favouriteList = <FavouriteModel>[].obs;
  RxList tags = [].obs;

  List occasionList = ["Birthday", "Anniversary"];
  RxString selectedOccasion = "".obs;

  RxList<DateModel> dateList = <DateModel>[].obs;
  RxList<TimeModel> timeSlotList = <TimeModel>[].obs;

  Rx<Timestamp> selectedDate = Timestamp.now().obs;
  RxString selectedTimeSlot = '6:00 PM'.obs;

  RxString selectedTimeDiscount = '0'.obs;
  RxString selectedTimeDiscountType = ''.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    getRecord();
    super.onInit();
  }

  orderBook() async {
    ShowToastDialog.showLoader("Please wait".tr);

    DateTime dt = selectedDate.value.toDate();
    String hour = DateFormat("kk:mm").format(DateFormat('hh:mm a').parse((Intl.getCurrentLocale() == "en_US") ? selectedTimeSlot.value : selectedTimeSlot.value.toLowerCase()));
    dt = DateTime(dt.year, dt.month, dt.day, int.parse(hour.split(":")[0]), int.parse(hour.split(":")[1]), dt.second, dt.millisecond, dt.microsecond);
    selectedDate.value = Timestamp.fromDate(dt);
    DineInBookingModel dineInBookingModel = DineInBookingModel(
        id: Constant.getUuid(),
        author: Constant.userModel,
        authorID: FireStoreUtils.getCurrentUid(),
        createdAt: Timestamp.now(),
        date: selectedDate.value,
        status: Constant.orderPlaced,
        vendor: vendorModel.value,
        specialRequest: additionRequestController.value.text.isEmpty ? "" : additionRequestController.value.text,
        vendorID: vendorModel.value.id,
        guestEmail: Constant.userModel!.email,
        guestFirstName: Constant.userModel!.firstName,
        guestLastName: Constant.userModel!.lastName,
        guestPhone: Constant.userModel!.phoneNumber,
        occasion: selectedOccasion.value,
        discount: selectedTimeDiscount.value,
        discountType: selectedTimeDiscountType.value,
        totalGuest: noOfQuantity.value.toString(),
        firstVisit: firstVisit.value);
    await FireStoreUtils.setBookedOrder(dineInBookingModel);
    await SendNotification.sendFcmMessage(Constant.dineInPlaced, vendorModel.value.fcmToken.toString(), {});
    ShowToastDialog.closeLoader();
    Get.back();
    Get.to(const DineInBookingScreen());
    ShowToastDialog.showToast('Dine-In Request submitted successfully.'.tr);
  }

  getRecord() {
    for (int i = 0; i < 7; i++) {
      final now = DateTime.now().add(Duration(days: i));
      var day = DateFormat('EEEE').format(now);
      if (vendorModel.value.specialDiscount?.isNotEmpty == true && vendorModel.value.specialDiscountEnable == true) {
        for (var element in vendorModel.value.specialDiscount!) {
          if (day == element.day.toString()) {
            if (element.timeslot!.isNotEmpty) {
              SpecialDiscountTimeslot employeeWithMaxSalary =
                  element.timeslot!.reduce((item1, item2) => double.parse(item1.discount.toString()) > double.parse(item2.discount.toString()) ? item1 : item2);
              if (employeeWithMaxSalary.discountType == "dinein") {
                DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: employeeWithMaxSalary.discount.toString());
                dateList.add(model);
              } else {
                DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
                dateList.add(model);
              }
            } else {
              DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
              dateList.add(model);
            }
          }
        }
      } else {
        DateModel model = DateModel(date: Timestamp.fromDate(now), discountPer: "0");
        dateList.add(model);
      }
    }
    selectedDate.value = dateList.first.date;

    timeSet(selectedDate.value);
    if (timeSlotList.isNotEmpty) {
      selectedTimeSlot.value = DateFormat('hh:mm a').format(timeSlotList[0].time!);
    }
  }

  timeSet(Timestamp selectedDate) {
    timeSlotList.clear();

    for (DateTime time = Constant.stringToDate(vendorModel.value.openDineTime.toString());
        time.isBefore(Constant.stringToDate(vendorModel.value.closeDineTime.toString()));
        time = time.add(const Duration(minutes: 30))) {
      final now = DateTime.parse(selectedDate.toDate().toString());
      var day = DateFormat('EEEE').format(now);
      var date = DateFormat('dd-MM-yyyy').format(now);

      if (vendorModel.value.specialDiscount?.isNotEmpty == true && vendorModel.value.specialDiscountEnable == true) {
        for (var element in vendorModel.value.specialDiscount!) {
          if (day == element.day.toString()) {
            if (element.timeslot!.isNotEmpty) {
              for (var element in element.timeslot!) {
                if (element.discountType == "dinein") {
                  var start = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.from}");
                  var end = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${element.to}");
                  var selected = DateFormat("dd-MM-yyyy HH:mm").parse("$date ${DateFormat.Hm().format(time)}");

                  if (isCurrentDateInRangeDineIn(start, end, selected)) {
                    var contains = timeSlotList.where((element) => element.time == time);
                    if (contains.isNotEmpty) {
                      var index = timeSlotList.indexWhere((element) => element.time == time);
                      if (timeSlotList[index].discountPer == "0") {
                        timeSlotList.removeAt(index);
                        TimeModel model = TimeModel(time: time, discountPer: element.discount, discountType: element.type);
                        timeSlotList.insert(index == 0 ? 0 : index, model);
                      }
                    } else {
                      TimeModel model = TimeModel(time: time, discountPer: element.discount, discountType: element.type);
                      timeSlotList.add(model);
                    }
                  } else {
                    var contains = timeSlotList.where((element) => element.time == time);
                    if (contains.isEmpty) {
                      TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
                      timeSlotList.add(model);
                    }
                  }
                } else {
                  TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
                  timeSlotList.add(model);
                }
              }
            } else {
              TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
              timeSlotList.add(model);
            }
          }
        }
      } else {
        TimeModel model = TimeModel(time: time, discountPer: "0", discountType: "amount");
        timeSlotList.add(model);
      }
    }
  }

  void animateSlider() {
    if (vendorModel.value.photos != null && vendorModel.value.photos!.isNotEmpty) {
      Timer.periodic(const Duration(seconds: 2), (Timer timer) {
        if (currentPage < vendorModel.value.photos!.length) {
          currentPage++;
        } else {
          currentPage.value = 0;
        }

        if (pageController.value.hasClients) {
          pageController.value.animateToPage(
            currentPage.value,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      });
    }
  }

  Rx<VendorModel> vendorModel = VendorModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      vendorModel.value = argumentData['vendorModel'];
    }
    animateSlider();
    statusCheck();
    isLoading.value = false;
    await getFavouriteList();

    update();
  }

  getFavouriteList() async {
    if (Constant.userModel != null) {
      await FireStoreUtils.getFavouriteRestaurant().then(
        (value) {
          favouriteList.value = value;
        },
      );
    }

    await FireStoreUtils.getVendorCuisines(vendorModel.value.id.toString()).then(
      (value) {
        tags.value = value;
      },
    );
    update();
  }

  RxBool isOpen = false.obs;
  RxMap<String, dynamic> restaurantStatus = <String, dynamic>{}.obs;

  /// **FAILPROOF RESTAURANT STATUS SYSTEM**
  /// 
  /// Implements the comprehensive failproof system where restaurant is ONLY OPEN if:
  /// 1. Manual toggle (isOpen) is explicitly true AND
  /// 2. Current time is within working hours
  /// 
  /// This replaces the old reststatus-based logic with the new isOpen field
  void statusCheck() {
    print('DEBUG: DineInRestaurantDetailsController - Running failproof status check');
    
    // Use the RestaurantStatusManager for failproof logic
    final statusManager = RestaurantStatusManager();
    
    // Get current status using the new isOpen field from Firebase
    final status = statusManager.getRestaurantStatus(
      vendorModel.value.workingHours,
      vendorModel.value.isOpen, // Use the new isOpen field instead of reststatus
    );
    
    // Update reactive variables
    isOpen.value = status['isOpen'];
    restaurantStatus.assignAll(status);
    
    // Log status for debugging
    print('DEBUG: Status check result:');
    print('  - Manual toggle (isOpen): ${vendorModel.value.isOpen}');
    print('  - Within working hours: ${status['withinWorkingHours']}');
    print('  - Final status: ${status['isOpen'] ? 'OPEN' : 'CLOSED'}');
    print('  - Reason: ${status['reason']}');
    
    // Start monitoring for status changes
    _startStatusMonitoring();
  }
  
  /// **START STATUS MONITORING**
  /// 
  /// Monitors restaurant status every 5 minutes
  void _startStatusMonitoring() {
    final statusManager = RestaurantStatusManager();
    
    statusManager.startStatusMonitoring(
      workingHours: vendorModel.value.workingHours,
      isOpen: vendorModel.value.isOpen,
      onStatusUpdate: (status) {
        // Update status if it changed
        if (isOpen.value != status['isOpen']) {
          print('DEBUG: Status changed from ${isOpen.value} to ${status['isOpen']}');
          isOpen.value = status['isOpen'];
          restaurantStatus.assignAll(status);
        }
      },
      intervalMinutes: 5,
    );
  }
  
  /// **GET RESTAURANT STATUS INFO (LEGACY COMPATIBILITY)**
  Map<String, dynamic> getRestaurantStatusInfo() {
    if (restaurantStatus.isEmpty) {
      // Fallback to old logic if status not yet calculated
      final statusManager = RestaurantStatusManager();
      final status = statusManager.getRestaurantStatus(
        vendorModel.value.workingHours,
        vendorModel.value.isOpen,
      );
      restaurantStatus.assignAll(status);
      isOpen.value = status['isOpen'];
    }
    
    return Map<String, dynamic>.from(restaurantStatus);
  }
  
  /// **CHECK IF RESTAURANT ACCEPTS ORDERS**
  /// 
  /// Uses the failproof system to determine if orders can be accepted
  bool canAcceptOrders() {
    return isOpen.value;
  }
  
  /// **GET NEXT OPENING TIME**
  String? getNextOpeningTime() {
    final status = getRestaurantStatusInfo();
    return status['nextOpeningTime'];
  }
  
  /// **GET STATUS SUMMARY FOR DEBUGGING**
  String getStatusSummary() {
    final statusManager = RestaurantStatusManager();
    return statusManager.getStatusSummary(
      vendorModel.value.workingHours,
      vendorModel.value.isOpen,
    );
  }
  


  bool isCurrentDateInRangeDineIn(DateTime startDate, DateTime endDate, DateTime selected) {
    return selected.isAtSameMomentAs(startDate) || selected.isAtSameMomentAs(endDate) || selected.isAfter(startDate) && selected.isBefore(endDate);
  }

  bool isCurrentDateInRange(DateTime startDate, DateTime endDate) {
    final currentDate = DateTime.now();
    return currentDate.isAfter(startDate) && currentDate.isBefore(endDate);
  }
}

class DateModel {
  late Timestamp date;
  late String discountPer;

  DateModel({required this.date, required this.discountPer});
}

class TimeModel {
  DateTime? time;
  String? discountPer;
  String? discountType;

  TimeModel({required this.time, required this.discountPer, required this.discountType});
}
