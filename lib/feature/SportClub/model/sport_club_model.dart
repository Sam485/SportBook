// feature/SportClub/model/sport_club_model.dart
import 'package:flutter/material.dart';

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
  final List<String> imageUrls;
  final int favoriteCount;
  final List<dynamic> categories;
  final CreatorModel createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // COMPUTED PROPERTIES
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get color {
    final colors = [
      const Color(0xFFE74C3C), // Red
      const Color(0xFF2ECC71), // Green
      const Color(0xFFF39C12), // Orange
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFF3498DB), // Blue
      const Color(0xFFE67E22), // Dark Orange
      const Color(0xFF2C3E50), // Navy
      const Color(0xFF16A085), // Dark Teal
      const Color(0xFF8E44AD), // Dark Purple
    ];
    // FIX: Use modulo with safe division, handle id = 0
    return colors[id % colors.length];
  }

  double get distanceKm {
    // FIX: Return a default value instead of dividing by zero
    // You can calculate this based on user location
    // For now, return a random-looking value based on id
    if (id == 0) return 1.5; // Default distance
    return (id % 10) + 0.5 + (id % 5) / 10;
  }

  bool get isCurrentlyOpen {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;

    int parseTime(String timeStr) {
      try {
        final parts = timeStr.trim().split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        return hour * 60 + minute;
      } catch (_) {
        return 0;
      }
    }

    final openMinutes = parseTime(openTime);
    final closeMinutes = parseTime(closeTime);

    if (closeMinutes < openMinutes) {
      return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
    } else {
      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    }
  }

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
    required this.imageUrls,
    required this.favoriteCount,
    required this.categories,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SportClubModel.fromJson(Map<String, dynamic> json) {
    return SportClubModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      location: json['location'] ?? '',
      isOpen: json['is_open'] ?? false,
      openTime: json['open_time'] ?? '06:00',
      closeTime: json['close_time'] ?? '22:00',
      description: json['description'] ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : ['https://via.placeholder.com/400x300?text=No+Image'],
      favoriteCount: json['favorite_count'] ?? 0,
      categories: json['categories'] ?? [],
      createdBy: CreatorModel.fromJson(json['created_by'] ?? {}),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
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
      'image_urls': imageUrls,
      'favorite_count': favoriteCount,
      'categories': categories,
      'created_by': createdBy.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CreatorModel {
  final int id;
  final String fullName;
  final String role;

  CreatorModel({required this.id, required this.fullName, required this.role});

  factory CreatorModel.fromJson(Map<String, dynamic> json) {
    return CreatorModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'role': role};
  }
}
