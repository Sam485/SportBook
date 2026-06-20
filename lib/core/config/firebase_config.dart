import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseConfig {
  static FirebaseAuth get auth => FirebaseAuth.instance;
  static FirebaseMessaging get messaging => FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  static Future<String?> getFirebaseIdToken() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      print('Error getting Firebase ID token: $e');
      return null;
    }
  }

  static Future<String?> getFcmToken() async {
    try {
      return await messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> requestNotificationPermission() async {
    try {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    } catch (e) {
      print('Error requesting notification permission: $e');
    }
  }
}
