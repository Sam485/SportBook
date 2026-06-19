// feature/SportClub/Service/sport_club_service_imp.dart
import 'package:flutter/material.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/dto/favorite_response_dto.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/repository/sport_club_repository.dart';

class SportClubServiceImp extends ChangeNotifier implements SportClubService {
  final SportClubRepository _repository;

  // State management for all clubs
  List<SportClubModel> _allClubs = [];
  bool _isLoading = false;
  String _error = '';

  // State management for favorites (separate)
  List<SportClubModel> _favoriteClubs = [];
  bool _isLoadingFavorites = false;
  String _favoritesError = '';

  // Track favorited club IDs for quick lookup
  Set<int> _favoritedClubIds = {};

  // Getters for all clubs
  @override
  List<SportClubModel> get clubs => _allClubs;

  @override
  bool get isLoading => _isLoading;

  @override
  String get error => _error;

  // Getters for favorites
  @override
  List<SportClubModel> get favoriteClubs => _favoriteClubs;

  @override
  bool get isLoadingFavorites => _isLoadingFavorites;

  @override
  String get favoritesError => _favoritesError;

  SportClubServiceImp(this._repository);

  // ============================================================================
  // All Clubs Methods
  // ============================================================================

  @override
  Future<GetAllSportClubDto> getAllSportClub() async {
    try {
      return await _repository.getAllSportClub();
    } catch (e) {
      throw Exception('Retrieve data failed: $e');
    }
  }

  @override
  Future<List<SportClubModel>> fetchClubs({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final dto = await _repository.getAllSportClub(
        page: page,
        limit: limit,
        search: search,
      );
      _allClubs = dto.data;

      // Fetch favorites to know which clubs are favorited
      await _loadFavorites();

      _isLoading = false;
      notifyListeners();
      return _allClubs;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<List<SportClubModel>> getFilteredClubs(String categoryId) async {
    if (categoryId == 'all') {
      return _allClubs;
    }

    if (_allClubs.isEmpty) {
      await fetchClubs();
    }

    return _allClubs
        .where(
          (club) => club.categories.any((cat) => cat.toString() == categoryId),
        )
        .toList();
  }

  @override
  Future<SportClubModel?> getClubById(int id) async {
    if (_allClubs.isEmpty) {
      await fetchClubs();
    }

    try {
      return _allClubs.firstWhere((club) => club.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshClubs() async {
    await fetchClubs();
  }

  // ============================================================================
  // Favorites Methods
  // ============================================================================

  @override
  Future<List<SportClubModel>> fetchFavorite() async {
    _isLoadingFavorites = true;
    _favoritesError = '';
    notifyListeners();

    try {
      final dto = await _repository.getAllFavorite();
      _favoriteClubs = dto.data;

      // Update favorited IDs based on the response
      _favoritedClubIds = _favoriteClubs.map((club) => club.id).toSet();

      _isLoadingFavorites = false;
      notifyListeners();
      return _favoriteClubs;
    } catch (e) {
      _favoritesError = e.toString();
      _isLoadingFavorites = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<GetAllSportClubDto> getAllFavorite() {
    return _repository.getAllFavorite();
  }

  // ============================================================================
  // Shared Methods
  // ============================================================================

  // Helper method to load favorites and update the set
  Future<void> _loadFavorites() async {
    try {
      final favoritesDto = await _repository.getAllFavorite();
      _favoritedClubIds = favoritesDto.data.map((club) => club.id).toSet();
      _favoriteClubs = favoritesDto.data;
    } catch (e) {
      print('Failed to load favorites: $e');
      _favoritedClubIds = {};
      _favoriteClubs = [];
    }
  }

  @override
  Future<FavoriteResponseDto?> toggleFavorite(int clubId) async {
    try {
      // Check if the club is currently favorited
      final isCurrentlyFavorited = _favoritedClubIds.contains(clubId);

      // Use the explicit state toggle method
      final response = await _repository.toggleFavoriteWithState(
        clubId,
        isCurrentlyFavorited,
      );

      // Update the club's favorite count in all clubs list
      final index = _allClubs.indexWhere((club) => club.id == clubId);
      if (index != -1) {
        final club = _allClubs[index];
        _allClubs[index] = SportClubModel(
          id: club.id,
          name: club.name,
          lat: club.lat,
          lng: club.lng,
          location: club.location,
          isOpen: club.isOpen,
          openTime: club.openTime,
          closeTime: club.closeTime,
          description: club.description,
          imageUrls: club.imageUrls,
          favoriteCount: response.favoriteCount,
          categories: club.categories,
          createdBy: club.createdBy,
          createdAt: club.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      // Update our local favorite tracking set
      if (_favoritedClubIds.contains(clubId)) {
        // Remove from favorited IDs
        _favoritedClubIds.remove(clubId);

        // IMPORTANT: Remove from favoriteClubs list
        _favoriteClubs.removeWhere((club) => club.id == clubId);

        print('Club $clubId removed from favorites');
      } else {
        // Add to favorited IDs
        _favoritedClubIds.add(clubId);

        // IMPORTANT: Add to favoriteClubs list if not already present
        final club = _allClubs.firstWhere(
          (c) => c.id == clubId,
          orElse: () => throw Exception('Club not found'),
        );

        // Only add if not already in favorites
        if (!_favoriteClubs.any((c) => c.id == clubId)) {
          _favoriteClubs.add(club);
          print('Club $clubId added to favorites');
        }
      }

      // Notify all listeners that data has changed
      notifyListeners();

      return response;
    } catch (e) {
      print('Toggle favorite error: $e');
      rethrow;
    }
  }

  // Helper method to check if a club is favorited
  @override
  bool isClubFavorited(int clubId) {
    return _favoritedClubIds.contains(clubId);
  }

  // Get favorited club IDs
  @override
  Set<int> get favoritedClubIds => _favoritedClubIds;

  // Get count of favorites
  @override
  int get favoriteCount => _favoriteClubs.length;
}
