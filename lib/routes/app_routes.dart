import 'package:flutter/material.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/screens/auth/forget_password_screen.dart';
import 'package:sportbook/screens/auth/login_screen.dart';
import 'package:sportbook/screens/auth/reset_password_screen.dart';
import 'package:sportbook/screens/auth/sign_in_with_otp_screen.dart';
import 'package:sportbook/screens/auth/sign_up_screen.dart';
import 'package:sportbook/screens/auth/verify_screen.dart';
import 'package:sportbook/screens/bookings/bookings_screen.dart';
import 'package:sportbook/screens/bookings/detail/booked_detailed.dart';
import 'package:sportbook/screens/home/Notification/notification_screen.dart';
import 'package:sportbook/screens/home/ViewAll/view_all.dart';
import 'package:sportbook/screens/loading/splash_screen.dart';
import '../feature/static/models/models.dart';
import '../screens/main_screen.dart';
import '../screens/booking_flow/booking_flow_screen.dart';
import '../screens/club_detailed/club_detailed.dart';

class AppRoutes {
  static const String home = '/';
  static const String bookingFlow = '/booking';
  static const String clubDetailed = '/club-detailed';
  static const String landing = '/landing';
  static const String verify = '/verify';
  static const String bookedDetailed = '/booked-detailed';
  static const String notification = '/notification';
  static const String viewAll = '/view-all';
  static const String allbookings = '/all-bookings';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpLogin = '/otp-login';
  static const String forgetPass = '/forget-password';
  static const String otpVerify = '/otp-verify';
  static const String resetPassword = '/reset-password';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case otpVerify:
        return MaterialPageRoute(builder: (_) => const VerifyScreen());
      case resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      case forgetPass:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());

      case otpLogin:
        return MaterialPageRoute(builder: (_) => const SignInWithOtpScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

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
            data: args['data'] as List<SportClubModel>,
          ),
        );

      case notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      case bookedDetailed:
        final target = settings.arguments as SportBooking;
        return MaterialPageRoute(
          builder: (_) => BookedDetailed(booking: target),
        );

      case bookingFlow:
        final target = settings.arguments as SportClubModel;
        return MaterialPageRoute(
          builder: (_) => BookingFlowScreen(target: target),
        );

      case clubDetailed:
        final target = settings.arguments as SportClubModel;
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
