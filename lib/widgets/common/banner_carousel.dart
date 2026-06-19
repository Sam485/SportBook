// banner_carousel.dart
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel>? banners;
  const BannerCarousel({super.key, required this.banners});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final banners = widget.banners;

    // Show loading or empty state
    if (banners == null) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.kAccent,
            strokeWidth: 2,
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
          child: Text(
            'No banners available',
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
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
          items: banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    banner.imageUrl, // Adjust this based on your BannerModel
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
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
}
