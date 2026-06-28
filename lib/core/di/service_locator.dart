import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sportbook/core/config/app_config.dart';
import 'package:sportbook/core/config/firebase_config.dart';
import 'package:sportbook/core/interceptors/auth_interceptor.dart';
import 'package:sportbook/feature/Auth/service/auth_service.dart';
import 'package:sportbook/feature/Auth/service/firebase_otp_service.dart';
import 'package:sportbook/feature/Banner/repositories/banner_repository.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/Banner/service/banner_service_imp.dart';
import 'package:sportbook/feature/Booking/repository/booking_repository.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/feature/Booking/service/booking_service_imp.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/Category/service/category_service_imp.dart';
import 'package:sportbook/feature/Category/repository/category_repository.dart';
import 'package:sportbook/feature/Notification/repository/notification_repository.dart';
import 'package:sportbook/feature/Notification/service/notification_service.dart';
import 'package:sportbook/feature/Notification/service/notification_service_imp.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service_imp.dart';
import 'package:sportbook/feature/SportClub/repository/sport_club_repository.dart';
import 'package:sportbook/feature/Token/api/token_api.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/feature/User/service/user_service_imp.dart';
import 'package:sportbook/feature/User/repositories/user_api_repository.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  await FirebaseConfig.initialize();
  // Register FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ============================================================
  // REGISTER DIO FIRST (no dependencies)
  // ============================================================
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor());

    return dio;
  });

  // ============================================================
  // REGISTER TOKEN (depends on Dio)
  // ============================================================
  getIt.registerLazySingleton<TokenApi>(() => TokenApi(getIt<Dio>()));
  getIt.registerLazySingleton<TokenService>(
    () => TokenService(getIt<TokenApi>()),
  );

  // ============================================================
  // REGISTER AUTH SERVICE (depends on TokenService)
  // ============================================================
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // ============================================================
  // REGISTER NAVIGATOR KEY (to be set in main.dart)
  // ============================================================
  // Don't create it here - it will be registered in main.dart
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    getIt.registerSingleton<GlobalKey<NavigatorState>>(
      GlobalKey<NavigatorState>(),
    );
  }

  // ============================================================
  // REGISTER FIREBASE OTP SERVICE
  // ============================================================
  getIt.registerLazySingleton<FirebaseOtpService>(
    () => FirebaseOtpService.instance,
  );

  // ============================================================
  // REGISTER REPOSITORIES AND SERVICES
  // ============================================================

  // User
  getIt.registerLazySingleton<UserApiRepository>(
    () => UserApiRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<UserService>(
    () => UserServiceImp(getIt<UserApiRepository>()),
  );

  // Notification
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImp(getIt<NotificationRepository>()),
  );

  // Category
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryServiceImp(getIt<CategoryRepository>()),
  );

  // Sport Club
  getIt.registerLazySingleton<SportClubRepository>(
    () => SportClubRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<SportClubService>(
    () => SportClubServiceImp(getIt<SportClubRepository>()),
  );

  // Banner
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<BannerService>(
    () => BannerServiceImp(getIt<BannerRepository>()),
  );

  // Booking
  getIt.registerLazySingleton<BookingRepository>(
    () => BookingRepository(getIt<Dio>()),
  );
  getIt.registerLazySingleton<BookingService>(
    () => BookingServiceImp(getIt<BookingRepository>()),
  );
}
