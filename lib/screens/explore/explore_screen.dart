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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _searchBar()),
            SliverToBoxAdapter(child: _categories()),
            SliverToBoxAdapter(child: const SectionHeader(title: 'Nearby')),
            _nearByList(),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        decoration: AppTheme.textFieldDecoration(
          Icons.search,
          'Search',
        ).copyWith(labelText: 'Search'),
        onChanged: (query) {
          setState(() {
            _query = query;
          });
        },
      ),
    );
  }

  // ── Categories ────────────────────────────────────────────────────────────
  Widget _categories() => Padding(
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? AppTheme.kAccent : AppTheme.kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: sel ? AppTheme.kAccent : AppTheme.kBorder,
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
                      color: sel ? const Color(0xFF0A1828) : Colors.white60,
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
  // ── Categories ────────────────────────────────────────────────────────────
  Widget _nearByList() {
    final booking = _bookings;
    if (booking.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: const Center(
            child: Text(
              'No nearby club found!',
              style: TextStyle(color: AppTheme.kTextSub, fontSize: 14),
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
