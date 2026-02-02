import 'package:json_annotation/json_annotation.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/pagination_models.dart';

part 'visited_country_models.g.dart';

@JsonSerializable(explicitToJson: true)
class VisitedCountryItemsResponse {
  const VisitedCountryItemsResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @JsonKey(
    fromJson: _readVisitedCountriesList,
    toJson: _writeVisitedCountriesList,
  )
  final List<VisitedCountryResponse> items;

  @JsonKey(fromJson: _readPageInt, toJson: _writeInt)
  final int page;

  @JsonKey(fromJson: _readLimitInt, toJson: _writeInt)
  final int limit;

  @JsonKey(fromJson: _readTotalInt, toJson: _writeInt)
  final int total;

  @JsonKey(fromJson: _readTotalPagesInt, toJson: _writeInt)
  final int totalPages;

  PaginationMeta get meta => PaginationMeta(
    page: page,
    limit: limit,
    total: total,
    totalPages: totalPages,
  );

  factory VisitedCountryItemsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;
    return _$VisitedCountryItemsResponseFromJson(payload);
  }

  Map<String, dynamic> toJson() => _$VisitedCountryItemsResponseToJson(this);
}

@JsonSerializable()
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

  factory VisitedCountryResponse.fromJson(Map<String, dynamic> json) =>
      _$VisitedCountryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$VisitedCountryResponseToJson(this);
}

List<VisitedCountryResponse> _readVisitedCountriesList(Object? value) {
  if (value is! List) return const <VisitedCountryResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(VisitedCountryResponse.fromJson)
      .toList();
}

List<Map<String, dynamic>> _writeVisitedCountriesList(
  List<VisitedCountryResponse> value,
) => value.map((e) => e.toJson()).toList();

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int _readPageInt(Object? value) => _readIntWithFallback(value, 1);

int _readLimitInt(Object? value) => _readIntWithFallback(value, 10);

int _readTotalInt(Object? value) => _readIntWithFallback(value, 0);

int _readTotalPagesInt(Object? value) => _readIntWithFallback(value, 0);

int _writeInt(int value) => value;
