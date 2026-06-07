import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';

class HistoryBookingsScreen extends StatelessWidget {
  final List<SportBooking> historyBookings;

  const HistoryBookingsScreen({super.key, required this.historyBookings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      appBar: AppBar(
        backgroundColor: AppTheme.kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('History Bookings', style: AppTheme.tsTitle),
        centerTitle: true,
      ),
      body: historyBookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  const Text(
                    'No booking history',
                    style: TextStyle(color: AppTheme.kTextSub, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your past bookings will appear here',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyBookings.length,
              itemBuilder: (context, index) {
                final booking = historyBookings[index];
                return _historyCard(booking, context);
              },
            ),
    );
  }

  Widget _historyCard(SportBooking booking, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to booking details
            // Navigator.pushNamed(context, AppRoutes.bookedDetailed, arguments: booking);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: booking.ownerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        color: booking.ownerColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.title,
                            style: AppTheme.tsTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            booking.venue,
                            style: AppTheme.tsBody,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppTheme.kTextSub,
                    ),
                    const SizedBox(width: 4),
                    Text(booking.formattedBookingDate, style: AppTheme.tsSub),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.kTextSub,
                    ),
                    const SizedBox(width: 4),
                    Text(booking.formattedTimeRange, style: AppTheme.tsSub),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
