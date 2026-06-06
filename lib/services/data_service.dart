import 'package:flutter/material.dart';
import '../models/models.dart';

class DataService {
  DataService._();

  // ── Categories ─────────────────────────────────────────────────────────────
  static const List<SportCategory> categories = [
    SportCategory(id: 'all', name: 'All', emoji: '🏅'),
    SportCategory(id: 'football', name: 'Football', emoji: '⚽'),
    SportCategory(id: 'badminton', name: 'Badminton', emoji: '🏸'),
    SportCategory(id: 'tennis', name: 'Tennis', emoji: '🎾'),
    SportCategory(id: 'basketball', name: 'Basketball', emoji: '🏀'),
    SportCategory(id: 'gym', name: 'Gym', emoji: '🏋️'),
  ];

  // ── Clubs ──────────────────────────────────────────────────────────────────
  static const List<SportClub> clubs = [
    SportClub(
      id: 'c1',
      name: 'Victory FC Club',
      initials: 'VF',
      color: Color(0xFF4CAF50),
      distanceKm: 1.2,
      openTime: '06:00 AM',
      closeTime: '10:00 PM',
      venue: 'Central Park Field A',
      description: 'Professional football training with full-size pitches.',
      sports: ['Football'],
      imageUrls: [
        'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      totalCourts: 3,
      pricePerHour: 15.0,
    ),
    SportClub(
      id: 'c2',
      name: 'Smash Badminton',
      initials: 'SB',
      color: Color(0xFF29B6F6),
      distanceKm: 2.5,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
      venue: 'SportZone Hall 2',
      description: 'Indoor courts with pro-grade synthetic surface.',
      sports: ['Badminton', 'Tennis'],
      imageUrls: [
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&q=80',
      ],
      totalCourts: 6,
      pricePerHour: 12.0,
    ),
    SportClub(
      id: 'c3',
      name: 'Slam Dunk Arena',
      initials: 'SD',
      color: Color(0xFFFF9800),
      distanceKm: 4.1,
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
      venue: 'Downtown Arena Court 1',
      description: '3v3 and 5v5 basketball with floodlit courts.',
      sports: ['Basketball'],
      imageUrls: [
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=800&q=80',
      ],
      totalCourts: 5,
      pricePerHour: 18.0,
    ),
    SportClub(
      id: 'c4',
      name: 'SportZone Hub',
      initials: 'SZ',
      color: Color(0xFFFF5722),
      distanceKm: 6.8,
      openTime: '06:00 AM',
      closeTime: '12:00 AM',
      venue: 'Riverside Sports Complex',
      description: 'Multi-sport complex for all levels and ages.',
      sports: ['Football', 'Tennis', 'Basketball', 'Badminton'],
      imageUrls: [
        'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=800&q=80',
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
      ],
      totalCourts: 12,
      pricePerHour: 10.0,
    ),
    SportClub(
      id: 'c5',
      name: 'FitZone Gym',
      initials: 'FZ',
      color: Color(0xFF9C27B0),
      distanceKm: 3.3,
      openTime: '05:00 AM',
      closeTime: '11:00 PM',
      venue: 'FitZone Tower Level 2',
      description: 'Premium gym with certified personal trainers.',
      sports: ['Gym'],
      imageUrls: [
        'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&q=80',
        'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800&q=80',
      ],
      totalCourts: 4,
      pricePerHour: 25.0,
    ),
  ];

  // ── Bookings ───────────────────────────────────────────────────────────────
  static const List<SportBooking> bookings = [
    SportBooking(
      id: 'b1',
      title: 'Evening Football Rally',
      ownerName: 'Carlos Mendez',
      ownerInitials: 'CM',
      ownerColor: Color(0xFF4CAF50),
      sportTypes: ['Football'],
      venue: 'Central Park Field A',
      imageUrls: [
        'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      openTime: '08:00 AM',
      closeTime: '10:00 PM',
      bookedSlots: 3,
      totalSlots: 10,
    ),
    SportBooking(
      id: 'b2',
      title: 'Badminton & Tennis Night',
      ownerName: 'Sarah Kim',
      ownerInitials: 'SK',
      ownerColor: Color(0xFF29B6F6),
      sportTypes: ['Badminton', 'Tennis'],
      venue: 'SportZone Hall 2',
      imageUrls: [
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&q=80',
      ],
      openTime: '10:00 AM',
      closeTime: '09:00 PM',
      bookedSlots: 2,
      totalSlots: 4,
    ),
    SportBooking(
      id: 'b3',
      title: 'Multi-Sport Arena',
      ownerName: 'David Osei',
      ownerInitials: 'DO',
      ownerColor: Color(0xFFFF9800),
      sportTypes: ['Football', 'Basketball', 'Tennis'],
      venue: 'Riverside Sports Complex',
      imageUrls: [
        'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=800&q=80',
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      openTime: '07:00 AM',
      closeTime: '11:00 PM',
      bookedSlots: 5,
      totalSlots: 12,
    ),
    SportBooking(
      id: 'b4',
      title: '3v3 Basketball Open',
      ownerName: 'Priya Sharma',
      ownerInitials: 'PS',
      ownerColor: Color(0xFFFF5722),
      sportTypes: ['Basketball'],
      venue: 'Downtown Arena Court 1',
      imageUrls: [
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=800&q=80',
      ],
      openTime: '09:00 AM',
      closeTime: '08:00 PM',
      bookedSlots: 4,
      totalSlots: 6,
    ),
  ];

  // ── Court images keyed by sport ─────────────────────────────────────────────
  static const Map<String, List<String>> courtImages = {
    'Football': [
      'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600&q=80',
      'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=600&q=80',
      'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=600&q=80',
    ],
    'Badminton': [
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&q=80',
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
    ],
    'Tennis': [
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&q=80',
    ],
    'Basketball': [
      'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&q=80',
      'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=600&q=80',
    ],
    'Gym': [
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80',
      'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600&q=80',
      'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=600&q=80',
    ],
  };

  // ── Trainers ───────────────────────────────────────────────────────────────
  static const List<Trainer> trainers = [
    Trainer(
      index: 1,
      name: 'Marcus Webb',
      specialty: 'Strength & Conditioning',
      imageUrl:
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&q=80',
    ),
    Trainer(
      index: 2,
      name: 'Priya Nair',
      specialty: 'Yoga & Flexibility',
      imageUrl:
          'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&q=80',
    ),
    Trainer(
      index: 3,
      name: 'Jake Sullivan',
      specialty: 'CrossFit & HIIT',
      imageUrl:
          'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&q=80',
    ),
    Trainer(
      index: 4,
      name: 'Aisha Okafor',
      specialty: 'Nutrition & Wellness',
      imageUrl:
          'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400&q=80',
    ),
  ];

  // ── Emoji map ──────────────────────────────────────────────────────────────
  static String emojiFor(String sport) {
    switch (sport) {
      case 'Football':
        return '⚽';
      case 'Badminton':
        return '🏸';
      case 'Tennis':
        return '🎾';
      case 'Basketball':
        return '🏀';
      case 'Gym':
        return '🏋️';
      default:
        return '🏅';
    }
  }

  // ── Filter helpers ─────────────────────────────────────────────────────────
  static List<SportClub> filteredClubs(String categoryId) {
    if (categoryId == 'all') return clubs;
    return clubs
        .where((c) => c.sports.any((s) => s.toLowerCase() == categoryId))
        .toList();
  }

  static List<SportBooking> filteredBookings(String categoryId) {
    if (categoryId == 'all') return bookings;
    return bookings
        .where((b) => b.sportTypes.any((s) => s.toLowerCase() == categoryId))
        .toList();
  }

  // ── Filter helpers ─────────────────────────────────────────────────────────
  static List<SportBooking> searchClubs(String query) {
    if (query.isEmpty) return bookings;
    final lowerQuery = query.toLowerCase();

    return bookings.where((booking) {
      return booking.title.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
