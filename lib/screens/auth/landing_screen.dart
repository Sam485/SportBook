import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/routes/app_routes.dart';

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
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&h=1200&fit=crop', // Soccer stadium aerial
      'title': 'Book Your\nGame Today!',
      'description':
          'Find courts, book slots, and connect with players near you — all in one place.',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&h=1200&fit=crop', // Basketball
      'title': 'Find Courts\nInstantly',
      'description':
          'Discover available basketball courts, check real-time slot availability and reserve in seconds.',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1622279457486-62dcc4a431d6?w=800&h=1200&fit=crop', // Tennis court top-down
      'title': 'Meet & Play\nWith Others',
      'description':
          'Join local games, challenge nearby players, and grow your sports community.',
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=800&h=1200&fit=crop', // Athletics track
      'title': 'Track Every\nPerformance',
      'description':
          'Log your sessions, monitor progress, and push your personal best every time you play.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Column(
        children: [
          // Carousel takes most of the screen
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
            child: _carousel(),
          ),
          // Bottom section: description + dots + buttons
          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _carousel() {
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
                    color: AppTheme.kCardAlt,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: AppTheme.kTextSub,
                      size: 36,
                    ),
                  ),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: AppTheme.kCardAlt,
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
                        Color(0x66000000), // subtle dark at top
                        Colors.transparent,
                        Color(0xCC0A0E1A), // strong dark at bottom
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Three sport image strips (decorative overlay like the design)
                // Removed for simplicity — the full-bleed image carries the visual weight

                // Title at the bottom of the image
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 24,
                  child: Text(
                    slide['title'],
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

  Widget _buildBottomSection() {
    return Container(
      color: const Color(0xFF0A0E1A),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          Text(
            bannerUrl[_page]['description'],
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFADB5C7),
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
                  color: isActive ? AppTheme.kAccent : const Color(0xFF2E3548),
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
              child: const Text('Sign Up', style: AppTheme.tsButtonLabel),
            ),
          ),

          const SizedBox(height: 12),

          // Login button (outlined)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              style: AppTheme.outlineButtonStyle(),
              child: const Text('Login', style: AppTheme.tsButtonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
