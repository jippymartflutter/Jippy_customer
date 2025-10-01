

class MartCategoryModel {
  String? id;
  String? title;
  String? description;
  String? photo;
  bool? publish;
  bool? showInHomepage;
  String? martId;
  List<String>? reviewAttributes;
  String? migratedBy;
  String? createdAt;
  String? updatedAt;
  int? itemCount;
  String? icon;
  String? color;
  String? backgroundColor;
  String? section;
  int? sectionOrder;
  int? categoryOrder;
  int? sortOrder;
  
  // Sub-categories relationship
  bool? hasSubcategories;
  int? subcategoriesCount;

  MartCategoryModel({
    this.id,
    this.title,
    this.description,
    this.photo,
    this.publish,
    this.showInHomepage,
    this.martId,
    this.reviewAttributes,
    this.migratedBy,
    this.createdAt,
    this.updatedAt,
    this.itemCount,
    this.icon,
    this.color,
    this.backgroundColor,
    this.section,
    this.sectionOrder,
    this.categoryOrder,
    this.sortOrder,
    this.hasSubcategories,
    this.subcategoriesCount,
  });

  MartCategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[MART CATEGORY MODEL] Parsing JSON: ${json.keys.toList()}');
      
      id = json['id'];
      title = json['title'];
      description = json['description'];
      photo = json['photo'];
      publish = json['publish'];
      showInHomepage = json['show_in_homepage'];
      martId = json['mart_id'];
      
      // Safe parsing for review_attributes
      if (json['review_attributes'] != null) {
        print('[MART CATEGORY MODEL] review_attributes type: ${json['review_attributes'].runtimeType}');
        if (json['review_attributes'] is List) {
          try {
            // Handle empty list case
            if (json['review_attributes'].isEmpty) {
              reviewAttributes = [];
            } else {
              reviewAttributes = List<String>.from(json['review_attributes']);
            }
          } catch (e) {
            print('[MART CATEGORY MODEL] Error converting review_attributes to List<String>: $e');
            reviewAttributes = [];
          }
        } else {
          print('[MART CATEGORY MODEL] review_attributes is not a List, setting to empty list');
          reviewAttributes = [];
        }
      } else {
        reviewAttributes = [];
      }
      
      migratedBy = json['migratedBy'];
      createdAt = json['createdAt'];
      updatedAt = json['updated_at'];
      itemCount = json['itemCount'] ?? json['item_count'];
      icon = json['icon'];
      color = json['color'];
      backgroundColor = json['background_color'];
      section = json['section'];
      sectionOrder = json['section_order'];
      categoryOrder = json['category_order'];
      sortOrder = json['sortOrder'] ?? json['sort_order'];
      
      // Sub-categories relationship
      hasSubcategories = json['has_subcategories'];
      subcategoriesCount = json['subcategories_count'];
      
      print('[MART CATEGORY MODEL] Successfully parsed category: $title');
    } catch (e, stackTrace) {
      print('[MART CATEGORY MODEL] Error parsing JSON: $e');
      print('[MART CATEGORY MODEL] Stack trace: $stackTrace');
      print('[MART CATEGORY MODEL] JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['photo'] = photo;
    data['publish'] = publish;
    data['show_in_homepage'] = showInHomepage;
    data['mart_id'] = martId;
    data['review_attributes'] = reviewAttributes;
    data['migratedBy'] = migratedBy;
    data['createdAt'] = createdAt;
    data['updated_at'] = updatedAt;
    data['itemCount'] = itemCount;
    data['icon'] = icon;
    data['color'] = color;
    data['background_color'] = backgroundColor;
    data['section'] = section;
    data['section_order'] = sectionOrder;
    data['category_order'] = categoryOrder;
    data['sortOrder'] = sortOrder;
    
    // Sub-categories relationship
    data['has_subcategories'] = hasSubcategories;
    data['subcategories_count'] = subcategoriesCount;
    return data;
  }

  // Helper methods
  
  // Legacy compatibility getters
  int get productCount => itemCount ?? 0;
  String get displayName => title ?? '';
  String get displayDescription => description ?? '';
  String get mainImage => photo ?? '';
  bool get isPublished => publish ?? false;
  bool get showInHomepageBool => showInHomepage ?? false;
  bool get isFeatured => showInHomepage ?? false;
  bool get isGlobal => martId == null || martId!.isEmpty;
  
  String get imageUrl => photo ?? '';
  String get iconUrl => icon ?? '';
  
  int get totalItems => itemCount ?? 0;
  
  // For UI display
  String get shortDescription {
    if (description == null || description!.isEmpty) return '';
    if (description!.length <= 50) return description!;
    return '${description!.substring(0, 50)}...';
  }
  
  // Check if category is available for a specific mart
  bool isAvailableForMart(String? vendorId) {
    if (isGlobal) return true;
    return martId == vendorId;
  }
}
