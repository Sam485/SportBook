class UserBookingDto {
  final int id;
  final String fullName;
  final String phone;
  final String email;

  UserBookingDto({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
  });

  factory UserBookingDto.fromJson(Map<String, dynamic> json) {
    return UserBookingDto(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'phone': phone, 'email': email};
  }
}
