import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';
import 'package:sportbook/feature/Category/repository/category_repository.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';

class CategoryRepositoryImp implements CategoryRepository{
  CategoryService categoryService;
  CategoryRepositoryImp(this.categoryService);

  @override
  Future<GetAllCategoryDto> getAllCategory() async{
    try{
      return await categoryService.getAllCategory();
    }catch(e){
      throw Exception('Retrieve fail: $e');
    }
  }
}