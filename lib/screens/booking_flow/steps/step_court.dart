import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';
import '../../../feature/services/data_service.dart';
import '../../../translations/app_translations.dart';

class StepCourt extends StatelessWidget {
  final VoidCallback onNext;
  const StepCourt({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<BookingProvider>();
    final isGym = p.target?.isGym ?? false;
    final total = (p.target?.totalCourts ?? 4).clamp(1, 12);
    final sport = p.selectedSport ?? p.target?.sports.firstOrNull ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Text(
          isGym ? 'select_trainer'.tr(context) : 'select_court'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isGym
              ? 'choose_trainer_desc'.tr(context)
              : 'select_court_desc'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 20),

        isGym
            ? _trainerGrid(context, p, isDark)
            : _courtGrid(context, p, total, sport, isDark),
      ],
    );
  }

  // ── Court grid (2-col with image) ──────────────────────────────────────────
  Widget _courtGrid(
    BuildContext ctx,
    BookingProvider p,
    int total,
    String sport,
    bool isDark,
  ) {
    final imgs =
        DataService.courtImages[sport] ?? DataService.courtImages['Football']!;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: total,
      itemBuilder: (_, i) {
        final num = i + 1;
        final sel = p.selectedCourt == num;
        final img = imgs[(i) % imgs.length];

        return GestureDetector(
          onTap: () {
            p.selectCourt(num);
            Future.delayed(const Duration(milliseconds: 200), onNext);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel
                    ? AppTheme.kAccent
                    : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                width: sel ? 2.5 : 1,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: AppTheme.kAccent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
                      child: const Icon(
                        Icons.sports,
                        color: AppTheme.kAccent,
                        size: 32,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          sel
                              ? (isDark
                                    ? const Color(0xCC0A1828)
                                    : const Color(0xCCF0F6FF))
                              : (isDark
                                    ? const Color(0x880A1828)
                                    : const Color(0x88F0F6FF)),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                  // Check mark
                  if (sel)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.kAccent,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  // Expand icon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => _openFullImage(
                        ctx,
                        img,
                        'court_label'.tr(ctx).replaceAll('{number}', '$num'),
                      ),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                      ),
                    ),
                  ),
                  // Label
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'court_label'.tr(ctx).replaceAll('{number}', '$num'),
                          style: TextStyle(
                            color: sel ? AppTheme.kAccent : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        if (sport.isNotEmpty)
                          Text(
                            '${DataService.emojiFor(sport)} ${_getTranslatedSportName(sport, ctx)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 3),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Trainer grid ───────────────────────────────────────────────────────────
  Widget _trainerGrid(BuildContext ctx, BookingProvider p, bool isDark) =>
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: DataService.trainers.length,
        itemBuilder: (_, i) {
          final t = DataService.trainers[i];
          final sel = p.selectedCourt == t.index;
          return GestureDetector(
            onTap: () {
              p.selectCourt(t.index);
              Future.delayed(const Duration(milliseconds: 200), onNext);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: sel
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  width: sel ? 2.5 : 1,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.kAccent.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.5),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      t.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Color(0xDD0A1828)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [0.35, 1.0],
                        ),
                      ),
                    ),
                    if (sel)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.kAccent,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => _openFullImage(ctx, t.imageUrl, t.name),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.open_in_full_rounded,
                            color: Colors.white70,
                            size: 13,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t.name,
                            style: TextStyle(
                              color: sel ? AppTheme.kAccent : Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.specialty,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

  String _getTranslatedSportName(String sport, BuildContext context) {
    switch (sport.toLowerCase()) {
      case 'football':
        return 'sport_football'.tr(context);
      case 'badminton':
        return 'sport_badminton'.tr(context);
      case 'tennis':
        return 'sport_tennis'.tr(context);
      case 'basketball':
        return 'sport_basketball'.tr(context);
      case 'gym':
        return 'sport_gym'.tr(context);
      default:
        return sport;
    }
  }

  void _openFullImage(BuildContext ctx, String url, String label) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, __, ___) => _SingleImageViewer(url: url, label: label),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }
}

class _SingleImageViewer extends StatelessWidget {
  final String url, label;
  const _SingleImageViewer({required this.url, required this.label});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: Stack(
      children: [
        Center(
          child: InteractiveViewer(
            minScale: 1.0,
            maxScale: 4.0,
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white38,
                size: 64,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              'Pinch to zoom',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ),
      ],
    ),
  );
}
