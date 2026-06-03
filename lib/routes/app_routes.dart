import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/main_screen.dart';
import '../screens/booking_flow/booking_flow_screen.dart';
import '../screens/club_detailed/club_detailed.dart';

class AppRoutes {
  static const home        = '/';
  static const bookingFlow = '/booking';
  static const clubDetailed = '/clubDetailed';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case bookingFlow:
        final target = settings.arguments as BookingTarget;
        return MaterialPageRoute(
          builder: (_) => BookingFlowScreen(target: target),
        );

      case clubDetailed:
        final target = settings.arguments as BookingTarget;
        return MaterialPageRoute(
          builder: (_) => ClubDetailed(target: target),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found',
                  style: const TextStyle(color: Colors.white)),
            ),
          ),
        );
    }
  }
}
