// feature/Sport Club/Service/sport_club_service.dart
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import '../model/sport_club_model.dart';

abstract class SportClubService {
  // Original method
  Future<GetAllSportClubDto> getAllSportClub();

  // New provider-like methods
  Future<List<SportClubModel>> fetchClubs({int page, int limit, String search});
  Future<List<SportClubModel>> getFilteredClubs(String categoryId);
  Future<SportClubModel?> getClubById(int id);
  Future<void> refreshClubs();

  // State getters
  List<SportClubModel> get clubs;
  bool get isLoading;
  String get error;
}
