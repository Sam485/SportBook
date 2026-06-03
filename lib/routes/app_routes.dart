import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/main_screen.dart';
import '../screens/booking_flow/booking_flow_screen.dart';

class AppRoutes {
  static const home        = '/';
  static const bookingFlow = '/booking';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case bookingFlow:
        final target = settings.arguments as BookingTarget;
        return MaterialPageRoute(
          builder: (_) => BookingFlowScreen(target: target),
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
