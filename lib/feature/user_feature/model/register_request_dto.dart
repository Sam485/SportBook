class RegisterRequestDto {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterRequestDto({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': name,
      'email': email,
      'phone': phone,
      'password': password,
    };
  }

  factory RegisterRequestDto.fromInput(RegisterRequestDto register) {
    final normalizedPhone = _normalizePhoneNumber(register.phone);
    return RegisterRequestDto(
      name: register.name,
      email: register.email,
      phone: normalizedPhone,
      password: register.password,
    );
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
