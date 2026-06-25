import 'package:flutter/material.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/dto/favorite_response_dto.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/repository/sport_club_repository.dart';

class SportClubServiceImp extends ChangeNotifier implements SportClubService {
  final SportClubRepository _repository;

  // ============================================================================
  // State management for ALL clubs (from getAllSportClub)
  // ============================================================================
  List<SportClubModel> _allClubs = [];
  bool _isLoadingAll = false;
  String _errorAll = '';

  // ============================================================================
  // State management for NEARBY clubs (from getAllSportClubNearBy)
  // ============================================================================
  List<SportClubModel> _nearbyClubs = [];
  bool _isLoadingNearby = false;
  String _errorNearby = '';

  // ============================================================================
  // State management for favorites (shared)
  // ============================================================================
  List<SportClubModel> _favoriteClubs = [];
  bool _isLoadingFavorites = false;
  String _favoritesError = '';

  // Track favorited club IDs for quick lookup (shared)
  Set<int> _favoritedClubIds = {};

  // ============================================================================
  // Getters for ALL clubs
  // ============================================================================
  @override
  List<SportClubModel> get clubs => _allClubs;

  @override
  bool get isLoading => _isLoadingAll;

  @override
  String get error => _errorAll;

  // ============================================================================
  // Getters for NEARBY clubs
  // ============================================================================
  @override
  List<SportClubModel> get nearbyClubs => _nearbyClubs;

  @override
  bool get isLoadingNearby => _isLoadingNearby;

  @override
  String get errorNearby => _errorNearby;

  // ============================================================================
  // Getters for FAVORITES
  // ============================================================================
  @override
  List<SportClubModel> get favoriteClubs => _favoriteClubs;

  @override
  bool get isLoadingFavorites => _isLoadingFavorites;

  @override
  String get favoritesError => _favoritesError;

  // ============================================================================
  // Constructor
  // ============================================================================
  SportClubServiceImp(this._repository);

  // ============================================================================
  // ALL Clubs Methods
  // ============================================================================

  @override
  Future<GetAllSportClubDto> getAllSportClub({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    try {
      return await _repository.getAllSportClub(
        page: page,
        limit: limit,
        search: search,
      );
    } catch (e) {
      throw Exception('Retrieve data failed: $e');
    }
  }

  @override
  Future<List<SportClubModel>> fetchAllClubs({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    _isLoadingAll = true;
    _errorAll = '';
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

      _isLoadingAll = false;
      notifyListeners();
      return _allClubs;
    } catch (e) {
      _errorAll = e.toString();
      _isLoadingAll = false;
      notifyListeners();
      rethrow;
    }
  }

  // ============================================================================
  // NEARBY Clubs Methods - distance filtering on backend
  // ============================================================================

  @override
  Future<List<SportClubModel>> fetchNearbyClubs({
    required double lat,
    required double lng,
    int radius = 10,
  }) async {
    _isLoadingNearby = true;
    _errorNearby = '';
    notifyListeners();

    try {
      final dto = await _repository.getAllSportClubNearBy(lat, lng, radius);
      _nearbyClubs = dto.data;

      // Fetch favorites to know which clubs are favorited
      await _loadFavorites();

      _isLoadingNearby = false;
      notifyListeners();
      return _nearbyClubs;
    } catch (e) {
      _errorNearby = e.toString();
      _isLoadingNearby = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<List<SportClubModel>> getFilteredNearbyClubs(String categoryId) async {
    if (categoryId == 'all') {
      return _nearbyClubs;
    }

    if (_nearbyClubs.isEmpty) {
      return [];
    }

    return _nearbyClubs
        .where(
          (club) => club.categories.any(
            (cat) => cat.id.toString() == categoryId || cat.name == categoryId,
          ),
        )
        .toList();
  }

  // ============================================================================
  // Shared Methods - Get Club by ID (checks both lists)
  // ============================================================================

  @override
  Future<SportClubModel?> getClubById(int id) async {
    // First try to find in all clubs
    try {
      return _allClubs.firstWhere((club) => club.id == id);
    } catch (e) {
      // If not found, try nearby clubs
      try {
        return _nearbyClubs.firstWhere((club) => club.id == id);
      } catch (e) {
        // If not found in either, fetch from API
        try {
          return await _repository.getSportClubById(id);
        } catch (e) {
          return null;
        }
      }
    }
  }

  @override
  Future<void> refreshAllClubs() async {
    await fetchAllClubs();
  }

  @override
  Future<void> refreshNearbyClubs({
    required double lat,
    required double lng,
    int radius = 10,
  }) async {
    await fetchNearbyClubs(lat: lat, lng: lng, radius: radius);
  }

  // ============================================================================
  // Favorites Methods (shared)
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
  // Shared Methods - Load Favorites
  // ============================================================================

  Future<void> _loadFavorites() async {
    try {
      final favoritesDto = await _repository.getAllFavorite();
      _favoritedClubIds = favoritesDto.data.map((club) => club.id).toSet();
      _favoriteClubs = favoritesDto.data;
    } catch (e) {
      _favoritedClubIds = {};
      _favoriteClubs = [];
    }
  }

  // ============================================================================
  // Toggle Favorite - updates both lists
  // ============================================================================

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

      // Update the club's favorite count in ALL clubs list
      final allIndex = _allClubs.indexWhere((club) => club.id == clubId);
      if (allIndex != -1) {
        final club = _allClubs[allIndex];
        _allClubs[allIndex] = SportClubModel(
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

      // Update the club's favorite count in NEARBY clubs list
      final nearbyIndex = _nearbyClubs.indexWhere((club) => club.id == clubId);
      if (nearbyIndex != -1) {
        final club = _nearbyClubs[nearbyIndex];
        _nearbyClubs[nearbyIndex] = SportClubModel(
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

        // Remove from favoriteClubs list
        _favoriteClubs.removeWhere((club) => club.id == clubId);
      } else {
        // Add to favorited IDs
        _favoritedClubIds.add(clubId);

        // Try to find club in all clubs first, then nearby
        SportClubModel? club;
        try {
          club = _allClubs.firstWhere((c) => c.id == clubId);
        } catch (e) {
          try {
            club = _nearbyClubs.firstWhere((c) => c.id == clubId);
          } catch (e) {
            throw Exception('Club not found');
          }
        }

        // Only add if not already in favorites
        if (!_favoriteClubs.any((c) => c.id == clubId)) {
          _favoriteClubs.add(club);
        }
      }

      // Notify all listeners that data has changed
      notifyListeners();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // Helper Methods (shared)
  // ============================================================================

  @override
  bool isClubFavorited(int clubId) {
    return _favoritedClubIds.contains(clubId);
  }

  @override
  Set<int> get favoritedClubIds => _favoritedClubIds;

  @override
  int get favoriteCount => _favoriteClubs.length;

  // In SportClubService class
  @override
  Future<SportClubModel> getClubByIdWithSlots(int id) async {
    return await _repository.getSportClubById(id);
  }

  @override
  void setNearbyClubs(List<SportClubModel> clubs) {
    _nearbyClubs = clubs;
    _errorNearby = '';
    notifyListeners();
  }
}
