import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';

class BookedDetailed extends StatelessWidget {
  final SportBooking booking;
  BookedDetailed({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('Booking Detail', style: AppTheme.tsTitle),
        centerTitle: true,
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.share))],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _paymentSummary()),
            SliverToBoxAdapter(child: _buttons()),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return SizedBox(width: double.infinity, child: Divider());
  }

  Widget _header() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
        width: double.infinity,
        height: 200,
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar circle with initials
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: booking.ownerColor.withOpacity(0.2),
                    border: Border.all(color: booking.ownerColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    booking.ownerInitials,
                    style: TextStyle(
                      color: booking.ownerColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking title
                      Text(
                        booking.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        booking.venue,
                        style: AppTheme.tsBody.copyWith(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _divider(),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16),
                SizedBox(width: 5),
                Text(
                  booking.formattedBookingDate, // ✅ real date
                  style: TextStyle(fontSize: 11.5),
                ),
                Text(' • ', style: TextStyle(fontSize: 11.5)),
                Text(
                  booking.formattedTimeRange, // ✅ real booked time slot
                  style: AppTheme.tsSub,
                ),
                Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: booking.ownerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.sportTypes[0],
                    style: TextStyle(
                      color: booking.ownerColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            _divider(),
            Row(
              children: [
                Icon(Icons.location_pin, color: AppTheme.kTextSub),
                SizedBox(width: 5),
                Text(
                  '1.2 km away',
                  style: AppTheme.tsSub.copyWith(fontSize: 16),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: AppTheme.outlineButtonStyle(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_pin, color: AppTheme.kTextSub),
                      Text(
                        'View on Map',
                        style: TextStyle(color: AppTheme.kTextSub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentSummary() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Summary!', style: AppTheme.tsTitle),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
            width: double.infinity,
            height: 165,
            decoration: AppTheme.cardDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Field Booking:', style: AppTheme.tsLabel),
                    Spacer(),
                    Text('\$15.00', style: AppTheme.tsLabel),
                  ],
                ),
                _divider(),
                Row(
                  children: [
                    Text('User Name:', style: AppTheme.tsLabel),
                    Spacer(),
                    Text(
                      booking.userName ?? '—', // ✅ from provider
                      style: AppTheme.tsLabel,
                    ),
                  ],
                ),
                _divider(),
                Row(
                  children: [
                    Text('Phone:', style: AppTheme.tsLabel),
                    Spacer(),
                    Text(
                      booking.userPhone ?? '—', // ✅ from provider
                      style: AppTheme.tsLabel,
                    ),
                  ],
                ),
                _divider(),
                Row(
                  children: [
                    Text('Total:', style: AppTheme.tsLabel),
                    Spacer(),
                    Text('\$15.00', style: AppTheme.tsLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Text('Cancel Booking'),
            style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: AppTheme.elevatedButtonStyle(),
            child: Text('ReSchedule'),
          ),
        ],
      ),
    );
  }
}
