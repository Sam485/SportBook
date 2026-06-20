import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
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
  String _error = '';
  String _categoriesError = '';
  bool _isDisposed = false;

  final TextEditingController _searchController = TextEditingController();

  final _categoryService = getIt<CategoryService>();
  late final SportClubService _clubService;

  List<CategoryModel> _categories = [];

  // Get clubs from service
  List<SportClubModel> get _clubs => _clubService.clubs;

  // Get filtered clubs based on selected category or search query
  List<SportClubModel> get _filteredClubs {
    List<SportClubModel> result = _clubs;

    // Filter by search query if present
    if (_query.isNotEmpty) {
      result = result
          .where(
            (club) =>
                club.name.toLowerCase().contains(_query.toLowerCase()) ||
                club.location.toLowerCase().contains(_query.toLowerCase()) ||
                club.categories.any(
                  (cat) => cat.toString().toLowerCase().contains(
                    _query.toLowerCase(),
                  ),
                ),
          )
          .toList();
    }

    // Filter by category if not 'all'
    if (_selectedCat != 'all') {
      result = result
          .where(
            (club) =>
                club.categories.any((cat) => cat.toString() == _selectedCat),
          )
          .toList();
    }

    return result;
  }

  @override
  void initState() {
    super.initState();
    _clubService = getIt<SportClubService>();
    _loadData();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isCategoriesLoading = true;
      _error = '';
      _categoriesError = '';
    });

    try {
      // Load categories first
      await _categoryService.fetchCategories(limit: 100);
      _categories = _categoryService.categories;

      // Load clubs
      await _clubService.fetchClubs();

      setState(() {
        _isLoading = false;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isCategoriesLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
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
                  title: 'nearby'.tr(context),
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
                'loading'.tr(context),
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              ),
              const SizedBox(height: 16),
              Text(
                'error'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
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
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('retry'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    final clubs = _filteredClubs;

    if (clubs.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              ),
              const SizedBox(height: 16),
              Text(
                _query.isEmpty
                    ? 'no_nearby_clubs'.tr(context)
                    : 'no_results_for'
                          .tr(context)
                          .replaceAll('{query}', _query),
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              if (_query.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.kTextSub.withOpacity(0.7)
                        : AppTheme.kLightTextSub.withOpacity(0.7),
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
      delegate: SliverChildBuilderDelegate(
        (_, i) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClubCard(key: ValueKey('club_${clubs[i].id}'), club: clubs[i]),
        ),
        childCount: clubs.length,
      ),
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
          color: isDark ? Colors.white : AppTheme.kLightText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'search_hint'.tr(context),
          hintStyle: TextStyle(
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
        onChanged: (query) {
          setState(() {
            _query = query;
          });
        },
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

    // Add "All" category at the beginning
    final displayCategories = [
      CategoryModel(
        id: 0,
        name: 'all'.tr(context),
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
            final sel = _selectedCat == (isAll ? 'all' : cat.id.toString());

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCat = isAll ? 'all' : cat.id.toString();
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
                            color: AppTheme.kAccent.withOpacity(0.3),
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
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isAll ? 'all'.tr(context) : cat.name,
                      style: TextStyle(
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
