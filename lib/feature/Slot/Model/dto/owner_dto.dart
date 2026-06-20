class OwnerDto {
  final int id;
  final String fullName;
  final String role;

  OwnerDto({required this.id, required this.fullName, required this.role});

  factory OwnerDto.fromJson(Map<String, dynamic> json) {
    return OwnerDto(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'full_name': fullName, 'role': role};
  }
}
