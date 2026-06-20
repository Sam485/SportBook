import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportbook/core/config/firebase_config.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'core/theme.dart';
import 'providers/booking_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'routes/app_routes.dart';

// Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseConfig.initialize();
  await FirebaseConfig.requestNotificationPermission();

  await SharedPreferences.getInstance();
  await setupServiceLocator();
  await dotenv.load(fileName: ".env");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SportMateApp());
}

class SportMateApp extends StatefulWidget {
  const SportMateApp({super.key});

  @override
  State<SportMateApp> createState() => _SportMateAppState();
}

class _SportMateAppState extends State<SportMateApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
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
      _checkTokenOnResume();
    }
  }

  Future<void> _checkTokenOnResume() async {
    try {
      final tokenService = getIt<TokenService>();
      final hasValidToken = await tokenService.hasValidTokenAsync();

      if (!hasValidToken) {
        final refreshed = await tokenService.refreshAccessToken();
        if (!refreshed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final navState = navigatorKey.currentState;
            if (navState == null) return;

            final currentRoute = ModalRoute.of(navState.context)?.settings.name;
            if (currentRoute != AppRoutes.login &&
                currentRoute != AppRoutes.splash) {
              navState.pushReplacementNamed(AppRoutes.login);
            }
          });
        }
      }
    } catch (e) {
      print('Token check on resume error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            navigatorKey: navigatorKey, // <-- add this
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
