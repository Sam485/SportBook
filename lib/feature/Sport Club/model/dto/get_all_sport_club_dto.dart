import 'package:sportbook/feature/Sport%20Club/model/sport_club_model.dart';

class GetAllSportClubDto {
  final SportClubModel data;
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
    return GetAllSportClubDto(
      data: json['data'].map((e) => SportClubModel.fromJson(e)),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
