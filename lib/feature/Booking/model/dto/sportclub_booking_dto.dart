class SportclubBookingDto {
  final int id;
  final String name;
  final String location;

  SportclubBookingDto({
    required this.id,
    required this.name,
    required this.location,
  });

  factory SportclubBookingDto.fromJson(Map<String, dynamic> json) {
    return SportclubBookingDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'location': location};
  }
}
