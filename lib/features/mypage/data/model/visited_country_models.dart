import 'package:mohaeng_app_service/features/mypage/data/model/pagination_models.dart';

class VisitedCountryItemsResponse {
  const VisitedCountryItemsResponse({required this.items, required this.meta});

  final List<VisitedCountryResponse> items;
  final PaginationMeta meta;

  factory VisitedCountryItemsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;

    final itemsRaw = payload['items'];
    final items = itemsRaw is List
        ? itemsRaw
              .whereType<Map<String, dynamic>>()
              .map(VisitedCountryResponse.fromJson)
              .toList()
        : const <VisitedCountryResponse>[];

    return VisitedCountryItemsResponse(
      items: items,
      meta: PaginationMeta.fromJson(payload),
    );
  }

  Map<String, dynamic> toJson() {
    return {'items': items.map((e) => e.toJson()).toList(), ...meta.toJson()};
  }
}

class VisitedCountryResponse {
  const VisitedCountryResponse({
    this.id,
    this.countryName,
    this.visitDate,
    this.createdAt,
  });

  final String? id;
  final String? countryName;

  /// YYYY-MM-DD
  final String? visitDate;

  /// ISO8601 string.
  final String? createdAt;

  factory VisitedCountryResponse.fromJson(Map<String, dynamic> json) {
    return VisitedCountryResponse(
      id: _readStringNullable(json['id']),
      countryName: _readStringNullable(json['countryName']),
      visitDate: _readStringNullable(json['visitDate']),
      createdAt: _readStringNullable(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'countryName': countryName,
      'visitDate': visitDate,
      'createdAt': createdAt,
    };
  }
}

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
