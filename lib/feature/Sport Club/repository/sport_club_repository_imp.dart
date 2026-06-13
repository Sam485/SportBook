import 'package:sportbook/feature/Sport%20Club/Service/sport_club_service.dart';
import 'package:sportbook/feature/Sport%20Club/model/dto/get_all_sport_club_dto.dart';
import 'package:sportbook/feature/Sport%20Club/repository/sport_club_repository.dart';

class SportClubRepositoryImp implements SportClubRepository {
  SportClubService sportClubService;
  SportClubRepositoryImp(this.sportClubService);
  @override
  Future<GetAllSportClubDto> getAllSportClub() async {
    try {
      return await sportClubService.getAllSportClub();
    } catch (e) {
      throw Exception('Retrieve data failed: $e');
    }
  }
}
