class ChangePasswordRequestDto {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequestDto({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      "current_password": currentPassword,
      "new_password": newPassword,
      "confirm_password": confirmPassword,
    };
  }

  factory ChangePasswordRequestDto.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequestDto(
      currentPassword: json['current_password'] ?? '',
      newPassword: json['new_password'] ?? '',
      confirmPassword: json['confirm_password'] ?? '',
    );
  }
}
