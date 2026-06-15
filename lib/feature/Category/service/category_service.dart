import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';

abstract class CategoryService {
  Future<GetAllCategoryDto> getAllCategory();
}