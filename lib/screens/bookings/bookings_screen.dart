import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/services/data_service.dart';
import 'package:sportbook/widgets/cards/booked_card.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCat = 'all';
  List<SportBooking> get _bookings =>
      DataService.filteredBookings(_selectedCat);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: ClampingScrollPhysics(),
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
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        decoration: AppTheme.textFieldDecoration(
          Icons.search,
          'Search',
        ).copyWith(labelText: 'Search'),
      ),
    );
  }
}
