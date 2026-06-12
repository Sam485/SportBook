import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/models/models.dart';
import 'package:sportbook/feature/services/data_service.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/booked_card.dart';

class BookingsScreen extends StatefulWidget {
  final bool isView;
  const BookingsScreen({super.key, required this.isView});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<SportBooking> get _bookings => DataService.filteredBookings('all');

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
      appBar: widget.isView
          ? AppBar(
              backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'My Bookings',
                style: AppTheme.tsTitleAdaptive(context),
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Only show back button in the search bar if isView is true AND no AppBar
          if (widget.isView && !widget.isView) // This condition can be adjusted
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: isDark ? Colors.white : Colors.black,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: AppTheme.textFieldDecoration(Icons.search, 'Search')
                  .copyWith(
                    labelText: 'search'.tr(context),
                    labelStyle: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                    ),
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
