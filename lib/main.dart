// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportbook/core/config/firebase_config.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Auth/service/auth_service.dart';
import 'core/theme.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with proper error handling
  await _initializeFirebase();

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Setup service locator
  await setupServiceLocator();

  // Register the navigator key in service locator
  final navigatorKey = GlobalKey<NavigatorState>();
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(SportMateApp(navigatorKey: navigatorKey));
}

/// Initialize Firebase with proper error handling
Future<void> _initializeFirebase() async {
  try {
    // Initialize Firebase
    final initialized = await FirebaseConfig.initialize();

    if (initialized) {
      // Request notification permission only on supported platforms
      await FirebaseConfig.requestNotificationPermission();
    }
  } catch (e) {
    // App will continue without Firebase features
  }
}

class SportMateApp extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const SportMateApp({super.key, required this.navigatorKey});

  @override
  State<SportMateApp> createState() => _SportMateAppState();
}

class _SportMateAppState extends State<SportMateApp>
    with WidgetsBindingObserver {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = getIt<AuthService>();
    WidgetsBinding.instance.addObserver(this);

    // Initialize FCM token if Firebase is available
    _initializeFcmToken();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _authService.checkTokenOnResume();
    }
  }

  /// Initialize FCM token if Firebase is available
  Future<void> _initializeFcmToken() async {
    try {
      if (FirebaseConfig.isInitialized) {
        final token = await FirebaseConfig.getFcmToken();
        if (token != null) {
          // You can store this token or send it to your backend
          // await _sendFcmTokenToBackend(token);
        }
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        Provider<AuthService>.value(value: _authService),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            navigatorKey: widget.navigatorKey,
            title: 'SportMate',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            locale: languageProvider.locale,
            supportedLocales: const [Locale('en', ''), Locale('km', '')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRoutes.home,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              // Add a builder to handle Firebase errors globally
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}
