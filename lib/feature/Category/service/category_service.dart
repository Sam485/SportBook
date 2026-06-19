// feature/Category/service/category_service.dart
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';

abstract class CategoryService {
  // Fetch all categories
  Future<List<CategoryModel>> fetchCategories({
    int page = 1,
    int limit = 10,
    String search = '',
  });

  // Get all categories (original method)
  Future<GetAllCategoryDto> getAllCategory({
    int page = 1,
    int limit = 10,
    String search = '',
  });

  // Refresh categories
  Future<void> refreshCategories();

  // Get category by ID
  Future<CategoryModel?> getCategoryById(int id);

  // Get category by name
  CategoryModel? getCategoryByName(String name);

  // Search categories
  Future<List<CategoryModel>> searchCategories(String query);

  // State getters
  List<CategoryModel> get categories;
  bool get isLoading;
  String get error;
  int get totalCategories;

  // Helper getters
  List<String> get categoryNames;

  void removeListener(void Function() onCategoryServiceChanged) {}

  void addListener(void Function() onCategoryServiceChanged) {}
}
