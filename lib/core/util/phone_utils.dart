// lib/core/utils/phone_utils.dart
class PhoneUtils {
  static String cleanPhoneNumber(String phoneNumber) {
    // Remove all spaces, dashes, parentheses, and other special characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // If the number starts with '0', replace with '+855'
    if (cleaned.startsWith('0')) {
      cleaned = '+855${cleaned.substring(1)}';
    }
    // If the number starts with '855' without '+', add '+'
    else if (cleaned.startsWith('855')) {
      cleaned = '+$cleaned';
    }
    // If the number starts with '+855' but has extra characters
    else if (cleaned.startsWith('+855')) {
      // Keep as is
    }
    // If the number doesn't start with '+', add '+855'
    else if (!cleaned.startsWith('+')) {
      // If it's less than 8 digits, it's incomplete
      if (cleaned.length < 8) {
        return cleaned; // Return as is, validation will catch it
      }
      cleaned = '+855$cleaned';
    }

    return cleaned;
  }

  static bool isValidPhoneNumber(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    // Must be +855 followed by 8-9 digits (total 12-13 characters)
    final regex = RegExp(r'^\+855[0-9]{8,9}$');
    return regex.hasMatch(cleaned);
  }

  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = cleanPhoneNumber(phoneNumber);
    // Return in E.164 format
    return cleaned;
  }
}
