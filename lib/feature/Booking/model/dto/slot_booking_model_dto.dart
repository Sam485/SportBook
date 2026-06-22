class SlotBookingModelDto {
  final int id;
  final String name;
  final String imageUrl;
  final double price; // Changed to double for consistency

  SlotBookingModelDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
  });

  factory SlotBookingModelDto.fromJson(Map<String, dynamic> json) {
    return SlotBookingModelDto(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image_url': imageUrl, 'price': price};
  }
}
