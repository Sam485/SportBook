import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';

class HistoryBookingsScreen extends StatelessWidget {
  final List<SportBooking> historyBookings;

  const HistoryBookingsScreen({super.key, required this.historyBookings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer(
      builder: (context, value, child) => Scaffold(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        appBar: AppBar(
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
            'History Bookings',
            style: AppTheme.tsTitleAdaptive(context),
          ),
          centerTitle: true,
        ),
        body: historyBookings.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey[600]),
                    const SizedBox(height: 16),
                    Text(
                      'No booking history',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 16,
                      ),
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
      ),
    );
  }

  Widget _historyCard(SportBooking booking, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                            style: AppTheme.tsBodyAdaptive(context),
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
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.formattedBookingDate,
                      style: AppTheme.tsSubAdaptive(context),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.formattedTimeRange,
                      style: AppTheme.tsSubAdaptive(context),
                    ),
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
