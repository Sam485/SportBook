import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sportbook/core/config/app_config.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/user_feature/repositories/user_repository.dart';
import 'package:sportbook/feature/user_feature/repositories/user_repository_imp.dart';
import 'package:sportbook/feature/user_feature/service/user_api_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register Dio
  getIt.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 900),
        receiveTimeout: const Duration(seconds: 900),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );

  // Register UserApiService
  getIt.registerLazySingleton<UserApiService>(
    () => UserApiService(getIt<Dio>()),
  );

  // Register UserRepository
  getIt.registerLazySingleton<Userrepository>(
    () => UserRepositoryImp(getIt<UserApiService>()),
  );

  getIt.registerLazySingleton<TokenService>(() => TokenService());
}
