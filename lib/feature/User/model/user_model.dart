class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String? avatarUrl;
  final String role;
  final double? lat;
  final double? lng;
  final String? location;
  final bool isVerified;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isVerified,
    required this.isActive,
    this.createdAt,
    this.avatarUrl,
    this.lat,
    this.lng,
    this.location,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'client',
      isVerified: json['is_verified'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      avatarUrl: json['avatar_url'],
      lat: json['lat'],
      lng: json['lng'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role,
      'is_verified': isVerified,
      'is_active': isActive,
      'avatar_url': avatarUrl,
      'lat': lat,
      'lng': lng,
      'location': location,
    };
  }
}
