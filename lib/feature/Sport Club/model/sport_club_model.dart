class SportClubModel {
  final int id;
  final String name;
  final double lat;
  final double lng;
  final String location;
  final bool isOpen;
  final String openTime;
  final String closeTime;
  final String description;
  final List<int> categoryIds;
  final List<String> imageUrl;

  SportClubModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.location,
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.description,
    required this.categoryIds,
    required this.imageUrl,
  });

  factory SportClubModel.fromJson(Map<String, dynamic> json) {
    return SportClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: json['lat'] ?? 0.00,
      lng: json['lng'] ?? 0.00,
      location: json['location'] ?? '',
      isOpen: json['is_open'] ?? '',
      openTime: json['open_time'] ?? '',
      closeTime: json['close_time'] ?? '',
      description: json['description'] ?? '',
      categoryIds: List<int>.from(json['category_ids']),
      imageUrl: List<String>.from(json['images']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'location': location,
      'is_open': isOpen,
      'open_time': openTime,
      'close_time': closeTime,
      'description': description,
      'category_ids': categoryIds,
      'images': imageUrl,
    };
  }
}
