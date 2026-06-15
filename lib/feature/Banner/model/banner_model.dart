class BannerModel {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkUrl;
  final int sortOrder;
  final String status;
  final DateTime craetedAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkUrl,
    required this.sortOrder,
    required this.status,
    required this.craetedAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      linkUrl: json['link_url'] ?? '',
      sortOrder: json['sort_order'] ?? '',
      status: json['status'] ?? '',
      craetedAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
