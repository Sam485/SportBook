import 'package:sportbook/feature/SportClub/model/dto/favorite_response_dto.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import '../model/sport_club_model.dart';

abstract class SportClubService {
  // ============================================================================
  // All Clubs Methods
  // ============================================================================

  Future<GetAllSportClubDto> getAllSportClub();
  Future<List<SportClubModel>> fetchClubs({
    int page = 1,
    int limit = 10,
    String search = '',
  });
  Future<List<SportClubModel>> getFilteredClubs(String categoryId);
  Future<SportClubModel?> getClubById(int id);
  Future<void> refreshClubs();

  // Getters for all clubs
  List<SportClubModel> get clubs;
  bool get isLoading;
  String get error;

  // ============================================================================
  // Favorites Methods
  // ============================================================================

  Future<List<SportClubModel>> fetchFavorite();
  Future<GetAllSportClubDto> getAllFavorite();
  Future<FavoriteResponseDto?> toggleFavorite(int clubId);

  // Getters for favorites
  List<SportClubModel> get favoriteClubs;
  bool get isLoadingFavorites;
  String get favoritesError;
  int get favoriteCount;

  // Helper methods
  bool isClubFavorited(int clubId);
  Set<int> get favoritedClubIds;

  void addListener(void Function() onServiceChanged) {}

  void removeListener(void Function() onServiceChanged) {}
}
