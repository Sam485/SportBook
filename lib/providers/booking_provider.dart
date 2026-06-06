import 'package:flutter/material.dart';
import '../models/models.dart';

class BookingProvider extends ChangeNotifier {
  // ── Flow state ─────────────────────────────────────────────────────────────
  BookingTarget? target;
  String? selectedSport;
  int? selectedCourt; // court number (1-based) or trainer index
  DateTime? selectedDate;
  int? startHour; // 0-23
  int? endHour; // 0-23, exclusive (endHour > startHour)
  String? userName;
  String? userPhone;
  SportBooking? confirmedBooking;

  // ── Persisted bookings ─────────────────────────────────────────────────────
  // Key: "targetId-courtNum-yyyyMMdd-sport"
  // Val: List of [startH, endH]
  final Map<String, List<List<int>>> _bookedRanges = {};

  // ── Computed ───────────────────────────────────────────────────────────────
  bool get canProceedFromCategory =>
      selectedSport != null && selectedSport!.isNotEmpty;

  bool get canProceedFromCourt => selectedCourt != null;

  bool get canProceedFromDate => selectedDate != null;

  bool get canConfirm =>
      selectedCourt != null &&
      selectedDate != null &&
      startHour != null &&
      endHour != null &&
      endHour! > startHour!;

  String get timeRangeLabel {
    if (startHour == null || endHour == null) return '';
    return '${_fmtH(startHour!)} – ${_fmtH(endHour!)}';
  }

  int get durationHours =>
      (startHour != null && endHour != null) ? endHour! - startHour! : 0;

  double get totalPrice => durationHours * (target?.pricePerHour ?? 0);

  // ── Setters ────────────────────────────────────────────────────────────────
  void setTarget(BookingTarget t) {
    target = t;
    selectedSport = t.sports.length == 1 ? t.sports.first : null;
    selectedCourt = null;
    selectedDate = null;
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  void selectSport(String sport) {
    selectedSport = sport;
    selectedCourt = null;
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  void selectCourt(int court) {
    selectedCourt = court;
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  void selectStartHour(int h) {
    startHour = h;
    if (endHour != null && endHour! <= h) endHour = null;
    notifyListeners();
  }

  void selectEndHour(int h) {
    endHour = h;
    notifyListeners();
  }

  // ── Booking conflict helpers ───────────────────────────────────────────────
  String _rangeKey(int court, DateTime date, String sport) {
    final d =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return '${target?.id ?? ''}-$court-$d-$sport';
  }

  List<List<int>> bookedRanges(int court, DateTime date, String sport) =>
      _bookedRanges[_rangeKey(court, date, sport)] ?? [];

  bool isHourBooked(int court, DateTime date, String sport, int hour) {
    for (final r in bookedRanges(court, date, sport)) {
      if (hour >= r[0] && hour < r[1]) return true;
    }
    return false;
  }

  bool rangeConflicts(int court, DateTime date, String sport, int s, int e) {
    for (final r in bookedRanges(court, date, sport)) {
      if (s < r[1] && e > r[0]) return true;
    }
    return false;
  }

  // ── Confirm ────────────────────────────────────────────────────────────────
  void confirmBooking() {
    if (!canConfirm) return;
    final key = _rangeKey(selectedCourt!, selectedDate!, selectedSport ?? '');
    (_bookedRanges[key] ??= []).add([startHour!, endHour!]);

    // Build the SportBooking from current provider state
    confirmedBooking = SportBooking(
      id: key,
      title: target!.name,
      ownerName: target!.name,
      ownerInitials: target!.initials,
      ownerColor: target!.color,
      sportTypes: selectedSport != null ? [selectedSport!] : target!.sports,
      venue: target!.venue,
      imageUrls: target!.imageUrls,
      openTime: target!.openTime,
      closeTime: target!.closeTime,
      bookedSlots: 1,
      totalSlots: target!.totalCourts,
      bookingDate: selectedDate,
      bookingStartHour: startHour,
      bookingEndHour: endHour,
      userName: userName,
      userPhone: userPhone,
    );

    notifyListeners();
  }

  void reset() {
    target = null;
    selectedSport = null;
    selectedCourt = null;
    selectedDate = null;
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  // ── Helper ─────────────────────────────────────────────────────────────────
  static String _fmtH(int h) {
    final p = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $p';
  }

  void clearTimeSelection() {
    startHour = null;
    endHour = null;
    notifyListeners();
  }

  void clearEndHour() {
    endHour = null;
    notifyListeners();
  }

  // Add to BookingProvider class
  void setUserInfo({required String name, required String phone}) {
    // Store these values for booking confirmation
    // You can add these fields to your provider
    userName = name;
    userPhone = phone;
    notifyListeners();
  }
}
