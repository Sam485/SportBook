// feature/Category/model/dto/get_all_category_dto.dart
import '../category_model.dart';

class GetAllCategoryDto {
  final List<CategoryModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllCategoryDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllCategoryDto.fromJson(Map<String, dynamic> json) {
    // If the API returns a list directly
    final List<dynamic>? items = json['data'] ?? json['items'] ?? json;

    return GetAllCategoryDto(
      data: items != null
          ? items.map((item) => CategoryModel.fromJson(item)).toList()
          : [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }
}
