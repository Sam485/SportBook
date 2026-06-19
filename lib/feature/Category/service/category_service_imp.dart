// feature/Category/service/category_service_imp.dart
import 'package:flutter/material.dart';
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';
import 'package:sportbook/feature/Category/repository/category_repository.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';

class CategoryServiceImp extends ChangeNotifier implements CategoryService {
  final CategoryRepository _repository;

  // State management
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';
  int _totalCategories = 0;

  // Getters
  @override
  List<CategoryModel> get categories => _categories;

  @override
  bool get isLoading => _isLoading;

  @override
  String get error => _error;

  @override
  int get totalCategories => _totalCategories;

  @override
  List<String> get categoryNames => _categories.map((c) => c.name).toList();

  CategoryServiceImp(this._repository);

  @override
  Future<List<CategoryModel>> fetchCategories({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final dto = await getAllCategory(
        page: page,
        limit: limit,
        search: search,
      );

      _categories = dto.data;
      _totalCategories = dto.total;
      _isLoading = false;
      notifyListeners();

      return _categories;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<GetAllCategoryDto> getAllCategory({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      return await _repository.getAllCategory(
        page: page,
        limit: limit,
        search: search,
      );
    } catch (e) {
      throw Exception('Retrieve fail: $e');
    }
  }

  @override
  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  @override
  Future<CategoryModel?> getCategoryById(int id) async {
    if (_categories.isEmpty) {
      await fetchCategories();
    }

    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  CategoryModel? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.nameLowerCase == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CategoryModel>> searchCategories(String query) async {
    if (query.isEmpty) {
      return _categories;
    }

    // If categories are empty, fetch them first
    if (_categories.isEmpty) {
      await fetchCategories();
    }

    return _categories
        .where(
          (category) => category.nameLowerCase.contains(query.toLowerCase()),
        )
        .toList();
  }

  // Helper method to get category ID by name
  int? getCategoryIdByName(String name) {
    final category = getCategoryByName(name);
    return category?.id;
  }

  // Helper method to check if category exists
  bool categoryExists(String name) {
    return getCategoryByName(name) != null;
  }
}
