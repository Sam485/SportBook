import 'package:flutter/material.dart';

// ─── Sport Category ───────────────────────────────────────────────────────────
class SportCategory {
  final String id;
  final String name;
  final String emoji;
  const SportCategory({
    required this.id,
    required this.name,
    required this.emoji,
  });
}

// ─── Sport Club ───────────────────────────────────────────────────────────────
class SportClub {
  final String id;
  final String name;
  final String initials;
  final Color color;
  final double distanceKm;
  final String openTime;
  final String closeTime;
  final String venue;
  final String description;
  final List<String> sports;
  final List<String> imageUrls;
  final int totalCourts;
  final double pricePerHour;

  const SportClub({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    required this.distanceKm,
    required this.openTime,
    required this.closeTime,
    required this.venue,
    required this.description,
    required this.sports,
    required this.imageUrls,
    required this.totalCourts,
    required this.pricePerHour,
  });

  bool get isGym => sports.any((s) => s == 'Gym');
}

// ─── Sport Booking (upcoming session) ────────────────────────────────────────
class SportBooking {
  final String id;
  final String title;
  final String ownerName;
  final String ownerInitials;
  final Color ownerColor;
  final List<String> sportTypes;
  final String venue;
  final List<String> imageUrls;
  final String openTime; // club open hour (display only)
  final String closeTime; // club close hour (display only)
  final int bookedSlots;
  final int totalSlots;

  // ── NEW: user's actual booking data ──
  final DateTime? bookingDate; // the day the user booked
  final int? bookingStartHour; // 0-23
  final int? bookingEndHour; // 0-23
  final String? userName;
  final String? userPhone;

  const SportBooking({
    required this.id,
    required this.title,
    required this.ownerName,
    required this.ownerInitials,
    required this.ownerColor,
    required this.sportTypes,
    required this.venue,
    required this.imageUrls,
    required this.openTime,
    required this.closeTime,
    required this.bookedSlots,
    required this.totalSlots,
    this.bookingDate,
    this.bookingStartHour,
    this.bookingEndHour,
    this.userName,
    this.userPhone,
  });

  String get primarySport => sportTypes.isNotEmpty ? sportTypes.first : 'Sport';

  // Helpers for formatted display
  static String _fmtH(int h) {
    final p = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $p';
  }

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  String get formattedBookingDate {
    if (bookingDate == null) return '—';
    final d = bookingDate!;
    return '${_weekdays[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  String get formattedTimeRange {
    if (bookingStartHour == null || bookingEndHour == null) return '—';
    return '${_fmtH(bookingStartHour!)} – ${_fmtH(bookingEndHour!)}';
  }
}

// ─── Booking Target (passed to BookingFlowScreen) ─────────────────────────────
class BookingTarget {
  final String id;
  final String name;
  final String initials;
  final Color color;
  final List<String> sports;
  final String venue;
  final List<String> imageUrls;
  final String openTime;
  final String closeTime;
  final int totalCourts;
  final double pricePerHour;

  const BookingTarget({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    required this.sports,
    required this.venue,
    required this.imageUrls,
    required this.openTime,
    required this.closeTime,
    required this.totalCourts,
    required this.pricePerHour,
  });

  bool get isGym => sports.any((s) => s == 'Gym');

  factory BookingTarget.fromClub(SportClub c) => BookingTarget(
    id: c.id,
    name: c.name,
    initials: c.initials,
    color: c.color,
    sports: c.sports,
    venue: c.venue,
    imageUrls: c.imageUrls,
    openTime: c.openTime,
    closeTime: c.closeTime,
    totalCourts: c.totalCourts,
    pricePerHour: c.pricePerHour,
  );

  factory BookingTarget.fromBooking(SportBooking b) => BookingTarget(
    id: b.id,
    name: b.title,
    initials: b.ownerInitials,
    color: b.ownerColor,
    sports: b.sportTypes.toSet().toList(),
    venue: b.venue,
    imageUrls: b.imageUrls,
    openTime: b.openTime,
    closeTime: b.closeTime,
    totalCourts: b.totalSlots,
    pricePerHour: 12.0,
  );
}

// ─── Trainer ──────────────────────────────────────────────────────────────────
class Trainer {
  final int index;
  final String name;
  final String specialty;
  final String imageUrl;
  const Trainer({
    required this.index,
    required this.name,
    required this.specialty,
    required this.imageUrl,
  });
}

// ─── PaymentMethod ──────────────────────────────────────────────────────────────────
enum PaymentMethod { cash, ecash }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.ecash:
        return 'E-Cash';
    }
  }

  String get apiValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.ecash:
        return 'E_CASH';
    }
  }
}

// ─── Banner ──────────────────────────────────────────────────────────────────
class BannerSport {
  final int id;
  final String name;
  const BannerSport({required this.id, required this.name});
}

// ─── Notification ─────────────────────────────────────────────────────────────
class NotificationItem {
  final IconData icon;
  final String title;
  final String description;
  final String datetime;
  final String category;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.datetime,
    required this.category,
    required this.iconColor,
    this.isRead = false,
  });
}
