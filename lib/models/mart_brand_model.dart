import 'package:cloud_firestore/cloud_firestore.dart';

class MartBrandModel {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String slug;
  final bool status;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  MartBrandModel({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.slug,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MartBrandModel.fromJson(Map<String, dynamic> json) {
    return MartBrandModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      status: json['status'] ?? false,
      createdAt: json['created_at'] is Timestamp 
          ? json['created_at'] as Timestamp
          : null,
      updatedAt: json['updated_at'] is Timestamp 
          ? json['updated_at'] as Timestamp
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'slug': slug,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper getters
  bool get isActive => status;
  String get displayName => name;
  String get displayDescription => description;
  bool get hasLogo => logoUrl.isNotEmpty;
}
