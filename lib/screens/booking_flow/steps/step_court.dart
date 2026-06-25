import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/model/dto/slot_dto.dart';
import 'package:sportbook/translations/app_translations.dart';

class StepCourt extends StatelessWidget {
  final VoidCallback onNext;
  final Function(int) onCourtSelected;
  final int? selectedCourt;
  final SportClubModel? club;
  final String? selectedCategory;

  const StepCourt({
    super.key,
    required this.onNext,
    required this.onCourtSelected,
    this.selectedCourt,
    this.club,
    this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get courts from club slots - ONLY from API
    List<SlotDto> slots = [];
    List<int> courtIds = [];
    List<String> courtImages = [];
    List<String> courtNames = [];
    List<int> courtPrices = [];
    List<bool> courtAvailability = [];

    if (club != null && club!.slots != null && club!.slots!.isNotEmpty) {
      slots = club!.slots!;

      // Extract court info from slots
      for (var slot in slots) {
        courtIds.add(slot.id);
        courtNames.add(slot.name);
        courtPrices.add(slot.price);
        courtAvailability.add(slot.isAvailalbe);
        if (slot.imageUrl.isNotEmpty) {
          courtImages.add(slot.imageUrl);
        }
      }
    }

    // If no slots from API, show empty state
    if (courtIds.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          Text(
            'select_court'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'select_court_desc'.tr(context),
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.sports,
                  color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'no_courts_available'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'please_check_back_later'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final sport = selectedCategory ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        // Header
        Text(
          'select_court'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'select_court_desc'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        // Availability info if there are unavailable courts
        if (courtAvailability.contains(false)) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'some_courts_unavailable'.tr(context),
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Court Grid
        _courtGrid(
          context,
          courtIds,
          sport,
          courtImages,
          courtNames,
          courtPrices,
          courtAvailability,
          isDark,
        ),
      ],
    );
  }

  // ── Court grid (2-col with image) ──────────────────────────────────────────
  Widget _courtGrid(
    BuildContext ctx,
    List<int> courtIds,
    String sport,
    List<String> images,
    List<String> names,
    List<int> prices,
    List<bool> availability,
    bool isDark,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: courtIds.length,
      itemBuilder: (_, i) {
        final courtId = courtIds[i];
        final sel = selectedCourt == courtId;
        final img = images.isNotEmpty ? images[i % images.length] : '';
        final name = names.isNotEmpty ? names[i] : 'Court ${i + 1}';
        final price = prices.isNotEmpty ? prices[i] : 0.0;
        final isAvailable = availability.isNotEmpty ? availability[i] : true;

        return GestureDetector(
          onTap: isAvailable
              ? () {
                  onCourtSelected(courtId);
                  Future.delayed(const Duration(milliseconds: 200), onNext);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel
                    ? AppTheme.kAccent
                    : !isAvailable
                    ? Colors.grey.withValues(alpha: 0.3)
                    : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                width: sel ? 2.5 : 1,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: AppTheme.kAccent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              color: !isAvailable
                  ? (isDark
                        ? Colors.grey.withValues(alpha: 0.15)
                        : Colors.grey.withValues(alpha: 0.1))
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image - only show if image exists
                  if (img.isNotEmpty)
                    Image.network(
                      img,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                        child: Icon(
                          Icons.sports,
                          color: isAvailable
                              ? AppTheme.kAccent
                              : Colors.grey.withValues(alpha: 0.5),
                          size: 32,
                        ),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.kAccent,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
                      child: Icon(
                        Icons.sports,
                        color: isAvailable
                            ? AppTheme.kAccent
                            : Colors.grey.withValues(alpha: 0.5),
                        size: 32,
                      ),
                    ),

                  // Gradient overlay
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

                  // Unavailable overlay
                  if (!isAvailable)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'unavailable'.tr(ctx),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Check mark (selected)
                  if (sel && isAvailable)
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

                  // Expand icon (only if available and has image)
                  if (isAvailable && img.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () => _openFullImage(ctx, img, name),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.5),
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
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: !isAvailable
                                ? Colors.grey
                                : sel
                                ? AppTheme.kAccent
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            shadows: [
                              const Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (price > 0 && isAvailable)
                          Text(
                            '\$${price.toStringAsFixed(0)}/hr',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              shadows: [
                                Shadow(color: Colors.black87, blurRadius: 3),
                              ],
                            ),
                          ),
                        if (sport.isNotEmpty && price == 0 && isAvailable)
                          Text(
                            sport,
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

  void _openFullImage(BuildContext ctx, String url, String label) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => _SingleImageViewer(url: url, label: label),
        transitionsBuilder: (_, a, _, c) =>
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
              errorBuilder: (_, _, _) => const Icon(
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
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
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
