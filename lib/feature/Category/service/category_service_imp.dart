import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';

class CategoryServiceImp implements CategoryService {
  CategoryService categoryService;
  CategoryServiceImp(this.categoryService);

  @override
  Future<GetAllCategoryDto> getAllCategory() async {
    try {
      return await categoryService.getAllCategory();
    } catch (e) {
      throw Exception('Retrieve fail: $e');
    }
  }
}
