import 'package:dio/dio.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';

class BannerService {
  final Dio dio;
  BannerService(this.dio);

  Future<List<BannerModel>> getAllActiveBanner() async {
    try {
      final response = await dio.get('/banners/active');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to retrieve data: ${response.statusCode}');
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
