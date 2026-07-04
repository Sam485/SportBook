import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/static/services/data_service.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/club_card.dart';

class FavoriteClub extends StatefulWidget {
  const FavoriteClub({super.key});

  @override
  State<FavoriteClub> createState() => _FavoriteClubState();
}

class _FavoriteClubState extends State<FavoriteClub> {
  String _selectedCat = 'all';
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _error = '';
  bool _isInitialLoad = true;
  bool _isDisposed = false;

  final _clubService = getIt<SportClubService>();

  @override
  void initState() {
    super.initState();
    // Listen to service changes
    _clubService.addListener(_onServiceChanged);
    // Load favorites after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _loadFavorites(showLoading: true);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clubService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    // Schedule the update after the current build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadFavorites({bool showLoading = false}) async {
    // Only show loading indicator if it's the initial load or explicitly requested
    if (showLoading || _isInitialLoad) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = true;
          _error = '';
          _isInitialLoad = false;
        });
      }
    } else {
      if (!_isDisposed && mounted) {
        setState(() {
          _isRefreshing = true;
          _error = '';
        });
      }
    }

    try {
      await _clubService.fetchFavorite();
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // Pull to refresh
  Future<void> _onRefresh() async {
    await _loadFavorites(showLoading: false);
  }

  // Use the separate favoriteClubs getter
  List<SportClubModel> get _favorites => _clubService.favoriteClubs;

  List<SportClubModel> get _filtered {
    if (_selectedCat == 'all') return _favorites;
    return _favorites
        .where(
          (c) => c.categories.any(
            (cat) => cat.toString().toLowerCase() == _selectedCat,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'favorites'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppTheme.kAccent,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(
                    Icons.refresh_rounded,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                  ),
            onPressed: _isRefreshing ? null : _onRefresh,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.kAccent,
          backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
          child: _buildBody(isDark, filtered),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, List<SportClubModel> filtered) {
    // Loading state - use isLoadingFavorites from service
    if (_isLoading || _clubService.isLoadingFavorites) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.kAccent),
            const SizedBox(height: 16),
            Text(
              'loading'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Error state - use favoritesError from service
    if (_error.isNotEmpty || _clubService.favoritesError.isNotEmpty) {
      final displayError = _error.isNotEmpty
          ? _error
          : _clubService.favoritesError;
      return Center(
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
              'Failed to load favorites',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              displayError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadFavorites(showLoading: true),
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
      );
    }

    // Empty state
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 64,
              color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
            ),
            const SizedBox(height: 16),
            Text(
              'favorites_empty'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'favorites_hint'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
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
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: Text('explore_clubs'.tr(context)),
            ),
          ],
        ),
      );
    }

    // Main content with clubs
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _categories(isDark)),
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                'no_clubs_for_this_sport'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClubCard(club: filtered[i]),
              ),
              childCount: filtered.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _categories(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DataService.categories.length,
        itemBuilder: (_, i) {
          final cat = DataService.categories[i];
          final sel = _selectedCat == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Text(
                    cat.emoji,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: sel
                          ? const Color(0xFF0A1828)
                          : (isDark ? Colors.white60 : AppTheme.kLightTextSub),
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
