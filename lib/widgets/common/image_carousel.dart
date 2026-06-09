import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 180,
    this.borderRadius,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _page = 0;
  bool _fav = false;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 10000);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
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

  void _openFull(BuildContext ctx) {
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) =>
            _FullScreenViewer(imageUrls: widget.imageUrls, initialIndex: _page),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urls = widget.imageUrls;
    final br =
        widget.borderRadius ??
        const BorderRadius.vertical(top: Radius.circular(22));

    return ClipRRect(
      borderRadius: br,
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: () => _openFull(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Pages
              PageView.builder(
                controller: _ctrl,
                itemCount: null,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i % urls.length),
                itemBuilder: (_, i) => Image.network(
                  urls[i % urls.length],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                    child: Icon(
                      Icons.image_not_supported,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      size: 36,
                    ),
                  ),
                  loadingBuilder: (_, c, p) => p == null
                      ? c
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
              ),

              // Bottom scrim
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
                    stops: const [0.45, 1.0],
                  ),
                ),
              ),

              // Dot indicators
              if (urls.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      urls.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 6,
                        height: 6,
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

              // Count badge
              if (urls.length > 1)
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_page + 1} / ${urls.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Favourite
              Positioned(
                top: 10,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _fav = !_fav),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _fav
                          ? AppTheme.kAccent.withOpacity(0.85)
                          : Colors.black.withOpacity(0.4),
                      border: Border.all(
                        color: _fav ? AppTheme.kAccent : Colors.white24,
                      ),
                    ),
                    child: Icon(
                      _fav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Full-screen viewer ───────────────────────────────────────────────────────
class _FullScreenViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const _FullScreenViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _ctrl;
  late int _cur;
  late AnimationController _fade;
  double _dragY = 0;

  @override
  void initState() {
    super.initState();
    _cur = widget.initialIndex;
    _ctrl = PageController(initialPage: 10000 + widget.initialIndex);
    _fade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fade.dispose();
    super.dispose();
  }

  void _close() => _fade.reverse().then((_) => Navigator.of(context).pop());

  @override
  Widget build(BuildContext context) {
    final total = widget.imageUrls.length;
    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onVerticalDragUpdate: (d) =>
                  setState(() => _dragY += d.primaryDelta ?? 0),
              onVerticalDragEnd: (d) {
                if (_dragY.abs() > 100 ||
                    (d.primaryVelocity ?? 0).abs() > 800) {
                  _close();
                } else {
                  setState(() => _dragY = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(0, _dragY),
                child: Opacity(
                  opacity: (1 - (_dragY.abs() / 400)).clamp(0.0, 1.0),
                  child: PageView.builder(
                    controller: _ctrl,
                    itemCount: null,
                    onPageChanged: (i) => setState(() => _cur = i % total),
                    itemBuilder: (_, i) => InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          widget.imageUrls[i % total],
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white38,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _dragY.abs() > 30 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
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
                          onPressed: _close,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            '${_cur + 1} / $total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom indicators
            if (total > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _dragY.abs() > 30 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      total,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _cur ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _cur
                              ? AppTheme.kAccent
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Close hint
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: const Center(
                child: Text(
                  'Swipe down to close',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
