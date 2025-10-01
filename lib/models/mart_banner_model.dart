class MartBannerModel {
  String? id;
  String? title;
  String? text;
  String? description;
  String? photo;
  String? position; // "top" or "bottom"
  String? redirectType; // "external_link", "store", "product", "category", "mart_category"
  String? externalLink;
  String? productId;
  String? storeId;
  String? categoryId;
  String? martCategoryId;
  String? zoneId;
  String? zoneTitle;
  bool? isPublish;
  int? setOrder;
  DateTime? createdAt;
  DateTime? updatedAt;

  MartBannerModel({
    this.id,
    this.title,
    this.text,
    this.description,
    this.photo,
    this.position,
    this.redirectType,
    this.externalLink,
    this.productId,
    this.storeId,
    this.categoryId,
    this.martCategoryId,
    this.zoneId,
    this.zoneTitle,
    this.isPublish,
    this.setOrder,
    this.createdAt,
    this.updatedAt,
  });

  MartBannerModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title']?.toString();
    text = json['text']?.toString();
    description = json['description']?.toString();
    photo = json['photo']?.toString();
    position = json['position']?.toString();
    redirectType = json['redirect_type']?.toString();
    externalLink = json['external_link']?.toString();
    productId = json['productId']?.toString();
    storeId = json['storeId']?.toString();
    categoryId = json['categoryId']?.toString();
    martCategoryId = json['martCategoryId']?.toString();
    zoneId = json['zoneId']?.toString();
    zoneTitle = json['zoneTitle']?.toString();
    isPublish = json['is_publish'] as bool?;
    setOrder = json['set_order'] as int?;
    
    // Handle timestamp fields
    if (json['created_at'] != null) {
      if (json['created_at'] is DateTime) {
        createdAt = json['created_at'] as DateTime;
      } else if (json['created_at'] is Map) {
        // Handle Firestore Timestamp
        final timestamp = json['created_at'];
        if (timestamp['_seconds'] != null) {
          createdAt = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
        }
      }
    }
    
    if (json['updated_at'] != null) {
      if (json['updated_at'] is DateTime) {
        updatedAt = json['updated_at'] as DateTime;
      } else if (json['updated_at'] is Map) {
        // Handle Firestore Timestamp
        final timestamp = json['updated_at'];
        if (timestamp['_seconds'] != null) {
          updatedAt = DateTime.fromMillisecondsSinceEpoch(timestamp['_seconds'] * 1000);
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['text'] = text;
    data['description'] = description;
    data['photo'] = photo;
    data['position'] = position;
    data['redirect_type'] = redirectType;
    data['external_link'] = externalLink;
    data['productId'] = productId;
    data['storeId'] = storeId;
    data['categoryId'] = categoryId;
    data['martCategoryId'] = martCategoryId;
    data['zoneId'] = zoneId;
    data['zoneTitle'] = zoneTitle;
    data['is_publish'] = isPublish;
    data['set_order'] = setOrder;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }

  // Alias for fromJson to match expected method name
  factory MartBannerModel.fromMap(Map<String, dynamic> json, [String? id]) {
    final data = {...json};
    if (id != null) {
      data['id'] = id;
    }
    return MartBannerModel.fromJson(data);
  }

  // Helper methods
  bool get isTopBanner => position == 'top';
  bool get isBottomBanner => position == 'bottom';
  bool get isPublished => isPublish == true;
  
  // Get redirect ID based on redirect type
  String? get redirectId {
    switch (redirectType) {
      case 'external_link':
        return externalLink;
      case 'store':
        return storeId;
      case 'product':
        return productId;
      case 'category':
        return categoryId;
      case 'mart_category':
        return martCategoryId;
      default:
        return null;
    }
  }
}