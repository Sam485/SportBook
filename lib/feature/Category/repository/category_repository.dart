// feature/Category/repository/category_repository.dart
import 'package:dio/dio.dart';
import 'package:sportbook/feature/Category/model/dto/get_all_category_dto.dart';

class CategoryRepository {
  final Dio dio;

  CategoryRepository(this.dio);

  Future<GetAllCategoryDto> getAllCategory({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await dio.get(
        '/categories',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return GetAllCategoryDto.fromJson(response.data);
      } else {
        throw Exception('Retrieve Data Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // Server responded with error
        final errorMessage = e.response?.data['message'] ?? e.message;
        throw Exception('Server error: $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
