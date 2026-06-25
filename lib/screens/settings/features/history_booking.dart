// screens/settings/features/history_booking.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/booked_card.dart';

class HistoryBookingsScreen extends StatelessWidget {
  final List<BookingModel> bookings;

  const HistoryBookingsScreen({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
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
          'history_bookings'.tr(context),
          style: AppTheme.tsTitleAdaptive(context),
        ),
        centerTitle: true,
      ),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_booking_history'.tr(context),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'past_bookings_appear_here'.tr(context),
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.kTextSub
                          : AppTheme.kLightTextSub,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                return BookedCard(booking: bookings[index]);
              },
            ),
    );
  }
}
