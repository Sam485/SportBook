import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';

class ClubDetailed extends StatefulWidget {
  final BookingTarget target;
  const ClubDetailed({super.key, required this.target});

  @override
  State<ClubDetailed> createState() => _ClubDetailedState();
}

class _ClubDetailedState extends State<ClubDetailed> {
  int _page = 0;
  List<Map<String, dynamic>> buttonData = [
    {'label': 'Chat', 'icon': Icons.chat_outlined},
    {'label': 'Save', 'icon': Icons.favorite},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _infoSection()),
              ],
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _header() => SizedBox(
    height: 220,
    width: double.infinity,
    child: Stack(
      children: [
        if (widget.target.imageUrls.length > 1)
          CarouselSlider(
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              pauseAutoPlayOnTouch: true,
              onPageChanged: (index, reason) => setState(() {
                _page = index;
              }),
            ),
            items: widget.target.imageUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return Image.network(
                    url,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppTheme.kCardAlt,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: AppTheme.kTextSub,
                        size: 36,
                      ),
                    ),
                    loadingBuilder: (_, c, p) => p == null
                        ? c
                        : Container(
                            color: AppTheme.kCardAlt,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.kAccent,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                  );
                },
              );
            }).toList(),
          ),
        if (widget.target.imageUrls.length <= 1)
          Image.network(
            widget.target.imageUrls.first,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppTheme.kCardAlt,
              child: const Icon(
                Icons.image_not_supported,
                color: AppTheme.kTextSub,
                size: 36,
              ),
            ),
            loadingBuilder: (_, c, p) => p == null
                ? c
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
        if (widget.target.imageUrls.length > 1)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.target.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppTheme.kAccent
                        : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          top: 5,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            splashColor: AppTheme.kAccent.withOpacity(0.2),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.kCardAlt.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bottomNav() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white70)),
        color: Colors.transparent,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Wrap ListView with Expanded
            SizedBox(
              height: 60,
              width: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, // Horizontal scroll
                itemCount: buttonData.length,
                itemBuilder: (_, i) => Row(
                  children: [
                    _iconButton(
                      buttonData[i]['label'] as String,
                      buttonData[i]['icon'] as IconData,
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _iconButton(String text, IconData icon) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Colors.white),
      Text(text, style: TextStyle(color: Colors.white)),
    ],
  );

  Widget _infoSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.target.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            _openCloseBadge(),
          ],
        ),
        Row(
          children: [
            Icon(Icons.lock,),
            Text(widget.target.openTime),
            Text('-'),
            Icon(Icons.lock),
            Text(widget.target.closeTime),
          ],
        ),
      ],
    ),
  );

  Widget _openCloseBadge() {
    final now = TimeOfDay.now();
    final nowM = now.hour * 60 + now.minute;

    int parse(String t) {
      try {
        final p = t.trim().split(':');
        var h = int.parse(p[0]);
        final rest = p[1].split(' ');
        final period = rest[1].toUpperCase();
        if (period == 'PM' && h != 12) h += 12;
        if (period == 'AM' && h == 12) h = 0;
        return h * 60 + int.parse(rest[0]);
      } catch (_) {
        return 0;
      }
    }

    final isOpen =
        nowM >= parse(widget.target.openTime) &&
        nowM < parse(widget.target.closeTime);

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
            isOpen ? 'Open' : 'Closed',
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
