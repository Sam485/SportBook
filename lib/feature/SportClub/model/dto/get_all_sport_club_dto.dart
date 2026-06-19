// feature/Sport Club/model/dto/get_all_sport_club_dto.dart
import '../sport_club_model.dart';

class GetAllSportClubDto {
  final List<SportClubModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllSportClubDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllSportClubDto.fromJson(Map<String, dynamic> json) {
    // Assuming your API returns a list directly
    // If it returns paginated data with 'data' key, adjust accordingly
    final List<dynamic>? items = json['data'] ?? json['items'] ?? json;

    return GetAllSportClubDto(
      data: items != null
          ? items.map((item) => SportClubModel.fromJson(item)).toList()
          : [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }
}
