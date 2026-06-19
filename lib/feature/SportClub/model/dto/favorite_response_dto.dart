class FavoriteResponseDto {
  final int sportClubId;
  final bool isFavorited;
  final int favoriteCount;
  final String message;

  FavoriteResponseDto({
    required this.sportClubId,
    required this.isFavorited,
    required this.favoriteCount,
    required this.message,
  });

  factory FavoriteResponseDto.fromJson(Map<String, dynamic> json) {
    return FavoriteResponseDto(
      sportClubId: json['sport_club_id'] ?? 0,
      isFavorited: json['is_favorited'] ?? false,
      favoriteCount: json['favorite_count'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}
