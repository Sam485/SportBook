import 'package:flutter/material.dart';
import 'package:sportbook/feature/user_feature/model/register_request_dto.dart';
import 'package:sportbook/screens/auth/create_profile_screen.dart';
import 'package:sportbook/screens/auth/forget_screen.dart';
import 'package:sportbook/screens/auth/landing_screen.dart';
import 'package:sportbook/screens/auth/login_screen.dart';
import 'package:sportbook/screens/auth/signup_screen.dart';
import 'package:sportbook/screens/auth/verify_screen.dart';
import 'package:sportbook/screens/bookings/bookings_screen.dart';
import 'package:sportbook/screens/bookings/detail/booked_detailed.dart';
import 'package:sportbook/screens/home/Notification/notification_screen.dart';
import 'package:sportbook/screens/home/ViewAll/view_all.dart';
import '../feature/models/models.dart';
import '../screens/main_screen.dart';
import '../screens/booking_flow/booking_flow_screen.dart';
import '../screens/club_detailed/club_detailed.dart';

class AppRoutes {
  static const home = '/';
  static const bookingFlow = '/booking';
  static const clubDetailed = '/clubDetailed';
  static const landing = '/landing';
  static const signUp = '/signup';
  static const login = '/login';
  static const forget = '/forget';
  static const verify = '/verify';
  static const createProfile = '/createProfile';
  static const bookedDetailed = '/bookedDetailed';
  static const notification = '/notification';
  static const viewAll = '/viewAll';
  static const allbookings = '/allBookings';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case allbookings:
        final target = settings.arguments as bool;
        return MaterialPageRoute(
          builder: (_) => BookingsScreen(isView: target),
        );

      case viewAll:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ViewAll(
            title: args['title'] as String,
            data: args['data'] as List<SportClub>,
          ),
        );

      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case createProfile:
        final args = settings.arguments as RegisterRequestDto;
        return MaterialPageRoute(
          builder: (_) => CreateProfileScreen(user: args),
        );

      case bookedDetailed:
        final target = settings.arguments as SportBooking;
        return MaterialPageRoute(
          builder: (_) => BookedDetailed(booking: target),
        );

      case verify:
        final target = settings.arguments as RegisterRequestDto?;
        return MaterialPageRoute(
          builder: (_) => VerifyScreen(isSignUp: target),
        );

      case forget:
        return MaterialPageRoute(builder: (_) => const ForgetScreen());

      case landing:
        return MaterialPageRoute(builder: (_) => LandingScreen());

      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case signUp:
        return MaterialPageRoute(builder: (_) => SignUpScreen());

      case bookingFlow:
        final target = settings.arguments as BookingTarget;
        return MaterialPageRoute(
          builder: (_) => BookingFlowScreen(target: target),
        );

      case clubDetailed:
        final target = settings.arguments as BookingTarget;
        return MaterialPageRoute(builder: (_) => ClubDetailed(target: target));

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text(
                'Route ${settings.name} not found',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
    }
  }
}
