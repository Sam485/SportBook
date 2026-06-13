import 'package:sportbook/feature/Category/model/category_model.dart';

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
    return GetAllCategoryDto(
      data: json['data'].map((item) => CategoryModel.fromJson(json)),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
