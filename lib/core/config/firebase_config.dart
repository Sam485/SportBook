import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sportbook/firebase_options.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Track initialization status
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<bool> initialize() async {
    try {
      // Only initialize if not already done
      if (!_isInitialized) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        _isInitialized = true;
      }
      return true;
    } catch (e) {
      _isInitialized = false;
      return false;
    }
  }

  static Future<String?> getFirebaseIdToken() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final user = auth.currentUser;
      if (user != null) {
        // Force refresh token if needed
        return await user.getIdToken(true);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getFcmToken() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Check if messaging is supported on this platform
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        return await messaging.getToken();
      }
      // Desktop platforms might not support FCM yet
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Only request permission on mobile and web
      if (kIsWeb ||
          defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        final permission = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return permission.authorizationStatus == AuthorizationStatus.authorized;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static bool isPlatformSupported() {
    try {
      DefaultFirebaseOptions.currentPlatform;
      return true;
    } catch (e) {
      return false;
    }
  }

  // ✅ Helper to check authentication status
  static bool get isUserAuthenticated => auth.currentUser != null;

  // ✅ Refresh token if needed
  static Future<bool> refreshTokenIfNeeded() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        await user.getIdToken(true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
