import 'package:sportbook/feature/Sport%20Club/model/dto/get_all_sport_club_dto.dart';

abstract class SportClubRepository {
  Future<GetAllSportClubDto> getAllSportClub();
}