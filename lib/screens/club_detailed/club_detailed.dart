import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/screens/booking_flow/booking_flow_screen.dart';
import 'package:sportbook/translations/app_translations.dart';

class ClubDetailed extends StatefulWidget {
  final SportClubModel target;
  const ClubDetailed({super.key, required this.target});

  @override
  State<ClubDetailed> createState() => _ClubDetailedState();
}

class _ClubDetailedState extends State<ClubDetailed> {
  int _page = 0;
  bool _isFavoriting = false;
  bool _isFavorited = false;
  bool _isDisposed = false;

  late final SportClubService _clubService;
  late final TokenService _tokenService;

  bool get _isOpen {
    final now = TimeOfDay.now();
    final nowM = now.hour * 60 + now.minute;

    int parse(String t) {
      try {
        final parts = t.trim().split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        return hour * 60 + minute;
      } catch (_) {
        return 0;
      }
    }

    final openMinutes = parse(widget.target.openTime);
    final closeMinutes = parse(widget.target.closeTime);

    if (closeMinutes < openMinutes) {
      return nowM >= openMinutes || nowM < closeMinutes;
    } else {
      return nowM >= openMinutes && nowM < closeMinutes;
    }
  }

  @override
  void initState() {
    super.initState();
    _clubService = getIt<SportClubService>();
    _tokenService = getIt<TokenService>();

    _isFavorited = _clubService.isClubFavorited(widget.target.id);
    _clubService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clubService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        final isNowFavorited = _clubService.isClubFavorited(widget.target.id);
        if (_isFavorited != isNowFavorited) {
          setState(() {
            _isFavorited = isNowFavorited;
          });
        }
      }
    });
  }

  Future<bool> _isAuthenticated() async {
    try {
      return await _tokenService.hasValidTokenAsync();
    } catch (e) {
      return false;
    }
  }

  void _showLoginRequiredDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'login_required'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'login_to_favorite'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text('login'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriting) return;

    final isAuth = await _isAuthenticated();

    if (!isAuth) {
      _showLoginRequiredDialog();
      return;
    }

    final wasFavorited = _isFavorited;

    setState(() {
      _isFavoriting = true;
      _isFavorited = !_isFavorited;
    });

    try {
      await _clubService.toggleFavorite(widget.target.id);

      if (!_isDisposed && mounted) {
        final isNowFavorited = _clubService.isClubFavorited(widget.target.id);

        setState(() {
          _isFavorited = isNowFavorited;
          _isFavoriting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowFavorited
                  ? 'added_to_favorites'.tr(context)
                  : 'removed_from_favorites'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: isNowFavorited ? Colors.green : Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isFavorited = wasFavorited;
          _isFavoriting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'failed_to_update_favorite'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBookingSheet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingFlowScreen(target: widget.target),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header(isDark)),
                SliverToBoxAdapter(child: _infoSection(isDark)),
                SliverToBoxAdapter(
                  child: _divider('sports_available'.tr(context), isDark),
                ),
                SliverToBoxAdapter(child: _sportsGrid(isDark)),
                SliverToBoxAdapter(
                  child: _divider('location'.tr(context), isDark),
                ),
                SliverToBoxAdapter(child: _location(isDark)),
                SliverToBoxAdapter(
                  child: _divider('about'.tr(context), isDark),
                ),
                SliverToBoxAdapter(child: _about(isDark)),
                SliverToBoxAdapter(
                  child: _divider('you_might_also_like'.tr(context), isDark),
                ),
                SliverToBoxAdapter(child: _suggestions(isDark)),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
            _bottomNav(isDark),
          ],
        ),
      ),
    );
  }

  Widget _header(bool isDark) => SizedBox(
    height: 260,
    width: double.infinity,
    child: Stack(
      children: [
        if (widget.target.imageUrls.length > 1)
          CarouselSlider(
            options: CarouselOptions(
              height: 260,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 1.0,
              onPageChanged: (i, _) => setState(() => _page = i),
            ),
            items: widget.target.imageUrls
                .map((url) => _netImage(url, isDark))
                .toList(),
          )
        else
          _netImage(
            widget.target.imageUrls.isNotEmpty
                ? widget.target.imageUrls.first
                : '',
            isDark,
          ),

        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  (isDark ? AppTheme.kBg : AppTheme.kLightBg).withValues(
                    alpha: 0.85,
                  ),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),

        if (widget.target.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.target.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppTheme.kAccent
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.35)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          left: 12,
          top: 10,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        Positioned(
          right: 12,
          top: 10,
          child: GestureDetector(
            onTap: _toggleFavorite,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isFavorited
                      ? AppTheme.kAccent.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: _isFavoriting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: AppTheme.kAccent,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      _isFavorited
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorited ? AppTheme.kAccent : Colors.white,
                      size: 18,
                    ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _netImage(String url, bool isDark) => url.isNotEmpty
      ? Image.network(
          url,
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
            child: Icon(
              Icons.image_not_supported,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              size: 36,
            ),
          ),
          loadingBuilder: (_, child, p) => p == null
              ? child
              : Container(
                  color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.kAccent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
        )
      : Container(
          height: 260,
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          child: Icon(
            Icons.image_not_supported,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            size: 36,
          ),
        );

  Widget _infoSection(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.target.name,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _openCloseBadge(),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(
              Icons.lock_open_rounded,
              color: AppTheme.kAccent,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(
              widget.target.openTime,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.kAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '–',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: (isDark ? Colors.white : AppTheme.kLightText)
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
            const Icon(Icons.lock_rounded, color: AppTheme.kTextSub, size: 13),
            const SizedBox(width: 4),
            Text(
              widget.target.closeTime,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.kTextSub,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _statPill(
              Icons.grid_view_rounded,
              '${widget.target.categories.length} ${'courts'.tr(context)}',
              AppTheme.kAccent,
            ),
            const SizedBox(width: 8),
            _statPill(Icons.star_rounded, '4.8', const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            _statPill(
              Icons.attach_money_rounded,
              '\$${(widget.target.favoriteCount + 10).toString()}/hr',
              const Color(0xFF4CAF50),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _statPill(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _divider(String title, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            thickness: 1,
          ),
        ),
      ],
    ),
  );

  // ─── Sports Grid ──────────────────────────────────────────────────────────
  Widget _sportsGrid(bool isDark) {
    final categories = widget.target.categories;

    if (categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            ),
          ),
          child: Center(
            child: Text(
              'No sports available',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categories.map((cat) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.kAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getCategoryEmoji(cat.name),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  cat.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Category Emoji Helper ──────────────────────────────────────────────
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
      case 'table tennis':
        return '🏓';
      case 'squash':
        return '🏸';
      case 'dance':
        return '💃';
      case 'cycling':
        return '🚴';
      default:
        return '🏅';
    }
  }

  Widget _location(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_rounded,
                color: AppTheme.kAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.target.location,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130,
              color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFE0E0E0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: _MapGridPainter(isDark: isDark),
                    size: const Size(double.infinity, 130),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.kAccent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'view_on_map'.tr(context),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _about(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      child: Text(
        widget.target.description.isNotEmpty
            ? widget.target.description
            : '${widget.target.name} ${'about_description'.tr(context)}',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
          fontSize: 13,
          height: 1.65,
        ),
      ),
    ),
  );

  Widget _suggestions(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          ),
        ),
        child: Center(
          child: Text(
            'more_clubs_coming_soon'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNav(bool isDark) => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.kBg : AppTheme.kLightBg).withValues(
          alpha: 0.95,
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _navIconBtn(
            icon: _isFavorited
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _isFavorited ? 'saved'.tr(context) : 'save'.tr(context),
            color: _isFavorited ? AppTheme.kAccent : null,
            onTap: _toggleFavorite,
            isDark: isDark,
          ),
          const SizedBox(width: 10),

          _navIconBtn(
            icon: Icons.share_rounded,
            label: 'share'.tr(context),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'share_feature_coming_soon'.tr(context),
                    style: const TextStyle(fontFamily: AppTheme.fontFamily),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(width: 14),

          Expanded(
            child: ElevatedButton(
              onPressed: () => _showBookingSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: Text(
                'book_now'.tr(context),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _navIconBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    required bool isDark,
  }) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color ?? (isDark ? Colors.white70 : AppTheme.kLightTextSub),
          size: 22,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: color ?? (isDark ? Colors.white54 : AppTheme.kLightTextSub),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _openCloseBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: _isOpen
            ? Colors.greenAccent.withValues(alpha: 0.7)
            : Colors.redAccent.withValues(alpha: 0.7),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isOpen ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _isOpen ? 'open_now'.tr(context) : 'closed'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: _isOpen ? Colors.greenAccent : Colors.redAccent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _MapGridPainter extends CustomPainter {
  final bool isDark;

  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? const Color(0xFF2A2A3A) : const Color(0xFFCCCCCC)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final road = Paint()
      ..color = isDark ? const Color(0xFF3A3A4A) : const Color(0xFFBBBBBB)
      ..strokeWidth = 5;
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
