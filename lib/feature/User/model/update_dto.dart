class UpdateDto {
  final String fullName;
  final double lat;
  final double lng;
  final String location;

  UpdateDto({
    required this.fullName,
    required this.lat,
    required this.lng,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'lat': lat,
      'lng': lng,
      'location': location,
    };
  }
}
