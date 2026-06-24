class SlotDto {
  final int id;
  final String name;
  final String imageUrl;
  final int price;
  final int capacity;
  final bool isAvailalbe;

  SlotDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.capacity,
    required this.isAvailalbe,
  });

  factory SlotDto.fromJson(Map<String, dynamic> json) {
    return SlotDto(
      id: json['id'],
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: json['price'] ?? 0.00,
      capacity: json['capacity'] ?? 0,
      isAvailalbe: json['is_available'] ?? false,
    );
  }
}
