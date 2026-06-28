import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sportbook/core/config/firebase_config.dart';

class FirebaseOtpService {
  FirebaseOtpService._internal();
  static final FirebaseOtpService instance = FirebaseOtpService._internal();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _verificationId;
  int? _resendToken;
  String? _phoneNumber;

  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException e) onFailed,
    bool isResend = false,
  }) async {
    try {
      await FirebaseConfig.initialize();

      final timeout = defaultTargetPlatform == TargetPlatform.iOS
          ? const Duration(seconds: 90)
          : const Duration(seconds: 60);

      _phoneNumber = phoneNumber;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: isResend ? _resendToken : null,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _firebaseAuth.signInWithCredential(credential);
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

  Future<User> verifyOtp({
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

    if (smsCode.isEmpty || smsCode.length != 6) {
      throw FirebaseAuthException(
        code: 'invalid-verification-code',
        message: 'Please enter a valid 6-digit OTP code.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found for this verification.',
        );
      }

      if (_phoneNumber != null && user.phoneNumber != _phoneNumber) {
        throw FirebaseAuthException(
          code: 'phone-mismatch',
          message: 'Phone number mismatch. Please try again.',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code' ||
          e.code == 'session-expired') {
        _verificationId = null;
      }

      rethrow;
    } catch (e) {
      // ✅ FIX: Handle the platform channel error
      // When this error occurs, the user might still be signed in
      if (e.toString().contains('PigeonUserDetails')) {
        // Wait a moment for Firebase to complete the sign-in process
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if user is now signed in
        final currentUser = _firebaseAuth.currentUser;

        if (currentUser != null) {
          // Verify this is the correct user
          if (currentUser.phoneNumber == _phoneNumber) {
            return currentUser;
          } else {
            throw FirebaseAuthException(
              code: 'phone-mismatch',
              message: 'Phone number mismatch. Please try again.',
            );
          }
        } else {
          throw FirebaseAuthException(
            code: 'verification-failed',
            message: 'Verification failed. Please try again.',
          );
        }
      }

      throw FirebaseAuthException(
        code: 'verification-failed',
        message: 'Verification failed: ${e.toString()}',
      );
    }
  }

  // ... rest of the code
}
