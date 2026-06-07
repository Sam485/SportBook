import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/services/data_service.dart';
import 'package:sportbook/widgets/cards/booked_card.dart';

class BookingsScreen extends StatefulWidget {
  final bool isView;
  const BookingsScreen({super.key, required this.isView});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCat = 'all';

  List<SportBooking> get _bookings =>
      DataService.filteredBookings(_selectedCat);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      appBar: widget.isView
          ? AppBar(
              backgroundColor: AppTheme.kBg,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('My Bookings', style: AppTheme.tsTitle),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _searchBar()),
            SliverToBoxAdapter(child: _categories()),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => BookedCard(booking: _bookings[i]),
                childCount: _bookings.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Only show back button in the search bar if isView is true AND no AppBar
          if (widget.isView && !widget.isView) // This condition can be adjusted
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.textFieldDecoration(Icons.search, 'Search')
                  .copyWith(
                    labelText: 'Search',
                    labelStyle: const TextStyle(color: AppTheme.kTextSub),
                  ),
              onChanged: (value) {
                // Implement search functionality
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

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
}
