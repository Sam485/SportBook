import 'dart:io';

class SlotModel {
  final int sportClubId;
  final String name;
  final String description;
  final double price;
  final int capacity;
  final bool isAvailable;
  final int categoryId;
  final File? image; // Made nullable since it might not always be available

  SlotModel({
    required this.sportClubId,
    required this.name,
    required this.description,
    required this.price,
    required this.capacity,
    required this.isAvailable,
    required this.categoryId,
    this.image,
  });

  /// Create a SlotModel from JSON (for API responses)
  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      sportClubId: json['sportClubId'] ?? json['sport_club_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      capacity: json['capacity'] ?? 0,
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? false,
      categoryId: json['categoryId'] ?? json['category_id'] ?? 0,
      image: json['image'] != null ? File(json['image']) : null,
    );
  }

  /// Convert SlotModel to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'sportClubId': sportClubId,
      'name': name,
      'description': description,
      'price': price,
      'capacity': capacity,
      'isAvailable': isAvailable,
      'categoryId': categoryId,
      'image': image?.path,
    };
  }

  /// Create a copy with updated fields
  SlotModel copyWith({
    int? sportClubId,
    String? name,
    String? description,
    double? price,
    int? capacity,
    bool? isAvailable,
    int? categoryId,
    File? image,
  }) {
    return SlotModel(
      sportClubId: sportClubId ?? this.sportClubId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      isAvailable: isAvailable ?? this.isAvailable,
      categoryId: categoryId ?? this.categoryId,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return 'SlotModel(sportClubId: $sportClubId, name: $name, price: $price, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SlotModel &&
        other.sportClubId == sportClubId &&
        other.name == name &&
        other.description == description &&
        other.price == price &&
        other.capacity == capacity &&
        other.isAvailable == isAvailable &&
        other.categoryId == categoryId &&
        other.image?.path == image?.path;
  }

  @override
  int get hashCode {
    return Object.hash(
      sportClubId,
      name,
      description,
      price,
      capacity,
      isAvailable,
      categoryId,
      image?.path,
    );
  }
}
