class LoginRequestDto {
  final String? email;
  final String? phone;
  final String? username;
  final String password;

  LoginRequestDto({
    this.email,
    this.phone,
    this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (username != null) 'username': username,
      'password': password,
    };
  }

  // Factory method to create from input with phone normalization
  factory LoginRequestDto.fromInput(String input, String password) {
    // Check if email
    final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(input);

    if (isEmail) {
      return LoginRequestDto(email: input, password: password);
    }

    // Check if phone number (with +855, 855, or 0)
    final isPhoneNumber = RegExp(r'^(\+855|855|0)?[0-9]{8,9}$').hasMatch(input);

    if (isPhoneNumber) {
      final normalizedPhone = _normalizePhoneNumber(input);
      return LoginRequestDto(phone: normalizedPhone, password: password);
    }

    // Otherwise treat as username
    return LoginRequestDto(username: input, password: password);
  }

  static String _normalizePhoneNumber(String phone) {
    // Remove all non-digit characters
    String cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it starts with 855
    if (cleaned.startsWith('855')) {
      return '+$cleaned';
    }
    // Check if it starts with 0 (local format)
    else if (cleaned.startsWith('0')) {
      // Remove leading 0 and add +855
      String withoutZero = cleaned.substring(1);
      return '+855$withoutZero';
    }
    // Assume it's a local number without 0
    else {
      return '+855$cleaned';
    }
  }
}
