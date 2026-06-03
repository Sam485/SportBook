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
  final String openTime;
  final String closeTime;
  final int bookedSlots;
  final int totalSlots;

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
  });

  String get primarySport => sportTypes.isNotEmpty ? sportTypes.first : 'Sport';
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
