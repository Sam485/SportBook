// widgets/cards/club_card.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import '../../core/theme.dart';
import '../../routes/app_routes.dart';
import '../../translations/app_translations.dart';

class ClubCard extends StatefulWidget {
  final SportClubModel club;
  const ClubCard({super.key, required this.club});

  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  int _page = 0;
  late final PageController _ctrl;
  bool _isFavoriting = false;
  bool _isFavorited = false;
  bool _isDisposed = false;

  final _clubService = getIt<SportClubService>();

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 10000);
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
    // Schedule the update after the current build phase completes
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
    // Update favorite status if the club ID changed
    if (oldWidget.club.id != widget.club.id) {
      _isFavorited = _clubService.isClubFavorited(widget.club.id);
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_ctrl.hasClients) return;
    _ctrl.position.moveTo(_ctrl.offset - (d.primaryDelta ?? 0), clamp: false);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_ctrl.hasClients) return;
    final v = d.primaryVelocity ?? 0;
    final c = _ctrl.page?.round() ?? 10000;
    if (v < -300)
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else if (v > 300)
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriting) return;

    // Store the current state before toggling
    final wasFavorited = _isFavorited;

    setState(() {
      _isFavoriting = true;
      // Optimistically update UI
      _isFavorited = !_isFavorited;
    });

    try {
      await _clubService.toggleFavorite(widget.club.id);

      if (!_isDisposed && mounted) {
        // Get the actual state from the service after the operation
        final isNowFavorited = _clubService.isClubFavorited(widget.club.id);

        setState(() {
          _isFavorited = isNowFavorited;
          _isFavoriting = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        // Revert to the previous state on error
        setState(() {
          _isFavorited = wasFavorited;
          _isFavoriting = false;
        });

        // Optional: Log error silently
        print('Failed to toggle favorite: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = widget.club;
    final urls = c.imageUrls;

    final hasImages = urls.isNotEmpty;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 14),
      clipBehavior: Clip.hardEdge,
      decoration: AppTheme.cardDecorationAdaptive(context, radius: 22),
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.bookingFlow, arguments: c),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image carousel ──────────────────────────────────────────
            GestureDetector(
              onHorizontalDragUpdate: hasImages ? _onDragUpdate : null,
              onHorizontalDragEnd: hasImages ? _onDragEnd : null,
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
                      // Pages - Only show if images exist
                      if (hasImages)
                        PageView.builder(
                          controller: _ctrl,
                          itemCount: null,
                          physics: const NeverScrollableScrollPhysics(),
                          onPageChanged: (i) =>
                              setState(() => _page = i % urls.length),
                          itemBuilder: (_, i) => Image.network(
                            urls[i % urls.length],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
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
                        // Placeholder when no images
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
                              color: Colors.black.withOpacity(0.5),
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
                              color: Colors.black.withOpacity(0.5),
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
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: i == _page ? 14 : 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: i == _page
                                      ? AppTheme.kAccent
                                      : (isDark
                                            ? Colors.white.withOpacity(0.35)
                                            : Colors.black.withOpacity(0.35)),
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
                          color: c.color.withOpacity(0.2),
                          border: Border.all(color: c.color, width: 1.8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          c.initials,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.clubDetailed,
                            arguments: c,
                          ),
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
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
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
                            color: AppTheme.kAccent.withOpacity(0.7),
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
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookingFlow,
                          arguments: c,
                        ),
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
                                color: AppTheme.kAccent.withOpacity(0.35),
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
    );
  }

  Widget _openCloseBadge(bool isDark) {
    final isOpen = widget.club.isCurrentlyOpen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withOpacity(0.7)
              : Colors.redAccent.withOpacity(0.7),
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
