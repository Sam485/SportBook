import 'dto/category_dto.dart';
import 'dto/owner_dto.dart';

class SlotModel {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final double price;
  final int capacity;
  final bool isAvailable;
  final int sportClubId;
  final CategoryDto? category;
  final OwnerDto createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SlotModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.capacity,
    required this.isAvailable,
    required this.sportClubId,
    this.category,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
      isAvailable: json['is_available'] ?? false,
      sportClubId: json['sport_club_id'] ?? 0,
      category: json['category'] != null
          ? CategoryDto.fromJson(json['category'])
          : null,
      createdBy: OwnerDto.fromJson(json['created_by'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'price': price,
      'capacity': capacity,
      'is_available': isAvailable,
      'sport_club_id': sportClubId,
      'category': category?.toJson(),
      'created_by': createdBy.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
