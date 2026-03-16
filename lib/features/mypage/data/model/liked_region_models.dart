import 'package:mohaeng_app_service/features/mypage/data/model/pagination_models.dart';

class LikedRegionsResponse {
  const LikedRegionsResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  final List<LikedRegionResponse> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationMeta get meta => PaginationMeta(
    page: page,
    limit: limit,
    total: total,
    totalPages: totalPages,
  );

  factory LikedRegionsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;

    return LikedRegionsResponse(
      items: _readLikedRegionsList(payload['items']),
      page: _readIntWithFallback(payload['page'], 1),
      limit: _readIntWithFallback(payload['limit'], 10),
      total: _readIntWithFallback(payload['total'], 0),
      totalPages: _readIntWithFallback(payload['totalPages'], 0),
    );
  }
}

class LikedRegionResponse {
  const LikedRegionResponse({
    this.regionId,
    this.regionName,
    this.imageUrl,
    this.description,
    this.likeCount,
    this.isLiked,
  });

  final String? regionId;
  final String? regionName;
  final String? imageUrl;
  final String? description;
  final int? likeCount;
  final bool? isLiked;

  factory LikedRegionResponse.fromJson(Map<String, dynamic> json) {
    return LikedRegionResponse(
      regionId: _readStringNullable(json['regionId']),
      regionName: _readStringNullable(json['regionName']),
      imageUrl: _readStringNullable(json['imageUrl']),
      description: _readStringNullable(json['description']),
      likeCount: _readIntNullable(json['likeCount']),
      isLiked: _readBoolNullable(json['isLiked']),
    );
  }
}

List<LikedRegionResponse> _readLikedRegionsList(Object? value) {
  if (value is! List) return const <LikedRegionResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(LikedRegionResponse.fromJson)
      .toList();
}

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  if (value is Map || value is List) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

bool? _readBoolNullable(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}
