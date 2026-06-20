import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:sportbook/core/config/app_config.dart';
import 'package:sportbook/core/interceptors/auth_interceptor.dart';
import 'package:sportbook/feature/Auth/service/firebase_otp_service.dart';
import 'package:sportbook/feature/Banner/repositories/banner_repository.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/Banner/service/banner_service_imp.dart';
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
  // Register FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // ============================================================
  // REGISTER FIREBASE OTP SERVICE
  // ============================================================
  getIt.registerLazySingleton<FirebaseOtpService>(
    () => FirebaseOtpService.instance,
  );

  // Register Dio with interceptors
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
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  });

  // Register TokenApi
  getIt.registerLazySingleton<TokenApi>(() => TokenApi(getIt<Dio>()));

  // Register TokenService
  getIt.registerLazySingleton<TokenService>(
    () => TokenService(getIt<TokenApi>()),
  );

  // Register UserRepository
  getIt.registerLazySingleton<UserApiRepository>(
    () => UserApiRepository(getIt<Dio>()),
  );

  // Register UserService
  getIt.registerLazySingleton<UserService>(
    () => UserServiceImp(getIt<UserApiRepository>()),
  );

  // Register NotificationRepository
  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(getIt<Dio>()),
  );

  // Register NotificationService
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationServiceImp(getIt<NotificationRepository>()),
  );

  // Register CategoryRepository
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<Dio>()),
  );

  // Register CategoryService
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryServiceImp(getIt<CategoryRepository>()),
  );

  // Register SportClubRepository
  getIt.registerLazySingleton<SportClubRepository>(
    () => SportClubRepository(getIt<Dio>()),
  );

  // Register SportClubService
  getIt.registerLazySingleton<SportClubService>(
    () => SportClubServiceImp(getIt<SportClubRepository>()),
  );

  // Register BannerRepository
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepository(getIt<Dio>()),
  );

  // Register BannerService
  getIt.registerLazySingleton<BannerService>(
    () => BannerServiceImp(getIt<BannerRepository>()),
  );
}
