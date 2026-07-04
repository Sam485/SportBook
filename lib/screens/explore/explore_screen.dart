import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/repository/sport_club_repository.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/club_card.dart';
import 'package:sportbook/widgets/common/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCat = 'all';
  String _query = "";
  bool _isLoading = true;
  bool _isCategoriesLoading = true;
  String _errorMessage = '';
  bool _hasError = false;
  int _currentPage = 1;
  int _totalClubs = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  // Search debounce
  Timer? _searchDebounce;

  final TextEditingController _searchController = TextEditingController();

  final _categoryService = getIt<CategoryService>();

  List<CategoryModel> _categories = [];
  List<SportClubModel> _allClubs = [];

  // Get filtered clubs based on selected category or search query
  List<SportClubModel> get _filteredClubs {
    List<SportClubModel> result = List.from(_allClubs);

    // Filter by category if not 'all'
    if (_selectedCat != 'all') {
      result = result.where((club) {
        return club.categories.any((cat) {
          return cat.id.toString() == _selectedCat;
        });
      }).toList();
    }

    // Filter by search query if present
    if (_query.isNotEmpty) {
      result = result.where((club) {
        final nameMatch = club.name.toLowerCase().contains(
          _query.toLowerCase(),
        );
        final locationMatch = club.location.toLowerCase().contains(
          _query.toLowerCase(),
        );
        final categoryMatch = club.categories.any(
          (cat) => cat.name.toLowerCase().contains(_query.toLowerCase()),
        );
        return nameMatch || locationMatch || categoryMatch;
      }).toList();
    }

    return result;
  }

  // Get user-friendly error message
  String get _userFriendlyErrorMessage {
    if (_errorMessage.contains('timeout') ||
        _errorMessage.contains('Timeout')) {
      return 'connection_timeout'.tr(context);
    } else if (_errorMessage.contains('network') ||
        _errorMessage.contains('Network')) {
      return 'network_error'.tr(context);
    } else if (_errorMessage.contains('401') ||
        _errorMessage.contains('unauthorized')) {
      return 'unauthorized'.tr(context);
    } else if (_errorMessage.contains('500')) {
      return 'server_error'.tr(context);
    } else if (_errorMessage.contains('404')) {
      return 'not_found'.tr(context);
    } else {
      return 'something_went_wrong'.tr(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isCategoriesLoading = true;
      _hasError = false;
      _errorMessage = '';
      _allClubs = [];
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      // Load categories first
      await _categoryService.fetchCategories(limit: 100);
      _categories = _categoryService.categories;

      // Load all clubs with pagination
      await _loadAllClubs(reset: true);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isCategoriesLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _hasError = true;
          _isLoading = false;
          _isCategoriesLoading = false;
        });
      }
    }
  }

  Future<void> _loadAllClubs({bool reset = false}) async {
    // Don't load if already loading or no more data
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final repository = getIt<SportClubRepository>();
      final dto = await repository.getAllSportClub(
        page: _currentPage,
        limit: 20,
        search: _query,
      );

      if (dto.data.isNotEmpty) {
        if (mounted) {
          setState(() {
            if (reset) {
              _allClubs = dto.data;
            } else {
              final existingIds = _allClubs.map((c) => c.id).toSet();
              final newClubs = dto.data
                  .where((c) => !existingIds.contains(c.id))
                  .toList();
              _allClubs.addAll(newClubs);
            }
            _totalClubs = dto.total;
            _hasMore = _allClubs.length < _totalClubs;
            _currentPage++;
            _hasError = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasMore = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _hasError = true;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  void _loadMore() {
    if (!_isLoadingMore && _hasMore) {
      _loadAllClubs();
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _query = query;
          _allClubs = [];
          _currentPage = 1;
          _hasMore = true;
          _hasError = false;
        });
        _loadAllClubs(reset: true);
      }
    });
  }

  // Navigate to booking flow
  void _navigateToBookingFlow(SportClubModel club) {
    Navigator.pushNamed(context, AppRoutes.bookingFlow, arguments: club);
  }

  // Navigate to club detailed
  void _navigateToClubDetailed(SportClubModel club) {
    Navigator.pushNamed(context, AppRoutes.clubDetailed, arguments: club);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.kAccent,
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _searchBar(context)),
              SliverToBoxAdapter(child: _categoriesWidget(context)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: '${'all_clubs'.tr(context)} ($_totalClubs)',
                  isDark: isDark,
                ),
              ),
              _buildContent(isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ── Content Builder ──────────────────────────────────────────────────────────
  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.kAccent),
              const SizedBox(height: 16),
              Text(
                'loading_clubs'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_hasError && _allClubs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
                ),
                const SizedBox(height: 16),
                Text(
                  _userFriendlyErrorMessage,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kAccent,
                    foregroundColor: const Color(0xFF0A1828),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text('retry'.tr(context)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final clubs = _filteredClubs;

    if (clubs.isEmpty && !_isLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Icon(
                _query.isNotEmpty ? Icons.search_off_rounded : Icons.sports,
                size: 64,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              ),
              const SizedBox(height: 16),
              Text(
                _query.isNotEmpty
                    ? 'no_results_for'.tr(context).replaceAll('{query}', _query)
                    : 'no_clubs_available'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (_query.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'try_adjusting_search'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark
                        ? AppTheme.kTextSub.withValues(alpha: 0.7)
                        : AppTheme.kLightTextSub.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        // Show loading indicator at the bottom if there are more clubs
        if (index == clubs.length) {
          if (_isLoadingMore) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: AppTheme.kAccent,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'loading_more'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (_hasMore) {
            // Trigger load more
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadMore();
            });
            return const SizedBox.shrink();
          } else if (_totalClubs > 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'end_of_list'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClubCard(
            key: ValueKey('club_${clubs[index].id}_${clubs[index].updatedAt}'),
            club: clubs[index],
            onBookPressed: (club) {
              _navigateToBookingFlow(club);
            },
            onDetailPressed: (club) {
              _navigateToClubDetailed(club);
            },
          ),
        );
      }, childCount: clubs.length + 1),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _searchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.white : AppTheme.kLightText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'search_clubs'.tr(context),
          hintStyle: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _query = '';
                      _searchController.clear();
                    });
                    _loadAllClubs(reset: true);
                  },
                )
              : null,
          filled: true,
          fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Widget _categoriesWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isCategoriesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: AppTheme.kAccent,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCategories = [
      CategoryModel(
        id: 0,
        name: 'all'.tr(context),
        imageUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ..._categories,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayCategories.length,
          itemBuilder: (_, i) {
            final cat = displayCategories[i];
            final isAll = cat.id == 0;
            final catId = isAll ? 'all' : cat.id.toString();
            final sel = _selectedCat == catId;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCat = catId;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kCard : AppTheme.kLightCard),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppTheme.kAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll) ...[
                      Text(
                        _getCategoryEmoji(cat.name),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isAll ? 'all'.tr(context) : cat.name,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: sel
                            ? const Color(0xFF0A1828)
                            : (isDark
                                  ? Colors.white60
                                  : AppTheme.kLightTextSub),
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Category Emoji Helper ────────────────────────────────────────────────────
  String _getCategoryEmoji(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'football':
        return '⚽';
      case 'basketball':
        return '🏀';
      case 'tennis':
        return '🎾';
      case 'badminton':
        return '🏸';
      case 'gym':
        return '🏋️';
      case 'volleyball':
        return '🏐';
      case 'swimming':
        return '🏊';
      case 'yoga':
        return '🧘';
      case 'boxing':
        return '🥊';
      case 'running':
        return '🏃';
      default:
        return '🏅';
    }
  }
}
