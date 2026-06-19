// feature/SportClub/repository/sport_club_repository.dart
import 'package:dio/dio.dart';
import 'package:sportbook/feature/SportClub/model/dto/favorite_response_dto.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';

class SportClubRepository {
  final Dio _dio;

  SportClubRepository(this._dio);

  // Get all sport clubs with pagination and search
  Future<GetAllSportClubDto> getAllSportClub({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      final response = await _dio.get(
        '/sport-clubs',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (search.isNotEmpty) 'search': search,
        },
      );
      return GetAllSportClubDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to get sport clubs: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get sport clubs: $e');
    }
  }

  // Get all favorites
  Future<GetAllSportClubDto> getAllFavorite() async {
    try {
      final response = await _dio.get('/users/me/favorites?page=1&limit=10');
      return GetAllSportClubDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
        'Failed to get favorites: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('Failed to get favorites: $e');
    }
  }

  // Toggle favorite with explicit state
  Future<FavoriteResponseDto> toggleFavoriteWithState(
    int clubId,
    bool isCurrentlyFavorited,
  ) async {
    try {

      if (isCurrentlyFavorited) {
        // If currently favorited, DELETE to remove
        final response = await _dio.delete('/users/me/favorites/$clubId');
        return FavoriteResponseDto.fromJson(response.data);
      } else {
        // If not favorited, POST to add
        final response = await _dio.post('/users/me/favorites/$clubId');
        return FavoriteResponseDto.fromJson(response.data);
      }
    } on DioException catch (e) {
      throw Exception('Server error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }
}
