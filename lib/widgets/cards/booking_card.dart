import 'package:flutter/material.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import '../../core/theme.dart';
import '../../feature/static/services/data_service.dart';
import '../../routes/app_routes.dart';
import '../common/image_carousel.dart';

// ─── Booking Card ─────────────────────────────────────────────────────────────
class BookingCard extends StatelessWidget {
  final BookingModel booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get image URLs from sportClub or use default
    final List<String> imageUrls = [
      'https://imgs.search.brave.com/KYNGI-vHgjDPTt1UOVl3OM2Cf4h0qZXzvBZOccwSXqs/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9ib29r/aXBoeS5jb20vd2Vi/LWFzc2V0cy1uZXcv/aW1nL2luZHVzdHJp/ZXMvbXVsdGlfc3Bv/cnRzL211bHRpX3Nw/b3J0cy0xLmpwZw',
    ];

    // Get unique sports from slot or sportClub
    final List<String> sports = _getSports();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Container(
        decoration: AppTheme.cardDecorationAdaptive(context, radius: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel
            ImageCarousel(
              imageUrls: booking.sportClub.imageUrls ?? imageUrls,
              height: 180,
              showFavorite: false,
            ),

            // Tappable details
            InkWell(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.bookedDetailed,
                arguments: booking,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
              splashColor: AppTheme.kAccent.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Owner row
                    Row(
                      children: [
                        _avatar(
                          booking.user.fullName,
                          _getAvatarColor(booking.user.id),
                          isDark,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.slot.name, // Using slot name
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.kLightText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              _timeRow(
                                booking.startTime,
                                booking.endTime,
                                isDark,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: isDark
                              ? AppTheme.kTextSub
                              : AppTheme.kLightTextSub,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    ),
                    const SizedBox(height: 12),

                    // Venue
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: AppTheme.kAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            booking
                                .sportClub
                                .location, // Using location from sportClub
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              color: isDark
                                  ? Colors.white70
                                  : AppTheme.kLightTextSub,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Sport tags
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.sports_outlined,
                            color: AppTheme.kAccent,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: sports
                                .map((s) => _sportTag(s, isDark, context))
                                .toList(),
                          ),
                        ),
                      ],
                    ),

                    // Additional booking info (optional)
                    const SizedBox(height: 8),
                    _bookingStatusRow(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get sports
  List<String> _getSports() {
    // If you have a sports list in your model, use it
    // Otherwise, derive from slot name or use a default
    final String slotName = booking.slot.name.toLowerCase();

    // Check if slot name contains sport keywords
    if (slotName.contains('football') || slotName.contains('soccer')) {
      return ['Football'];
    } else if (slotName.contains('basketball')) {
      return ['Basketball'];
    } else if (slotName.contains('tennis')) {
      return ['Tennis'];
    } else if (slotName.contains('swimming')) {
      return ['Swimming'];
    } else if (slotName.contains('badminton')) {
      return ['Badminton'];
    } else if (slotName.contains('volleyball')) {
      return ['Volleyball'];
    } else if (slotName.contains('cricket')) {
      return ['Cricket'];
    } else {
      // Try to extract from sport club name
      final String clubName = booking.sportClub.name.toLowerCase();
      if (clubName.contains('football') || clubName.contains('soccer')) {
        return ['Football'];
      } else if (clubName.contains('basketball')) {
        return ['Basketball'];
      } else if (clubName.contains('tennis')) {
        return ['Tennis'];
      } else if (clubName.contains('swimming')) {
        return ['Swimming'];
      } else if (clubName.contains('badminton')) {
        return ['Badminton'];
      } else if (clubName.contains('volleyball')) {
        return ['Volleyball'];
      } else if (clubName.contains('cricket')) {
        return ['Cricket'];
      }
    }

    // Default fallback
    return ['Sports'];
  }

  // Helper method to get avatar color based on user ID
  Color _getAvatarColor(int userId) {
    // Generate a consistent color based on user ID
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[userId % colors.length];
  }

  Widget _avatar(String fullName, Color color, bool isDark) {
    // Get initials from full name
    String initials = '';
    if (fullName.isNotEmpty) {
      final nameParts = fullName.split(' ');
      if (nameParts.length >= 2) {
        initials = '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts.isNotEmpty) {
        initials = nameParts[0].substring(0, nameParts[0].length > 1 ? 2 : 1);
      }
    }
    initials = initials.toUpperCase();

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1.8),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? Colors.white : AppTheme.kLightText,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _timeRow(String startTime, String endTime, bool isDark) => Row(
    children: [
      const Icon(Icons.lock_open_outlined, color: AppTheme.kAccent, size: 12),
      const SizedBox(width: 3),
      Text(
        startTime,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: AppTheme.kAccent,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          shape: BoxShape.circle,
        ),
      ),
      const SizedBox(width: 8),
      const Icon(Icons.lock_outline, color: AppTheme.kTextSub, size: 12),
      const SizedBox(width: 3),
      Text(
        endTime,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          fontSize: 11.5,
        ),
      ),
    ],
  );

  Widget _sportTag(String sport, bool isDark, BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.kAccent.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.kAccent.withOpacity(0.35)),
        ),
        child: Text(
          '${DataService.emojiFor(sport)} $sport',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.kAccent,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  // Optional: Add booking status row
  Widget _bookingStatusRow(bool isDark) {
    Color statusColor;
    String statusText = booking.status;

    switch (booking.status.toLowerCase()) {
      case 'confirmed':
        statusColor = Colors.green;
        statusText = '✓ Confirmed';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = '⌛ Pending';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = '✕ Cancelled';
        break;
      default:
        statusColor = Colors.grey;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (booking.payment != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              '💰 \$${booking.payment!.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.blue,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
