import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _page = 0;

  List<Map<String, dynamic>> bannerUrl = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&h=1200&fit=crop',
      'titleKey': 'banner_title_1',
      'descriptionKey': 'banner_desc_1',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&h=1200&fit=crop',
      'titleKey': 'banner_title_2',
      'descriptionKey': 'banner_desc_2',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800&h=1200&fit=crop',
      'titleKey': 'banner_title_3',
      'descriptionKey': 'banner_desc_3',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800&h=1200&fit=crop',
      'titleKey': 'banner_title_4',
      'descriptionKey': 'banner_desc_4',
    },
  ];

  // Helper method to translate
  String _tr(String key) {
    return AppTranslations.translate(key, locale: null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: _carousel(context),
          ),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _carousel(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
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
      items: bannerUrl.map((slide) {
        return Builder(
          builder: (BuildContext context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.network(
                  slide['imageUrl'],
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
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
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

                // Dark gradient overlay (top + bottom)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x66000000),
                        Colors.transparent,
                        Color(0xCC0A0E1A),
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Title at the bottom of the image
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Text(
                    AppTranslations.translate(slide['titleKey'], locale: null),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 8,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0A0E1A) : AppTheme.kLightCard,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            AppTranslations.translate(
              bannerUrl[_page]['descriptionKey'],
              locale: null,
            ),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFADB5C7) : AppTheme.kLightTextSub,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // Page indicator dots
          Row(
            children: List.generate(bannerUrl.length, (index) {
              final bool isActive = index == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: isActive ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.kAccent
                      : (isDark ? const Color(0xFF2E3548) : Colors.grey[400]),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const SizedBox(height: 50),

          // Sign Up button (primary)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.signUp),
              style: AppTheme.elevatedButtonStyle(),
              child: Text(
                AppTranslations.translate('sign_up', locale: null),
                style: AppTheme.tsButtonLabel,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Login button (outlined)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppTheme.kLightText,
                side: BorderSide(
                  color: isDark
                      ? const Color(0xFF2E3548)
                      : AppTheme.kLightBorder,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                AppTranslations.translate('login', locale: null),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
