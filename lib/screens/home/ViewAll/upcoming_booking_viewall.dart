import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/static/services/data_service.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/booking_card.dart';

class UpcomingBookingViewAll extends StatefulWidget {
  final String title;
  final List<BookingModel> bookings;

  const UpcomingBookingViewAll({
    super.key,
    required this.title,
    required this.bookings,
  });

  @override
  State<UpcomingBookingViewAll> createState() => _UpcomingBookingViewAllState();
}

class _UpcomingBookingViewAllState extends State<UpcomingBookingViewAll> {
  String _selectedFilter = 'all';

  // Get unique sport types from bookings
  List<String> get _sportTypes {
    final sports = <String>{};
    for (final booking in widget.bookings) {
      // Extract sport from slot name or use a default
      final sport = _extractSport(booking.slot.name);
      sports.add(sport);
    }
    return sports.toList()..sort();
  }

  // Extract sport from slot name
  String _extractSport(String slotName) {
    final name = slotName.toLowerCase();
    if (name.contains('football') || name.contains('soccer')) return 'Football';
    if (name.contains('basketball')) return 'Basketball';
    if (name.contains('tennis')) return 'Tennis';
    if (name.contains('swimming')) return 'Swimming';
    if (name.contains('badminton')) return 'Badminton';
    if (name.contains('volleyball')) return 'Volleyball';
    if (name.contains('cricket')) return 'Cricket';
    if (name.contains('golf')) return 'Golf';
    if (name.contains('rugby')) return 'Rugby';
    if (name.contains('boxing')) return 'Boxing';
    if (name.contains('yoga')) return 'Yoga';
    if (name.contains('gym')) return 'Gym';
    return 'Sports';
  }

  // Get filtered bookings
  List<BookingModel> get _filteredBookings {
    List<BookingModel> result = widget.bookings;

    // Filter by sport
    if (_selectedFilter != 'all') {
      result = result.where((booking) {
        final sport = _extractSport(booking.slot.name);
        return sport == _selectedFilter;
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredBookings = _filteredBookings;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sport filter categories
            _buildSportFilters(isDark),

            // Bookings list
            Expanded(
              child: filteredBookings.isEmpty
                  ? Center(child: _buildEmptyState(isDark))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return BookingCard(booking: booking);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportFilters(bool isDark) {
    final sportTypes = _sportTypes;

    if (sportTypes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: sportTypes.length + 1, // +1 for 'All'
          itemBuilder: (_, i) {
            final isAll = i == 0;
            final filter = isAll ? 'all' : sportTypes[i - 1];
            final isSelected = _selectedFilter == filter;

            // Get emoji for the sport
            String emoji = '🏆';
            if (!isAll) {
              emoji = DataService.emojiFor(filter);
            }

            return GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kCard : AppTheme.kLightCard),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.kAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll)
                      Text(
                        emoji,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                        ),
                      ),
                    if (!isAll) const SizedBox(width: 6),
                    Text(
                      isAll ? 'All' : filter,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isSelected
                            ? const Color(0xFF0A1828)
                            : (isDark
                                  ? Colors.white60
                                  : AppTheme.kLightTextSub),
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
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

  Widget _buildEmptyState(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.kAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_month_rounded,
            color: AppTheme.kAccent,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'no_bookings'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedFilter != 'all'
              ? 'No $_selectedFilter bookings found'
              : 'You don\'t have any upcoming bookings yet',
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        if (_selectedFilter != 'all') ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: const Text('Clear Filters'),
          ),
        ],
      ],
    );
  }
}
