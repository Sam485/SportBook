// lib/feature/Auth/service/firebase_otp_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseOtpService {
  FirebaseOtpService._internal();
  static final FirebaseOtpService instance = FirebaseOtpService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onFailed,
    bool isResend = false,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: isResend ? _resendToken : null,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _firebaseAuth.signInWithCredential(credential);
            // Don't call onAutoVerified - let the screen check currentUser
          } on FirebaseAuthException catch (e) {
            onFailed(e);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      onFailed(
        FirebaseAuthException(code: 'send_failed', message: e.toString()),
      );
    }
  }

  Future<User?> verifyOtp({
    required String smsCode,
    String? verificationIdOverride,
  }) async {
    final verificationId = verificationIdOverride ?? _verificationId;
    if (verificationId == null) {
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'No OTP was requested yet. Please request a code first.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      await _firebaseAuth.signInWithCredential(credential);

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        return user;
      } else {
        return null;
      }
    } catch (e) {
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        return currentUser;
      }
      rethrow;
    }
  }

  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  User? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
    } else {}
    return user;
  }

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }
}
