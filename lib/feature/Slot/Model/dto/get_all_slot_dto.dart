import '../slot_model.dart';

class GetAllSlotsDto {
  final List<SlotModel> data;
  final int total;
  final int page;
  final int limit;

  GetAllSlotsDto({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory GetAllSlotsDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? items = json['data'] ?? json['items'] ?? json;

    return GetAllSlotsDto(
      data: items != null
          ? items.map((item) => SlotModel.fromJson(item)).toList()
          : [],
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
    };
  }
}
