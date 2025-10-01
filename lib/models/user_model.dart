import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/models/subscription_plan_model.dart';

class UserModel {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? profilePictureURL;
  String? fcmToken;
  String? countryCode;
  String? phoneNumber;
  double? walletAmount;
  bool? active;
  bool? isActive;
  bool? isDocumentVerify;
  Timestamp? createdAt;
  String? role;
  UserLocation? location;
  UserBankDetails? userBankDetails;
  List<ShippingAddress>? shippingAddress;
  String? carName;
  String? carNumber;
  String? carPictureURL;
  List<dynamic>? inProgressOrderID;
  List<dynamic>? orderRequestData;
  String? vendorID;
  String? zoneId;
  num? rotation;
  String? appIdentifier;
  String? provider;
  String? subscriptionPlanId;
  Timestamp? subscriptionExpiryDate;
  SubscriptionPlanModel? subscriptionPlan;

  UserModel({
    this.id,
    this.firstName,
    this.lastName,
    this.active,
    this.isActive,
    this.isDocumentVerify,
    this.email,
    this.profilePictureURL,
    this.fcmToken,
    this.countryCode,
    this.phoneNumber,
    this.walletAmount,
    this.createdAt,
    this.role,
    this.location,
    this.shippingAddress,
    this.carName,
    this.carNumber,
    this.carPictureURL,
    this.inProgressOrderID,
    this.orderRequestData,
    this.vendorID,
    this.zoneId,
    this.rotation,
    this.appIdentifier,
    this.provider,
    this.subscriptionPlanId,
    this.subscriptionExpiryDate,
    this.subscriptionPlan,
  });

  String fullName() {
    return "${firstName ?? ''} ${lastName ?? ''}";
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      List<ShippingAddress>? addresses;
      if (json['shippingAddress'] != null) {
        if (json['shippingAddress'] is List) {
          addresses = (json['shippingAddress'] as List).map((e) {
            if (e is Map<String, dynamic>) {
              return ShippingAddress.fromJson(e);
            } else if (e is String) {
              try {
                return ShippingAddress.fromJson(jsonDecode(e));
              } catch (e) {
                log('Error parsing shipping address string: $e');
                return ShippingAddress();
              }
            }
            return ShippingAddress();
          }).toList();
        } else if (json['shippingAddress'] is Map) {
          addresses = [ShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>)];
        } else if (json['shippingAddress'] is String) {
          try {
            addresses = [ShippingAddress.fromJson(jsonDecode(json['shippingAddress']))];
          } catch (e) {
            log('Error parsing shipping address string: $e');
            addresses = [];
          }
        } else {
          addresses = [];
        }
      }

      return UserModel(
        id: json['id']?.toString(),
        email: json['email']?.toString(),
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        profilePictureURL: json['profilePictureURL']?.toString(),
        fcmToken: json['fcmToken']?.toString(),
        countryCode: json['countryCode']?.toString(),
        phoneNumber: json['phoneNumber']?.toString(),
        walletAmount: (json['wallet_amount'] is num) ? (json['wallet_amount'] as num).toDouble() : 0.0,
        createdAt: json['createdAt'] as Timestamp?,
        active: json['active'] as bool?,
        isActive: json['isActive'] as bool?,
        role: json['role']?.toString(),
        isDocumentVerify: json['isDocumentVerify'] as bool?,
        zoneId: json['zoneId']?.toString(),
        appIdentifier: json['appIdentifier']?.toString(),
        provider: json['provider']?.toString(),
        shippingAddress: addresses,
      );
    } catch (e) {
      log('Error converting user data: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureURL': profilePictureURL,
      'fcmToken': fcmToken,
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'wallet_amount': walletAmount,
      'createdAt': createdAt,
      'active': active,
      'isActive': isActive,
      'role': role,
      'isDocumentVerify': isDocumentVerify,
      'zoneId': zoneId,
      'appIdentifier': appIdentifier,
      'provider': provider,
      'shippingAddress': shippingAddress?.map((e) => e.toJson()).toList(),
    };
  }
}

class UserLocation {
  double? latitude;
  double? longitude;

  UserLocation({this.latitude, this.longitude});

  UserLocation.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class ShippingAddress {
  String? id;
  String? address;
  String? addressAs;
  String? landmark;
  String? locality;
  UserLocation? location;
  bool? isDefault;
  String? zoneId; // 🔑 Add zoneId field for delivery zone validation

  ShippingAddress({this.address, this.landmark, this.locality, this.location, this.isDefault, this.addressAs, this.id, this.zoneId});

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    address = json['address'];
    landmark = json['landmark'];
    locality = json['locality'];
    isDefault = json['isDefault'];
    addressAs = json['addressAs'];
    zoneId = json['zoneId']; // 🔑 Parse zoneId
    location = json['location'] == null ? null : UserLocation.fromJson(json['location']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address'] = address;
    data['landmark'] = landmark;
    data['locality'] = locality;
    data['isDefault'] = isDefault;
    data['addressAs'] = addressAs;
    data['zoneId'] = zoneId; // 🔑 Include zoneId
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }

  String getFullAddress() {
    List<String> addressParts = [];
    
    // Add address if available
    if (address != null && address!.isNotEmpty) {
      addressParts.add(address!);
    }
    
    // Add locality if available and different from address
    if (locality != null && locality!.isNotEmpty && locality != address) {
      addressParts.add(locality!);
    }
    
    // Add landmark if available and different from address and locality
    if (landmark != null && landmark!.isNotEmpty && 
        landmark != address && landmark != locality) {
      addressParts.add(landmark!);
    }
    
    // **FIXED: Remove duplicates and clean up the address**
    List<String> uniqueParts = [];
    for (String part in addressParts) {
      String cleanPart = part.trim();
      if (cleanPart.isNotEmpty && !uniqueParts.contains(cleanPart)) {
        uniqueParts.add(cleanPart);
      }
    }
    
    // Join with commas and clean up
    String fullAddress = uniqueParts.join(', ');
    
    // If no address parts, return a default message
    if (fullAddress.isEmpty) {
      return 'Current Location';
    }
    
    return fullAddress;
  }

  ShippingAddress copyWith({
    String? id,
    String? address,
    String? addressAs,
    String? landmark,
    String? locality,
    UserLocation? location,
    bool? isDefault,
    String? zoneId,
  }) {
    return ShippingAddress(
      id: id ?? this.id,
      address: address ?? this.address,
      addressAs: addressAs ?? this.addressAs,
      landmark: landmark ?? this.landmark,
      locality: locality ?? this.locality,
      location: location ?? this.location,
      isDefault: isDefault ?? this.isDefault,
      zoneId: zoneId ?? this.zoneId,
    );
  }
}

class UserBankDetails {
  String bankName;
  String branchName;
  String holderName;
  String accountNumber;
  String otherDetails;

  UserBankDetails({
    this.bankName = '',
    this.otherDetails = '',
    this.branchName = '',
    this.accountNumber = '',
    this.holderName = '',
  });

  factory UserBankDetails.fromJson(Map<String, dynamic> parsedJson) {
    return UserBankDetails(
      bankName: parsedJson['bankName'] ?? '',
      branchName: parsedJson['branchName'] ?? '',
      holderName: parsedJson['holderName'] ?? '',
      accountNumber: parsedJson['accountNumber'] ?? '',
      otherDetails: parsedJson['otherDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'branchName': branchName,
      'holderName': holderName,
      'accountNumber': accountNumber,
      'otherDetails': otherDetails,
    };
  }
}
