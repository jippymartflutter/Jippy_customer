class MartSubcategoryModel {
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
  int? subcategoryOrder;
  int? sortOrder;
  
  // Parent category relationship
  String? parentCategoryId;
  String? parentCategoryTitle;
  
  // Sub-categories relationship
  bool? hasSubcategories;
  int? subcategoriesCount;

  MartSubcategoryModel({
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
    this.subcategoryOrder,
    this.sortOrder,
    this.parentCategoryId,
    this.parentCategoryTitle,
    this.hasSubcategories,
    this.subcategoriesCount,
  });

  MartSubcategoryModel.fromJson(Map<String, dynamic> json) {
    try {
      print('[MART SUBCATEGORY MODEL] Parsing JSON: ${json.keys.toList()}');
      
      id = json['id'];
      title = json['title'];
      description = json['description'];
      photo = json['photo'];
      publish = json['publish'];
      showInHomepage = json['show_in_homepage'];
      martId = json['mart_id'];
      
      // Safe parsing for review_attributes
      if (json['review_attributes'] != null) {
        if (json['review_attributes'] is List) {
          try {
            if (json['review_attributes'].isEmpty) {
              reviewAttributes = [];
            } else {
              reviewAttributes = List<String>.from(json['review_attributes']);
            }
          } catch (e) {
            print('[MART SUBCATEGORY MODEL] Error converting review_attributes to List<String>: $e');
            reviewAttributes = [];
          }
        } else {
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
      subcategoryOrder = json['subcategory_order'];
      sortOrder = json['sortOrder'] ?? json['sort_order'];
      
      // Parent category relationship
      parentCategoryId = json['parent_category_id'];
      parentCategoryTitle = json['parent_category_title'];
      
      // Sub-categories relationship
      hasSubcategories = json['has_subcategories'];
      subcategoriesCount = json['subcategories_count'];
      
      print('[MART SUBCATEGORY MODEL] Successfully parsed subcategory: $title');
    } catch (e, stackTrace) {
      print('[MART SUBCATEGORY MODEL] Error parsing JSON: $e');
      print('[MART SUBCATEGORY MODEL] Stack trace: $stackTrace');
      print('[MART SUBCATEGORY MODEL] JSON data: $json');
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
    data['subcategory_order'] = subcategoryOrder;
    data['sortOrder'] = sortOrder;
    
    // Parent category relationship
    data['parent_category_id'] = parentCategoryId;
    data['parent_category_title'] = parentCategoryTitle;
    
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
  
  // Get a valid image URL with fallback
  String get validImageUrl {
    // Check if the photo URL is valid (not empty and not the default logo)
    if (photo != null && photo!.isNotEmpty && !photo!.contains('logo%20jippy%20bike')) {
      return photo!;
    }
    
    // Return empty string to use default icon
    return '';
  }
  
  // Get a valid image URL with parent category fallback
  String getValidImageUrlWithParentFallback(String? parentImageUrl) {
    // Check if the photo URL is valid and fix broken URLs
    if (photo != null && photo!.isNotEmpty) {
      // Fix broken .app URLs to .googleapis.com
      String fixedPhotoUrl = photo!;
      if (fixedPhotoUrl.contains('firebasestorage.app') && !fixedPhotoUrl.contains('googleapis.com')) {
        fixedPhotoUrl = fixedPhotoUrl.replaceAll('firebasestorage.app', 'firebasestorage.googleapis.com');
        print('[MART SUBCATEGORY MODEL] 🔧 Fixed broken URL: ${photo!} -> $fixedPhotoUrl');
      }
      
      // Skip default logo images and obviously broken URLs
      if (!fixedPhotoUrl.contains('logo%20jippy%20bike') && 
          !fixedPhotoUrl.contains('logo jippy bike') &&
          fixedPhotoUrl.contains('firebasestorage.googleapis.com')) {
        return fixedPhotoUrl;
      }
    }
    
    // Use parent category image as fallback
    if (parentImageUrl != null && parentImageUrl.isNotEmpty) {
      print('[MART SUBCATEGORY MODEL] 📸 Using parent category image as fallback: $parentImageUrl');
      return parentImageUrl;
    }
    
    // Return empty string to use default icon
    print('[MART SUBCATEGORY MODEL] ⚠️ No valid image found, using default icon');
    return '';
  }
  

  
  // Check if subcategory is available for a specific mart
  bool isAvailableForMart(String? vendorId) {
    if (isGlobal) return true;
    return martId == vendorId;
  }
  
  // Check if this subcategory belongs to a specific parent category
  bool belongsToCategory(String categoryId) {
    return parentCategoryId == categoryId;
  }
}
