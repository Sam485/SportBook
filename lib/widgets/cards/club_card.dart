import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import '../../core/theme.dart';
import '../../translations/app_translations.dart';

class ClubCard extends StatefulWidget {
  final SportClubModel club;
  final Function(SportClubModel)? onBookPressed;
  final Function(SportClubModel)? onDetailPressed;

  const ClubCard({
    super.key,
    required this.club,
    this.onBookPressed,
    this.onDetailPressed,
  });

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard>
    with AutomaticKeepAliveClientMixin {
  int _page = 0;
  late final PageController _ctrl;
  bool _isFavoriting = false;
  bool _isFavorited = false;
  bool _isDisposed = false;
  bool _isNavigating = false;

  late final SportClubService _clubService;
  late final TokenService _tokenService;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // ✅ Only use infinite scrolling if there are multiple images
    final urls = widget.club.imageUrls;
    if (urls.length > 1) {
      _ctrl = PageController(initialPage: 10000);
    } else {
      _ctrl = PageController(initialPage: 0);
    }

    _clubService = getIt<SportClubService>();
    _tokenService = getIt<TokenService>();

    // Check if this club is already favorited
    _isFavorited = _clubService.isClubFavorited(widget.club.id);

    // Listen to service changes
    _clubService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clubService.removeListener(_onServiceChanged);
    _ctrl.dispose();
    super.dispose();
  }

  void _onServiceChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        final isNowFavorited = _clubService.isClubFavorited(widget.club.id);
        if (_isFavorited != isNowFavorited) {
          setState(() {
            _isFavorited = isNowFavorited;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(ClubCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.club.id != widget.club.id) {
      _isFavorited = _clubService.isClubFavorited(widget.club.id);
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (widget.club.imageUrls.length <= 1 || !_ctrl.hasClients) return;
    _ctrl.position.moveTo(_ctrl.offset - (d.primaryDelta ?? 0), clamp: false);
  }

  void _onDragEnd(DragEndDetails d) {
    if (widget.club.imageUrls.length <= 1 || !_ctrl.hasClients) return;
    final v = d.primaryVelocity ?? 0;
    final c = _ctrl.page?.round() ?? 10000;
    if (v < -300) {
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (v > 300) {
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  // ✅ Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    try {
      return await _tokenService.hasValidTokenAsync();
    } catch (e) {
      return false;
    }
  }

  // ✅ Show login required dialog
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
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'login_to_favorite'.tr(context),
          style: TextStyle(
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
            ),
            child: Text('login'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriting) return;

    // ✅ Check if user is authenticated
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
      await _clubService.toggleFavorite(widget.club.id);

      if (!_isDisposed && mounted) {
        final isNowFavorited = _clubService.isClubFavorited(widget.club.id);

        setState(() {
          _isFavorited = isNowFavorited;
          _isFavoriting = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isFavorited = wasFavorited;
          _isFavoriting = false;
        });
      }
    }
  }

  // ✅ Use callbacks for navigation
  void _handleBookPressed() {
    if (widget.onBookPressed != null) {
      widget.onBookPressed!(widget.club);
    } else {
      // Fallback: Navigate directly
      _navigateToBookingFlow();
    }
  }

  void _handleDetailPressed() {
    if (widget.onDetailPressed != null) {
      widget.onDetailPressed!(widget.club);
    } else {
      // Fallback: Navigate directly
      _navigateToClubDetailed();
    }
  }

  // ✅ Fallback navigation methods (kept for backward compatibility)
  Future<void> _navigateToBookingFlow() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      final fullClubData = await _clubService.getClubByIdWithSlots(
        widget.club.id,
      );

      if (!_isDisposed && mounted) {
        await Navigator.pushNamed(
          context,
          AppRoutes.bookingFlow,
          arguments: fullClubData,
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        await Navigator.pushNamed(
          context,
          AppRoutes.bookingFlow,
          arguments: widget.club,
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  Future<void> _navigateToClubDetailed() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      final fullClubData = await _clubService.getClubByIdWithSlots(
        widget.club.id,
      );

      if (!_isDisposed && mounted) {
        await Navigator.pushNamed(
          context,
          AppRoutes.clubDetailed,
          arguments: fullClubData,
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        await Navigator.pushNamed(
          context,
          AppRoutes.clubDetailed,
          arguments: widget.club,
        );
      }
    } finally {
      if (!_isDisposed && mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.club;
    final urls = c.imageUrls;
    final hasImages = urls.isNotEmpty;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 14),
        clipBehavior: Clip.hardEdge,
        decoration: AppTheme.cardDecorationAdaptive(context, radius: 22),
        child: Stack(
          children: [
            // ✅ InkWell with custom border for ripple effect
            InkWell(
              onTap: _handleBookPressed,
              borderRadius: BorderRadius.circular(22),
              splashColor: AppTheme.kAccent.withValues(alpha: 0.1),
              highlightColor: AppTheme.kAccent.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image carousel ──────────────────────────────────────────
                  GestureDetector(
                    onHorizontalDragUpdate: hasImages && urls.length > 1
                        ? _onDragUpdate
                        : null,
                    onHorizontalDragEnd: hasImages && urls.length > 1
                        ? _onDragEnd
                        : null,
                    behavior: HitTestBehavior.opaque,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (hasImages)
                              PageView.builder(
                                controller: _ctrl,
                                itemCount: urls.length,
                                physics: const NeverScrollableScrollPhysics(),
                                onPageChanged: (i) => setState(() => _page = i),
                                itemBuilder: (_, i) => Image.network(
                                  urls[i],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: isDark
                                        ? AppTheme.kCardAlt
                                        : AppTheme.kLightCardAlt,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                  loadingBuilder: (_, ch, p) => p == null
                                      ? ch
                                      : Container(
                                          color: isDark
                                              ? AppTheme.kCardAlt
                                              : AppTheme.kLightCardAlt,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              color: AppTheme.kAccent,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                ),
                              )
                            else
                              Container(
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sports,
                                      color: isDark
                                          ? Colors.white38
                                          : AppTheme.kLightTextSub,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'no_images'.tr(context),
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white38
                                            : AppTheme.kLightTextSub,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Scrim
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    isDark
                                        ? const Color(0xCC0A1828)
                                        : const Color(0xCCF0F6FF),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: const [0.4, 1.0],
                                ),
                              ),
                            ),

                            // Open/close badge
                            Positioned(
                              top: 8,
                              left: 10,
                              child: _openCloseBadge(isDark),
                            ),

                            // Favorite button - TOP RIGHT
                            Positioned(
                              top: 8,
                              right: 10,
                              child: GestureDetector(
                                onTap: _toggleFavorite,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isFavorited
                                          ? AppTheme.kAccent
                                          : Colors.white24,
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
                                          color: _isFavorited
                                              ? AppTheme.kAccent
                                              : Colors.white70,
                                          size: 18,
                                        ),
                                ),
                              ),
                            ),

                            // Page count badge - Only show if multiple images
                            if (urls.length > 1)
                              Positioned(
                                bottom: 8,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Text(
                                    '${_page + 1}/${urls.length}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                            // Dot indicators - Only show if multiple images
                            if (urls.length > 1)
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    urls.length,
                                    (i) => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      width: i == _page ? 14 : 5,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: i == _page
                                            ? AppTheme.kAccent
                                            : (isDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.35,
                                                    )
                                                  : Colors.black.withValues(
                                                      alpha: 0.35,
                                                    )),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Details ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + hours
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: c.color.withValues(alpha: 0.2),
                                border: Border.all(color: c.color, width: 1.8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                c.initials,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.kLightText,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: _handleDetailPressed,
                                borderRadius: BorderRadius.circular(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : AppTheme.kLightText,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.lock_open_outlined,
                                          color: AppTheme.kAccent,
                                          size: 11,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          c.openTime,
                                          style: const TextStyle(
                                            color: AppTheme.kAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? AppTheme.kTextSub
                                                : AppTheme.kLightTextSub,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.lock_outline,
                                          color: AppTheme.kTextSub,
                                          size: 11,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          c.closeTime,
                                          style: TextStyle(
                                            color: isDark
                                                ? AppTheme.kTextSub
                                                : AppTheme.kLightTextSub,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Container(
                          height: 1,
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                        ),
                        const SizedBox(height: 6),

                        // Venue - Changed to location
                        Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              color: AppTheme.kAccent,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                c.location,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.kLightTextSub,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Distance + Favorite count + Book button
                        Row(
                          children: [
                            const Icon(
                              Icons.route_outlined,
                              color: AppTheme.kAccent,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${c.distanceKm.toStringAsFixed(1)} ${'km_away'.tr(context)}',
                              style: TextStyle(
                                color: isDark
                                    ? AppTheme.kTextSub
                                    : AppTheme.kLightTextSub,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Favorite count indicator
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: AppTheme.kAccent.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${c.favoriteCount}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.kTextSub
                                        : AppTheme.kLightTextSub,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _handleBookPressed,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.kAccent,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.kAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'book'.tr(context),
                                  style: const TextStyle(
                                    color: Color(0xFF0A1828),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay when navigating
            if (_isNavigating)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.kAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _openCloseBadge(bool isDark) {
    final isOpen = widget.club.isCurrentlyOpen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withValues(alpha: 0.7)
              : Colors.redAccent.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isOpen ? 'open'.tr(context) : 'closed'.tr(context),
            style: TextStyle(
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
