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
}
