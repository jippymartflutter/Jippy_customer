import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/models/admin_commission.dart';
import 'package:customer/models/cart_product_model.dart';
import 'package:customer/models/coupon_model.dart';
import 'package:customer/models/currency_model.dart';
import 'package:customer/models/email_template_model.dart';
import 'package:customer/models/language_model.dart';
import 'package:customer/models/mail_setting.dart';
import 'package:customer/models/order_model.dart';
import 'package:customer/models/tax_model.dart';
import 'package:customer/models/user_model.dart';
import 'package:customer/models/vendor_model.dart';
import 'package:customer/models/zone_model.dart';
import 'package:customer/themes/app_them_data.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:customer/utils/preferences.dart';
import 'package:customer/widget/permission_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

RxList<CartProductModel> cartItem = <CartProductModel>[].obs;

class Constant {
  static String userRoleDriver = 'driver';
  static String userRoleCustomer = 'customer';
  static String userRoleVendor = 'vendor';

  static ShippingAddress selectedLocation = ShippingAddress();
  static UserModel? userModel;
  static const globalUrl = "https://foodie.siswebapp.com/";

  static bool isZoneAvailable = false;
  static ZoneModel? selectedZone;

  static String theme = "theme_1";
  static String mapAPIKey = "";
  static String placeHolderImage = "";

  static String senderId = '';
  static String jsonNotificationFileURL = '';

  static String radius = "50";
  static String driverRadios = "50";
  static String distanceType = "km";

  static String placeholderImage = "assets/images/food_delivery.png";
  static String googlePlayLink = "";
  static String appStoreLink = "";
  static String appVersion = "";
  static String websiteUrl = "";
  static String termsAndConditions = "";
  static String privacyPolicy = "";
  static String supportURL = "";
  static String minimumAmountToDeposit = "0.0";
  static String minimumAmountToWithdrawal = "0.0";
  static String? referralAmount = "0.0";
  static bool? walletSetting = false;
  static bool? storyEnable = true;
  static bool? specialDiscountOffer = true;

  static const String orderPlaced = "Order Placed";
  static const String orderAccepted = "Order Accepted";
  static const String orderRejected = "Order Rejected";
  static const String orderCancelled = "Order Cancelled";
  static const String driverPending = "Driver Pending";
  static const String driverRejected = "Driver Rejected";
  static const String orderShipped = "Order Shipped";
  static const String orderInTransit = "In Transit";
  static const String orderCompleted = "Order Completed";

  static CurrencyModel? currencyModel;
  static AdminCommission? adminCommission;
  static List<TaxModel>? taxList = [];
  static List<VendorModel>? restaurantList = [];

  static bool isSubscriptionModelApplied = false;
  static bool isSelfDeliveryFeature=false;
  
  // Debug and development flags
  static bool showDebugButtons = false; // Set to true to show debug buttons in release mode

  static MailSettings? mailSettings;
  static String walletTopup = "wallet_topup";
  static String newVendorSignup = "new_vendor_signup";
  static String payoutRequestStatus = "payout_request_status";
  static String payoutRequest = "payout_request";

  static String newOrderPlaced = "order_placed";
  static String scheduleOrder = "schedule_order";
  static String dineInPlaced = "dinein_placed";
  static String dineInCanceled = "dinein_canceled";
  static String dineinAccepted = "dinein_accepted";
  static String restaurantRejected = "restaurant_rejected";
  static String driverCompleted = "driver_completed";
  static String restaurantAccepted = "restaurant_accepted";
  static String takeawayCompleted = "takeaway_completed";

  static String selectedMapType = 'osm';
  static String? mapType = "google";

  static String? we = "google";

  static bool? isEnabledForCustomer = true;
  static bool isEnableAdsFeature = true;

  static String amountShow({required String? amount}) {
    if (currencyModel!.symbolAtRight == true) {
      return "${double.parse(amount.toString()).toStringAsFixed(currencyModel!.decimalDigits ?? 0)} ${currencyModel!.symbol.toString()}";
    } else {
      return "${currencyModel!.symbol.toString()} ${amount == null || amount.isEmpty ? "0.0" : double.parse(amount.toString()).toStringAsFixed(currencyModel!.decimalDigits ?? 0)}";
    }
  }

  static Color statusColor({required String? status}) {
    if (status == orderPlaced) {
      return AppThemeData.secondary300;
    } else if (status == orderAccepted || status == orderCompleted) {
      return AppThemeData.success400;
    } else if (status == orderRejected) {
      return AppThemeData.danger300;
    } else {
      return AppThemeData.warning300;
    }
  }

  static Color statusText({required String? status}) {
    if (status == orderPlaced) {
      return AppThemeData.grey50;
    } else if (status == orderAccepted || status == orderCompleted) {
      return AppThemeData.grey50;
    } else if (status == orderRejected) {
      return AppThemeData.grey50;
    } else {
      return AppThemeData.grey900;
    }
  }

  static String productCommissionPrice(VendorModel vendorModel, String price) {
    String commission = "0";
    if (adminCommission!.isEnabled == true) {
      if (vendorModel.adminCommission == null) {
        if (adminCommission!.commissionType!.toLowerCase() ==
                "Percent".toLowerCase() ||
            adminCommission!.commissionType?.toLowerCase() ==
                "Percentage".toLowerCase()) {
          commission = (double.parse(price) +
                  (double.parse(price) *
                      double.parse(adminCommission!.amount.toString()) /
                      100))
              .toString();
        } else {
          commission = (double.parse(price) +
                  double.parse(adminCommission!.amount.toString()))
              .toString();
        }
      } else {
        if (vendorModel.adminCommission!.commissionType!.toLowerCase() ==
                "Percent".toLowerCase() ||
            vendorModel.adminCommission!.commissionType?.toLowerCase() ==
                "Percentage".toLowerCase()) {
          commission = (double.parse(price) +
                  (double.parse(price) *
                      double.parse(
                          vendorModel.adminCommission!.amount.toString()) /
                      100))
              .toString();
        } else {
          commission = (double.parse(price) +
                  double.parse(vendorModel.adminCommission!.amount.toString()))
              .toString();
        }
      }
    } else {
      commission = price;
    }

    return commission;
  }

  static double calculateTax({String? amount, TaxModel? taxModel}) {
    double taxAmount = 0.0;
    if (taxModel != null && taxModel.enable == true) {
      if (taxModel.type == "fix") {
        taxAmount = double.parse(taxModel.tax.toString());
      } else {
        taxAmount = (double.parse(amount.toString()) *
                double.parse(taxModel.tax!.toString())) /
            100;
      }
    }
    return taxAmount;
  }

  static double calculateDiscount({String? amount, CouponModel? offerModel}) {
    double taxAmount = 0.0;
    if (offerModel != null) {
      if (offerModel.discountType == "Percentage" ||
          offerModel.discountType == "percentage") {
        taxAmount = (double.parse(amount.toString()) *
                double.parse(offerModel.discount.toString())) /
            100;
      } else {
        taxAmount = double.parse(offerModel.discount.toString());
      }
    }
    return taxAmount;
  }

  static String calculateReview({required String? reviewCount, required String? reviewSum}) {
    final count = double.tryParse(reviewCount ?? '0') ?? 0;
    final sum = double.tryParse(reviewSum ?? '0') ?? 0;
    if (count == 0 || sum == 0) {
      // If new restaurant (no reviews), show random rating between 4.9 and 5.0
      final random = math.Random();
      final rating = count == 0
          ? (4.0 + random.nextDouble() * 0.1) // 4.9 to 5.0
          : (4.0 + random.nextDouble() * 1.0); // 4.0 to 5.0
      return rating.toStringAsFixed(1);
    }
    return (sum / count).toStringAsFixed(1);
  }

  static const userPlaceHolder = 'assets/images/user_placeholder.png';

  static String getUuid() {
    return const Uuid().v4();
  }

  static Widget loader({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppThemeData.primary300, // Orange color
            ),
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppThemeData.grey800,
                fontSize: 16,
                fontFamily: AppThemeData.semiBold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget showEmptyView({required String message}) {
    return Center(
      child: Text(message,
          style:
              const TextStyle(fontFamily: AppThemeData.medium, fontSize: 18)),
    );
  }

  static String getReferralCode() {
    var rng = math.Random();
    return (rng.nextInt(900000) + 100000).toString();
  }

  static String maskingString(String documentId, int maskingDigit) {
    String maskedDigits = documentId;
    for (int i = 0; i < documentId.length - maskingDigit; i++) {
      maskedDigits = maskedDigits.replaceFirst(documentId[i], "*");
    }
    return maskedDigits;
  }

  String? validateRequired(String? value, String type) {
    if (value!.isEmpty) {
      return '$type required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  static String getDistance(
      {required String lat1,
      required String lng1,
      required String lat2,
      required String lng2}) {
    // Enhanced null safety and validation checks
    if (lat1.isEmpty || lng1.isEmpty || lat2.isEmpty || lng2.isEmpty) {
      print('DEBUG: getDistance - Invalid coordinates: lat1=$lat1, lng1=$lng1, lat2=$lat2, lng2=$lng2');
      return "0.0";
    }
    
    try {
      // Parse coordinates with better error handling
      double lat1Double = double.parse(lat1);
      double lng1Double = double.parse(lng1);
      double lat2Double = double.parse(lat2);
      double lng2Double = double.parse(lng2);
      
      // Validate coordinate ranges
      if (lat1Double < -90 || lat1Double > 90 || lat2Double < -90 || lat2Double > 90) {
        print('DEBUG: getDistance - Invalid latitude range: lat1=$lat1Double, lat2=$lat2Double');
        return "0.0";
      }
      
      if (lng1Double < -180 || lng1Double > 180 || lng2Double < -180 || lng2Double > 180) {
        print('DEBUG: getDistance - Invalid longitude range: lng1=$lng1Double, lng2=$lng2Double');
        return "0.0";
      }
      
      // Use the more accurate Haversine formula instead of Geolocator
      double distance = calculateDistance(lat1Double, lng1Double, lat2Double, lng2Double);
      
      // Convert to miles if needed
      if (distanceType == "miles") {
        distance = distance * 0.621371; // Convert km to miles
      }
      
      return distance.toStringAsFixed(2);
    } catch (e) {
      print('DEBUG: getDistance - Error parsing coordinates: $e');
      return "0.0";
    }
  }

  bool hasValidUrl(String? value) {
    String pattern =
        r'(http|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?';
    RegExp regExp = RegExp(pattern);
    if (value == null || value.isEmpty) {
      return false;
    } else if (!regExp.hasMatch(value)) {
      return false;
    }
    return true;
  }

  static Future<String> uploadUserImageToFireStorage(
      File image, String filePath, String fileName) async {
    Reference upload =
        FirebaseStorage.instance.ref().child('$filePath/$fileName');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl =
        await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<TimeOfDay?> selectTime(context) async {
    FocusScope.of(context).requestFocus(FocusNode()); //remove focus
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (newTime != null) {
      return newTime;
    }
    return null;
  }

  static Future<DateTime?> selectDate(context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppThemeData.primary300, // header background color
                onPrimary: AppThemeData.grey900, // header text color
                onSurface: AppThemeData.grey900, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeData.grey900, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        initialDate: DateTime.now(),
        //get today's date
        firstDate: DateTime(2000),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime(2101));
    return pickedDate;
  }

  static int calculateDifference(DateTime date) {
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static String timestampToDate(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy').format(dateTime);
  }

  static String timestampToDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd,yyyy hh:mm aa').format(dateTime);
  }

  static String timestampToTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('hh:mm aa').format(dateTime);
  }

  static String timestampToDateChat(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  static DateTime stringToDate(String openDineTime) {
    return DateFormat('HH:mm').parse(DateFormat('HH:mm').format(
        DateFormat("hh:mm a").parse((Intl.getCurrentLocale() == "en_US")
            ? openDineTime
            : openDineTime.toLowerCase())));
  }

  static LanguageModel getLanguage() {
    final String user = Preferences.getString(Preferences.languageCodeKey);
    Map<String, dynamic> userMap = jsonDecode(user);
    return LanguageModel.fromJson(userMap);
  }

  static String orderId({String orderId = ''}) {
    return "#${(orderId).substring(orderId.length - 10)}";
  }

  static checkPermission(
      {required BuildContext context, required Function() onTap}) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      ShowToastDialog.showToast(
          "You have to allow location permission to use your location");
    } else if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const PermissionDialog();
        },
      );
    } else {
      onTap();
    }
  }

  /// Enhanced Point-in-Polygon algorithm using ray casting
  /// Returns true if the point is inside the polygon, false otherwise
  static bool isPointInPolygon(LatLng point, List<GeoPoint> polygon) {
    // Input validation
    if (polygon.isEmpty || polygon.length < 3) {
      print('[ZONE_DEBUG] Invalid polygon: empty or less than 3 points');
      return false;
    }
    
    // Check for null coordinates
    if (point.latitude == null || point.longitude == null) {
      print('[ZONE_DEBUG] Invalid point: null coordinates');
      return false;
    }
    
    int crossings = 0;
    int n = polygon.length;
    
    for (int i = 0; i < n; i++) {
      int j = (i + 1) % n;
      
      // Skip if any coordinate is null
      if (polygon[i].latitude == null || polygon[i].longitude == null ||
          polygon[j].latitude == null || polygon[j].longitude == null) {
        continue;
      }
      
      double lat1 = polygon[i].latitude!;
      double lng1 = polygon[i].longitude!;
      double lat2 = polygon[j].latitude!;
      double lng2 = polygon[j].longitude!;
      
      // Check if ray crosses this edge
      if (((lat1 <= point.latitude) && (lat2 > point.latitude)) ||
          ((lat1 > point.latitude) && (lat2 <= point.latitude))) {
        
        // Calculate intersection point
        double edgeLat = lat2 - lat1;
        
        // Avoid division by zero
        if (edgeLat == 0) {
          continue;
        }
        
        double interpol = (point.latitude - lat1) / edgeLat;
        double intersectionLng = lng1 + interpol * (lng2 - lng1);
        
        // Count crossing if intersection is to the right of the point
        if (point.longitude < intersectionLng) {
          crossings++;
        }
      }
    }
    
    bool isInside = (crossings % 2 == 1);
    
    // Debug logging for troubleshooting
    if (kDebugMode) {
      print('[ZONE_DEBUG] Point (${point.latitude}, ${point.longitude}) -> $crossings crossings -> $isInside');
    }
    
    return isInside;
  }

  static final smtpServer = SmtpServer(mailSettings!.host.toString(),
      username: mailSettings!.userName.toString(),
      password: mailSettings!.password.toString(),
      port: 465,
      ignoreBadCertificate: false,
      ssl: true,
      allowInsecure: true);

  static sendMail(
      {String? subject,
      String? body,
      bool? isAdmin = false,
      List<dynamic>? recipients}) async {
    // Create our message.
    if (mailSettings != null) {
      if (isAdmin == true) {
        recipients!.add(mailSettings!.userName.toString());
      }
      final message = Message()
        ..from = Address(mailSettings!.userName.toString(),
            mailSettings!.fromName.toString())
        ..recipients = recipients!
        ..subject = subject
        ..text = body
        ..html = body;

      try {
        final sendReport = await send(message, smtpServer);
        print('Message sent: $sendReport');
      } on MailerException catch (e) {
        print(e);
        print('Message not sent.');
        for (var p in e.problems) {
          print('Problem: ${p.code}: ${p.msg}');
        }
      }
    }

    // var connection = PersistentConnection(smtpServer);
    //
    // // Send the first message
    // await connection.send(message);
  }

  static Uri createCoordinatesUrl(double latitude, double longitude,
      [String? label]) {
    Uri uri;
    if (kIsWeb) {
      uri = Uri.https('www.google.com', '/maps/search/',
          {'api': '1', 'query': '$latitude,$longitude'});
    } else if (Platform.isAndroid) {
      var query = '$latitude,$longitude';
      if (label != null) query += '($label)';
      uri = Uri(scheme: 'geo', host: '0,0', queryParameters: {'q': query});
    } else if (Platform.isIOS) {
      var params = {'ll': '$latitude,$longitude'};
      if (label != null) params['q'] = label;
      uri = Uri.https('maps.apple.com', '/', params);
    } else {
      uri = Uri.https('www.google.com', '/maps/search/',
          {'api': '1', 'query': '$latitude,$longitude'});
    }

    return uri;
  }

  static sendOrderEmail({required OrderModel orderModel}) async {
    EmailTemplateModel? emailTemplateModel =
        await FireStoreUtils.getEmailTemplates(newOrderPlaced);
    if (emailTemplateModel != null) {
      String firstHTML = """
       <table style="width: 100%; border-collapse: collapse; border: 1px solid rgb(0, 0, 0);">
    <thead>
        <tr>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Product Name<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Quantity<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Price<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Extra Item Price<br></th>
            <th style="text-align: left; border: 1px solid rgb(0, 0, 0);">Total<br></th>
        </tr>
    </thead>
    <tbody>
    """;

      String newString = emailTemplateModel.message.toString();
      newString = newString.replaceAll("{username}",
          "${Constant.userModel!.firstName} ${Constant.userModel!.lastName}");
      newString = newString.replaceAll("{orderid}", orderModel.id.toString());
      newString = newString.replaceAll("{date}",
          DateFormat('yyyy-MM-dd').format(orderModel.createdAt!.toDate()));
      newString = newString.replaceAll(
        "{address}",
        orderModel.address!.getFullAddress(),
      );
      newString = newString.replaceAll(
        "{paymentmethod}",
        orderModel.paymentMethod.toString(),
      );

      double deliveryCharge = 0.0;
      double total = 0.0;
      double specialDiscount = 0.0;
      double discount = 0.0;
      double taxAmount = 0.0;
      double tipValue = 0.0;
      String specialLabel =
          '(${orderModel.specialDiscount!['special_discount_label']}${orderModel.specialDiscount!['specialType'] == "amount" ? currencyModel!.symbol : "%"})';
      List<String> htmlList = [];

      if (orderModel.deliveryCharge != null) {
        deliveryCharge = double.parse(orderModel.deliveryCharge.toString());
      }
      if (orderModel.tipAmount != null) {
        tipValue = double.parse(orderModel.tipAmount.toString());
      }
      for (var element in orderModel.products!) {
        // Check if this item has a promotional price
        final hasPromo = element.promoId != null && element.promoId!.isNotEmpty;
        
        double itemPrice;
        if (hasPromo) {
          // Use promotional price for calculations
          itemPrice = double.parse(element.price.toString());
        } else if (double.parse(element.discountPrice.toString()) <= 0) {
          // No promotion, no discount - use regular price
          itemPrice = double.parse(element.price.toString());
        } else {
          // Regular discount (non-promo) - use discount price
          itemPrice = double.parse(element.discountPrice.toString());
        }
        
        if (element.extrasPrice != null &&
            element.extrasPrice!.isNotEmpty &&
            double.parse(element.extrasPrice!) != 0.0) {
          total += double.parse(element.quantity.toString()) *
              double.parse(element.extrasPrice!);
        }
        total += double.parse(element.quantity.toString()) * itemPrice;

        List<dynamic>? addon = element.extras;
        String extrasDisVal = '';
        for (int i = 0; i < addon!.length; i++) {
          extrasDisVal +=
              '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
        }
        
        // Display the correct price in the HTML (promotional price if available)
        String displayPrice = hasPromo ? element.price.toString() : element.price.toString();
        String displayTotal = ((double.parse(element.quantity.toString()) * double.parse(element.extrasPrice!) + (double.parse(element.quantity.toString()) * itemPrice))).toString();
        
        String product = """
        <tr>
            <td style="width: 20%; border-top: 1px solid rgb(0, 0, 0);">${element.name}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${element.quantity}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: displayPrice)}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: element.extrasPrice.toString())}</td>
            <td style="width: 20%; border: 1px solid rgb(0, 0, 0);" rowspan="2">${amountShow(amount: displayTotal)}</td>
        </tr>
        <tr>
            <td style="width: 20%;">${extrasDisVal.isEmpty ? "" : "Extra Item : $extrasDisVal"}</td>
        </tr>
    """;
        htmlList.add(product);
      }

      if (orderModel.specialDiscount!.isNotEmpty) {
        specialDiscount = double.parse(
            orderModel.specialDiscount!['special_discount'].toString());
      }

      if (orderModel.couponId != null && orderModel.couponId!.isNotEmpty) {
        discount = double.parse(orderModel.discount.toString());
      }

      List<String> taxHtmlList = [];
      if (taxList != null) {
        for (var element in taxList!) {
          taxAmount = taxAmount +
              calculateTax(
                  amount: (total - discount - specialDiscount).toString(),
                  taxModel: element);
          String taxHtml =
              """<span style="font-size: 1rem;">${element.title}: ${amountShow(amount: calculateTax(amount: (total - discount - specialDiscount).toString(), taxModel: element).toString())}${taxList!.indexOf(element) == taxList!.length - 1 ? "</span>" : "<br></span>"}""";
          taxHtmlList.add(taxHtml);
        }
      }

      var totalamount = orderModel.deliveryCharge == null ||
              orderModel.deliveryCharge!.isEmpty
          ? total + taxAmount - discount - specialDiscount
          : total +
              taxAmount +
              double.parse(orderModel.deliveryCharge!) +
              double.parse(orderModel.tipAmount!) -
              discount -
              specialDiscount;

      newString = newString.replaceAll(
          "{subtotal}", amountShow(amount: total.toString()));
      newString =
          newString.replaceAll("{coupon}", orderModel.couponId.toString());
      newString = newString.replaceAll("{discountamount}",
          amountShow(amount: orderModel.discount.toString()));
      newString = newString.replaceAll("{specialcoupon}", specialLabel);
      newString = newString.replaceAll("{specialdiscountamount}",
          amountShow(amount: specialDiscount.toString()));
      newString = newString.replaceAll(
          "{shippingcharge}", amountShow(amount: deliveryCharge.toString()));
      newString = newString.replaceAll(
          "{tipamount}", amountShow(amount: tipValue.toString()));
      newString = newString.replaceAll(
          "{totalAmount}", amountShow(amount: totalamount.toString()));

      String tableHTML = htmlList.join();
      String lastHTML = "</tbody></table>";
      newString = newString.replaceAll(
          "{productdetails}", firstHTML + tableHTML + lastHTML);
      newString = newString.replaceAll("{taxdetails}", taxHtmlList.join());
      newString = newString.replaceAll("{newwalletbalance}.",
          amountShow(amount: Constant.userModel!.walletAmount.toString()));

      String subjectNewString = emailTemplateModel.subject.toString();
      subjectNewString =
          subjectNewString.replaceAll("{orderid}", orderModel.id.toString());
      await sendMail(
          subject: subjectNewString,
          isAdmin: emailTemplateModel.isSendToAdmin,
          body: newString,
          recipients: [Constant.userModel!.email]);
    }
  }

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = Constant._degToRad(lat2 - lat1);
    final dLon = Constant._degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(Constant._degToRad(lat1)) *
            cos(Constant._degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180);

  /// Helper method to safely convert coordinates to string
  static String _safeCoordinateToString(dynamic coordinate) {
    if (coordinate == null) return "0.0";
    if (coordinate is double) return coordinate.toString();
    if (coordinate is int) return coordinate.toDouble().toString();
    if (coordinate is String) return coordinate;
    return "0.0";
  }

  /// Enhanced distance calculation with better coordinate handling
  static String getDistanceFromVendor(VendorModel vendor) {
    if (Constant.selectedLocation.location == null) {
      print('DEBUG: getDistanceFromVendor - No selected location');
      return "0.0";
    }

    String vendorLat = _safeCoordinateToString(vendor.latitude);
    String vendorLng = _safeCoordinateToString(vendor.longitude);
    String userLat = _safeCoordinateToString(Constant.selectedLocation.location!.latitude);
    String userLng = _safeCoordinateToString(Constant.selectedLocation.location!.longitude);

    // Debug logging for distance calculation
    print('DEBUG: Distance calculation for ${vendor.title}');
    print('  Vendor coordinates: $vendorLat, $vendorLng');
    print('  User coordinates: $userLat, $userLng');

    String distance = getDistance(
      lat1: vendorLat,
      lng1: vendorLng,
      lat2: userLat,
      lng2: userLng,
    );

    print('  Calculated distance: $distance ${distanceType}');
    return distance;
  }

  String getTimeInTheMinutes({required double distance}) {
    double averageSpeed = 40.0;
    double estimatedTime = (distance / averageSpeed) * 60;
    return "${estimatedTime.toStringAsFixed(2)} minutes";
  }
}

extension StringExtension on String {
  String capitalizeString() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
