import 'package:dio/dio.dart';
import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';

class CategoryService {
  final Dio dio;
  CategoryService(this.dio);

  Future<GetAllCategoryDto> getAllCategory() async {
    try {
      final response = await dio.get('/categories?page=1&limit=10&search=');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllCategoryDto.fromJson(response.data);
      } else {
        throw Exception('Retrieve Data Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
