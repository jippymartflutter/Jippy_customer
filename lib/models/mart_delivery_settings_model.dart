import 'package:cloud_firestore/cloud_firestore.dart';

class MartDeliverySettingsModel {
  // Delivery Settings
  final double freeDeliveryThreshold;
  final String deliveryPromotionText;
  final bool isActive;
  
  // Distance-based Delivery Settings
  final double freeDeliveryDistanceKm;
  final double perKmChargeAboveFreeDistance;
  
  // Cart Settings
  final double minOrderValue;
  final bool minOrderEnabled;
  final String minOrderMessage;
  
  // General Settings
  final String appName;
  final String currency;
  final String currencySymbol;
  final bool maintenanceMode;
  final String maintenanceMessage;
  
  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MartDeliverySettingsModel({
    // Delivery Settings
    required this.freeDeliveryThreshold,
    required this.deliveryPromotionText,
    this.isActive = true,
    
    // Distance-based Delivery Settings
    this.freeDeliveryDistanceKm = 3.0,
    this.perKmChargeAboveFreeDistance = 7.0,
    
    // Cart Settings
    required this.minOrderValue,
    this.minOrderEnabled = true,
    required this.minOrderMessage,
    
    // General Settings
    this.appName = 'Jippy Mart',
    this.currency = 'INR',
    this.currencySymbol = '₹',
    this.maintenanceMode = false,
    this.maintenanceMessage = 'App is under maintenance. Please try again later.',
    
    // Timestamps
    this.createdAt,
    this.updatedAt,
  });

  /// Create from Firestore document
  factory MartDeliverySettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MartDeliverySettingsModel(
      // Delivery Settings
      freeDeliveryThreshold: (data['free_delivery_threshold'] ?? 99.0).toDouble(),
      deliveryPromotionText: data['delivery_promotion_text'] ?? 'daily',
      isActive: data['is_active'] ?? true,
      
      // Distance-based Delivery Settings
      freeDeliveryDistanceKm: (data['free_delivery_distance_km'] ?? 3.0).toDouble(),
      perKmChargeAboveFreeDistance: (data['per_km_charge_above_free_distance'] ?? 7.0).toDouble(),
      
      // Cart Settings
      minOrderValue: (data['min_order_value'] ?? 99.0).toDouble(),
      minOrderEnabled: data['min_order_enabled'] ?? true,
      minOrderMessage: data['min_order_message'] ?? 'Minimum order value is ₹99. Please add more items to your cart.',
      
      // General Settings
      appName: data['app_name'] ?? 'Jippy Mart',
      currency: data['currency'] ?? 'INR',
      currencySymbol: data['currency_symbol'] ?? '₹',
      maintenanceMode: data['maintenance_mode'] ?? false,
      maintenanceMessage: data['maintenance_message'] ?? 'App is under maintenance. Please try again later.',
      
      // Timestamps
      createdAt: data['created_at']?.toDate(),
      updatedAt: data['updated_at']?.toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      // Delivery Settings
      'free_delivery_threshold': freeDeliveryThreshold,
      'delivery_promotion_text': deliveryPromotionText,
      'is_active': isActive,
      
      // Distance-based Delivery Settings
      'free_delivery_distance_km': freeDeliveryDistanceKm,
      'per_km_charge_above_free_distance': perKmChargeAboveFreeDistance,
      
      // Cart Settings
      'min_order_value': minOrderValue,
      'min_order_enabled': minOrderEnabled,
      'min_order_message': minOrderMessage,
      
      // General Settings
      'app_name': appName,
      'currency': currency,
      'currency_symbol': currencySymbol,
      'maintenance_mode': maintenanceMode,
      'maintenance_message': maintenanceMessage,
      
      // Timestamps
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  MartDeliverySettingsModel copyWith({
    // Delivery Settings
    double? freeDeliveryThreshold,
    String? deliveryPromotionText,
    bool? isActive,
    
    // Distance-based Delivery Settings
    double? freeDeliveryDistanceKm,
    double? perKmChargeAboveFreeDistance,
    
    // Cart Settings
    double? minOrderValue,
    bool? minOrderEnabled,
    String? minOrderMessage,
    
    // General Settings
    String? appName,
    String? currency,
    String? currencySymbol,
    bool? maintenanceMode,
    String? maintenanceMessage,
    
    // Timestamps
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MartDeliverySettingsModel(
      // Delivery Settings
      freeDeliveryThreshold: freeDeliveryThreshold ?? this.freeDeliveryThreshold,
      deliveryPromotionText: deliveryPromotionText ?? this.deliveryPromotionText,
      isActive: isActive ?? this.isActive,
      
      // Distance-based Delivery Settings
      freeDeliveryDistanceKm: freeDeliveryDistanceKm ?? this.freeDeliveryDistanceKm,
      perKmChargeAboveFreeDistance: perKmChargeAboveFreeDistance ?? this.perKmChargeAboveFreeDistance,
      
      // Cart Settings
      minOrderValue: minOrderValue ?? this.minOrderValue,
      minOrderEnabled: minOrderEnabled ?? this.minOrderEnabled,
      minOrderMessage: minOrderMessage ?? this.minOrderMessage,
      
      // General Settings
      appName: appName ?? this.appName,
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      
      // Timestamps
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MartDeliverySettingsModel('
        'freeDeliveryThreshold: $freeDeliveryThreshold, '
        'deliveryPromotionText: $deliveryPromotionText, '
        'isActive: $isActive, '
        'freeDeliveryDistanceKm: $freeDeliveryDistanceKm, '
        'perKmChargeAboveFreeDistance: $perKmChargeAboveFreeDistance, '
        'minOrderValue: $minOrderValue, '
        'minOrderEnabled: $minOrderEnabled, '
        'minOrderMessage: $minOrderMessage, '
        'appName: $appName, '
        'currency: $currency, '
        'currencySymbol: $currencySymbol, '
        'maintenanceMode: $maintenanceMode, '
        'maintenanceMessage: $maintenanceMessage, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MartDeliverySettingsModel &&
        other.freeDeliveryThreshold == freeDeliveryThreshold &&
        other.deliveryPromotionText == deliveryPromotionText &&
        other.isActive == isActive &&
        other.freeDeliveryDistanceKm == freeDeliveryDistanceKm &&
        other.perKmChargeAboveFreeDistance == perKmChargeAboveFreeDistance &&
        other.minOrderValue == minOrderValue &&
        other.minOrderEnabled == minOrderEnabled &&
        other.minOrderMessage == minOrderMessage &&
        other.appName == appName &&
        other.currency == currency &&
        other.currencySymbol == currencySymbol &&
        other.maintenanceMode == maintenanceMode &&
        other.maintenanceMessage == maintenanceMessage &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return freeDeliveryThreshold.hashCode ^
        deliveryPromotionText.hashCode ^
        isActive.hashCode ^
        freeDeliveryDistanceKm.hashCode ^
        perKmChargeAboveFreeDistance.hashCode ^
        minOrderValue.hashCode ^
        minOrderEnabled.hashCode ^
        minOrderMessage.hashCode ^
        appName.hashCode ^
        currency.hashCode ^
        currencySymbol.hashCode ^
        maintenanceMode.hashCode ^
        maintenanceMessage.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
