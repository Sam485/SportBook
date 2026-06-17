import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/dto/get_all_sport_club_dto.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/repository/sport_club_repository.dart';

class SportClubServiceImp implements SportClubService {
  final SportClubRepository _repository;

  // State management
  List<SportClubModel> _clubs = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  @override
  List<SportClubModel> get clubs => _clubs;

  @override
  bool get isLoading => _isLoading;

  @override
  String get error => _error;

  SportClubServiceImp(this._repository);

  // Original method
  @override
  Future<GetAllSportClubDto> getAllSportClub() async {
    try {
      return await _repository.getAllSportClub();
    } catch (e) {
      throw Exception('Retrieve data failed: $e');
    }
  }

  // New provider methods
  @override
  Future<List<SportClubModel>> fetchClubs({
    int page = 1,
    int limit = 10,
    String search = '',
  }) async {
    _isLoading = true;
    _error = '';

    try {
      final dto = await _repository.getAllSportClub(
        page: page,
        limit: limit,
        search: search,
      );
      _clubs = dto.data;
      _isLoading = false;
      return _clubs;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  @override
  Future<List<SportClubModel>> getFilteredClubs(String categoryId) async {
    if (categoryId == 'all') {
      return _clubs;
    }

    // If clubs not loaded, fetch first
    if (_clubs.isEmpty) {
      await fetchClubs();
    }

    // Filter based on categories
    // Adjust based on your category structure
    return _clubs
        .where(
          (club) => club.categories.any((cat) => cat.toString() == categoryId),
        )
        .toList();
  }

  @override
  Future<SportClubModel?> getClubById(int id) async {
    // If clubs not loaded, fetch first
    if (_clubs.isEmpty) {
      await fetchClubs();
    }

    try {
      return _clubs.firstWhere((club) => club.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refreshClubs() async {
    await fetchClubs();
  }

  // Optional: Method to update club favorite status
  Future<void> toggleFavorite(int clubId) async {
    // Find and update the club in the list
    final index = _clubs.indexWhere((club) => club.id == clubId);
    if (index != -1) {
      final club = _clubs[index];
      // Update favorite status
      // You would call your API here to update the server
      // Then update the local state
      _clubs[index] = SportClubModel(
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
        favoriteCount: club.favoriteCount + 1, // Example update
        categories: club.categories,
        createdBy: club.createdBy,
        createdAt: club.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }
}
