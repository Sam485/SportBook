import 'package:flutter/material.dart';
import 'package:sportbook/screens/auth/forget_screen.dart';
import 'package:sportbook/screens/auth/landing_screen.dart';
import 'package:sportbook/screens/auth/login_screen.dart';
import 'package:sportbook/screens/auth/signup_screen.dart';
import 'package:sportbook/screens/auth/verify_screen.dart';
import '../models/models.dart';
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

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case verify:
        return MaterialPageRoute(builder: (_) => const VerifyScreen());

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
