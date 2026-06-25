import 'package:flutter/material.dart';
import 'package:sportbook/feature/SportClub/model/dto/favorite_response_dto.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import '../model/sport_club_model.dart';

abstract class SportClubService extends ChangeNotifier {
  // ============================================================================
  // ALL Clubs Methods
  // ============================================================================

  Future<GetAllSportClubDto> getAllSportClub({
    int page = 1,
    int limit = 10,
    String search = '',
  });

  Future<List<SportClubModel>> fetchAllClubs({
    int page = 1,
    int limit = 10,
    String search = '',
  });

  Future<void> refreshAllClubs();

  // Getters for ALL clubs
  List<SportClubModel> get clubs;
  bool get isLoading;
  String get error;

  // ============================================================================
  // NEARBY Clubs Methods
  // ============================================================================

  Future<List<SportClubModel>> fetchNearbyClubs({
    required double lat,
    required double lng,
    int radius = 10,
  });

  Future<List<SportClubModel>> getFilteredNearbyClubs(String categoryId);

  Future<void> refreshNearbyClubs({
    required double lat,
    required double lng,
    int radius = 10,
  });

  // Getters for NEARBY clubs
  List<SportClubModel> get nearbyClubs;
  bool get isLoadingNearby;
  String get errorNearby;

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

  // ============================================================================
  // Shared Methods
  // ============================================================================

  Future<SportClubModel?> getClubById(int id);
  bool isClubFavorited(int clubId);
  Set<int> get favoritedClubIds;
  Future<SportClubModel> getClubByIdWithSlots(int id);
  void setNearbyClubs(List<SportClubModel> clubs);

}
