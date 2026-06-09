import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/services/data_service.dart';
import 'package:sportbook/widgets/cards/booking_card.dart';
import 'package:sportbook/widgets/common/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCat = 'all';
  String _query = "";

  List<SportBooking> get _bookings {
    if (_query == "") {
      return DataService.filteredBookings(_selectedCat);
    }
    return DataService.searchClubs(_query);
  }

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _searchBar(context)),
            SliverToBoxAdapter(child: _categories(context)),
            SliverToBoxAdapter(
              child: SectionHeader(title: 'Nearby', isDark: isDark),
            ),
            _nearByList(context),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _searchBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.kLightText,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: 'Search clubs, sports...',
          hintStyle: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
          filled: true,
          fillColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (query) {
          setState(() {
            _query = query;
          });
        },
      ),
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Widget _categories(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: DataService.categories.length,
          itemBuilder: (_, i) {
            final cat = DataService.categories[i];
            final sel = _selectedCat == cat.id;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : isDark
                      ? AppTheme.kCard
                      : AppTheme.kLightCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : isDark
                        ? AppTheme.kBorder
                        : AppTheme.kLightBorder,
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppTheme.kAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat.emoji, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 6),
                    Text(
                      cat.name,
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : (isDark
                                  ? Colors.white60
                                  : AppTheme.kLightTextSub),
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Near By List ────────────────────────────────────────────────────────────
  Widget _nearByList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final booking = _bookings;

    if (booking.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Center(
            child: Text(
              _query.isEmpty
                  ? 'No nearby club found!'
                  : 'No results found for "$_query"',
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => BookingCard(booking: _bookings[i]),
        childCount: _bookings.length,
      ),
    );
  }
}
