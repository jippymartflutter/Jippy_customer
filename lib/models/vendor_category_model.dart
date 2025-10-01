class VendorCategoryModel {
  List<dynamic>? reviewAttributes;
  String? photo;
  String? description;
  String? id;
  String? title;
  int? productCount; // Add product count property

  VendorCategoryModel({this.reviewAttributes, this.photo, this.description, this.id, this.title, this.productCount});

  VendorCategoryModel.fromJson(Map<String, dynamic> json) {
    reviewAttributes = json['review_attributes'] ?? [];
    photo = json['photo'] ?? "";
    description = json['description'] ?? '';
    id = json['id'] ?? "";
    title = json['title'] ?? "";
    productCount = json['product_count'] ?? 0; // Parse product count from JSON
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_attributes'] = reviewAttributes;
    data['photo'] = photo;
    data['description'] = description;
    data['id'] = id;
    data['title'] = title;
    data['product_count'] = productCount; // Include product count in JSON
    return data;
  }
}
