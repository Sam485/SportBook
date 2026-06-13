import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/core/config/app_config.dart';
import 'package:sportbook/feature/Banner/repository/banner_repository.dart';
import 'package:sportbook/feature/Banner/repository/banner_repository_imp.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/Category/repository/category_repository.dart';
import 'package:sportbook/feature/Category/repository/category_repository_imp.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/Sport%20Club/Service/sport_club_service.dart';
import 'package:sportbook/feature/Sport%20Club/repository/sport_club_repository.dart';
import 'package:sportbook/feature/Sport%20Club/repository/sport_club_repository_imp.dart';
import 'package:sportbook/feature/Token/api/token_api.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/repositories/user_repository.dart';
import 'package:sportbook/feature/User/repositories/user_repository_imp.dart';
import 'package:sportbook/feature/User/service/user_api_service.dart';
import 'package:sportbook/core/interceptors/auth_interceptor.dart'; // Create this

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register FlutterSecureStorage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Register Dio with interceptors
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
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

  // Register UserApiService
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiService(getIt<Dio>()),
  );

  // Register UserRepository
  getIt.registerLazySingleton<Userrepository>(
    () => UserRepositoryImp(getIt<UserApiService>()),
  );

  // Register CategoryService
  getIt.registerLazySingleton<CategoryService>(
    () => CategoryService(getIt<Dio>()),
  );

  // Register CategoryRepository
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImp(getIt<CategoryService>()),
  );

  // Register SportClubService
  getIt.registerLazySingleton<SportClubService>(
    () => SportClubService(getIt<Dio>()),
  );

  // Register SportClubRepository
  getIt.registerLazySingleton<SportClubRepository>(
    () => SportClubRepositoryImp(getIt<SportClubService>()),
  );

  //Register BannerService
  getIt.registerLazySingleton<BannerService>(() => BannerService(getIt<Dio>()));

  // Register BannerRepository
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImp(getIt<BannerService>()),
  );
}
