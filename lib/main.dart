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

  await FirebaseConfig.initialize();
  await FirebaseConfig.requestNotificationPermission();

  await SharedPreferences.getInstance();
  await setupServiceLocator();

  // Register the navigator key in service locator
  final navigatorKey = GlobalKey<NavigatorState>();
  if (!getIt.isRegistered<GlobalKey<NavigatorState>>()) {
    getIt.registerSingleton<GlobalKey<NavigatorState>>(navigatorKey);
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(SportMateApp(navigatorKey: navigatorKey));
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
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
