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
    print('🔵 [sendOtp] Starting OTP send process');
    print('📱 Phone: $phoneNumber');
    print('🔄 IsResend: $isResend');
    print('🔑 ResendToken: ${isResend ? _resendToken : 'null'}');

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: isResend ? _resendToken : null,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('🟢 [verificationCompleted] Auto-verification triggered');
          try {
            final result = await _firebaseAuth.signInWithCredential(credential);
            print('✅ [verificationCompleted] Auto sign-in successful');
            print('👤 User: ${result.user?.uid}');
            print('📱 Phone: ${result.user?.phoneNumber}');
            // Don't call onAutoVerified - let the screen check currentUser
          } on FirebaseAuthException catch (e) {
            print(
              '❌ [verificationCompleted] Firebase Auth error: ${e.code} - ${e.message}',
            );
            onFailed(e);
          } catch (e) {
            print('❌ [verificationCompleted] Unknown error: $e');
            print('🔍 [verificationCompleted] Error details: ${e.toString()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ [verificationFailed] Failed: ${e.code} - ${e.message}');
          onFailed(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          print('📨 [codeSent] OTP code sent successfully');
          print('🆔 VerificationId: $verificationId');
          print('🔄 ResendToken: $resendToken');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ [codeAutoRetrievalTimeout] Auto-retrieval timed out');
          print('🆔 VerificationId: $verificationId');
          _verificationId = verificationId;
        },
      );
      print('✅ [sendOtp] verifyPhoneNumber call completed successfully');
    } catch (e) {
      print('❌ [sendOtp] Unexpected error: $e');
      print('🔍 [sendOtp] Error details: ${e.toString()}');
      print('📚 [sendOtp] Stack trace: ${StackTrace.current}');
      onFailed(
        FirebaseAuthException(code: 'send_failed', message: e.toString()),
      );
    }
  }

  Future<User?> verifyOtp({
    required String smsCode,
    String? verificationIdOverride,
  }) async {
    print('🔵 [verifyOtp] Starting OTP verification');
    print('📝 SMS Code: $smsCode');
    print('🆔 VerificationId Override: ${verificationIdOverride ?? 'null'}');
    print('🔑 Stored VerificationId: $_verificationId');

    final verificationId = verificationIdOverride ?? _verificationId;
    if (verificationId == null) {
      print('❌ [verifyOtp] No verification ID found');
      throw FirebaseAuthException(
        code: 'missing-verification-id',
        message: 'No OTP was requested yet. Please request a code first.',
      );
    }

    print('✅ [verifyOtp] Using verificationId: $verificationId');

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    try {
      print('🔄 [verifyOtp] Attempting to sign in with credential');
      await _firebaseAuth.signInWithCredential(credential);
      print('✅ [verifyOtp] Sign in successful');

      final user = _firebaseAuth.currentUser;
      if (user != null) {
        print('👤 [verifyOtp] User found:');
        print('   UID: ${user.uid}');
        print('   Phone: ${user.phoneNumber}');
        print('   Is Anonymous: ${user.isAnonymous}');
        print('   Provider Data: ${user.providerData}');
        print('   Metadata: ${user.metadata}');
        return user;
      } else {
        print('⚠️ [verifyOtp] No user found after sign in');
        return null;
      }
    } catch (e) {
      print('❌ [verifyOtp] Error during sign in: $e');
      print('🔍 [verifyOtp] Error details: ${e.toString()}');
      print('📚 [verifyOtp] Stack trace: ${StackTrace.current}');

      // If there's an error, check if user is already signed in
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser != null) {
        print('⚠️ [verifyOtp] User is already signed in despite error');
        print('👤 User: ${currentUser.uid}');
        return currentUser;
      }
      rethrow;
    }
  }

  Future<void> signOut() {
    print('🔵 [signOut] Signing out user');
    return _firebaseAuth.signOut();
  }

  User? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      print('🔵 [currentUser] Current user: ${user.uid}');
    } else {
      print('🔵 [currentUser] No user currently signed in');
    }
    return user;
  }

  Stream<User?> get authStateChanges {
    print('🔵 [authStateChanges] Subscribing to auth state changes');
    return _firebaseAuth.authStateChanges();
  }
}
