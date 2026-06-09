import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _page = 0;
  List<String> bannerUrl = [
    'https://imgs.search.brave.com/XNAVwFxoVagfWe_ADlCQObgy3cTH3zT9UzAB4tm8k3E/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzLzdkLzU2/Lzg1LzdkNTY4NWJk/NTBmZjQ2MmRkM2Iw/ZjMxZmM4ZDcwYzli/LmpwZw',
    'https://imgs.search.brave.com/kNCsOQhi-aUgzvIEIuQOF4iAGo-gg_m7klVqN63-3us/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9taXIt/czMtY2RuLWNmLmJl/aGFuY2UubmV0L3By/b2plY3RzLzQwNC8w/NTBiYzkyNDk2Mjg1/MjMuWTNKdmNDdzRN/akFzTmpReExEVTBP/Q3d4T0RJLnBuZw',
    'https://imgs.search.brave.com/F4jmStNsufHtqiCRrcW64lC47tIs3Ch9n4rCfoAiBW8/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9kM2pt/bjAxcmkxZnpnbC5j/bG91ZGZyb250Lm5l/dC9waG90b2Fka2lu/Zy93ZWJwX3RodW1i/bmFpbC9yZWQtYW5k/LXdoaXRlLWltcHJv/dmUtc3BvcnRzLXNr/aWxsLXNwb3J0cy1i/YW5uZXItdGVtcGxh/dGUtNjVydnNxM2M0/NTQxYTAud2VicA',
    'https://imgs.search.brave.com/2zEovOYU5ZJCLn92gtNi84eHOXMkd4LL0UXJYhEf2oY/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly93d3cu/Z2F0b3JwcmludHMu/Y29tL3dwLWNvbnRl/bnQvdXBsb2Fkcy8y/MDE1LzAzL0Zvb3Ri/YWxsLUZpcmUtU3Bv/cnRzLUJhbm5lci0x/OTIweDk2MC5qcGc',
    'https://imgs.search.brave.com/GbaPJVSOcJ-W71AvFWGNTnDgbWVmnksL9PZOI5F5pOQ/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pLnBp/bmltZy5jb20vb3Jp/Z2luYWxzL2Y2LzVk/L2QxL2Y2NWRkMWFj/MTNhNzYwYTc2YzQ5/ZmE0ODRmODhkNmMx/LmpwZw',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
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
          items: bannerUrl.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
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
        if (bannerUrl.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerUrl.length,
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
