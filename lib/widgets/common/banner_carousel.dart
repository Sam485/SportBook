// banner_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/translations/app_translations.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel>? banners;
  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _page = 0;
  final Map<int, bool> _hasError = {};
  final Map<int, bool> _isLoading = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final banners = widget.banners;

    // Show loading state
    if (banners == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppTheme.kAccent,
                strokeWidth: 2,
              ),
              SizedBox(height: 8),
              Text(
                'Loading banners...',
                style: TextStyle(color: AppTheme.kTextSub, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (banners.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.image_outlined,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'no_banners'.tr(context),
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

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 100,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            pauseAutoPlayOnTouch: true,
            onPageChanged: (index, reason) {
              setState(() {
                _page = index;
              });
            },
          ),
          items: banners.asMap().entries.map((entry) {
            final index = entry.key;
            final banner = entry.value;

            return Builder(
              builder: (BuildContext context) {
                // Check if this banner has an error
                final hasError = _hasError[index] ?? false;

                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
                    ),
                    child: hasError
                        ? _buildErrorWidget(isDark)
                        : Image.network(
                            banner.imageUrl,
                            width: MediaQuery.of(context).size.width,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (_, __, ___) {
                              // Mark this banner as having an error
                              _hasError[index] = true;
                              return _buildErrorWidget(isDark);
                            },
                            loadingBuilder: (_, child, loadingProgress) {
                              if (loadingProgress == null) {
                                // Image loaded successfully
                                return child;
                              }
                              // Image is still loading
                              return _buildLoadingWidget(isDark);
                            },
                          ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        if (banners.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
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
      ],
    );
  }

  Widget _buildLoadingWidget(bool isDark) {
    return Container(
      color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.kAccent, strokeWidth: 2),
            SizedBox(height: 8),
            Text(
              'Loading...',
              style: TextStyle(color: AppTheme.kTextSub, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'image_not_available'.tr(context),
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
