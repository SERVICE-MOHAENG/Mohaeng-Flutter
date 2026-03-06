import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'country_region_models.g.dart';

@immutable
@JsonSerializable()
class CountryRegionsResponse {
  const CountryRegionsResponse({this.regions = const <CountryRegionModel>[]});

  @JsonKey(fromJson: _readRegions)
  final List<CountryRegionModel> regions;

  factory CountryRegionsResponse.fromJson(Map<String, dynamic> json) =>
      _$CountryRegionsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CountryRegionsResponseToJson(this);
}

@immutable
@JsonSerializable()
class CountryRegionModel {
  const CountryRegionModel({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  final String id;
  final String name;

  /// API 응답 스펙이 고정되지 않아 어떤 JSON 타입이 와도 보존한다.
  @JsonKey(fromJson: _readUnknownJson, toJson: _writeUnknownJson)
  final Object? imageUrl;

  factory CountryRegionModel.fromJson(Map<String, dynamic> json) =>
      _$CountryRegionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CountryRegionModelToJson(this);
}

List<CountryRegionModel> _readRegions(Object? value) {
  if (value is! List) return const <CountryRegionModel>[];

  final regions = <CountryRegionModel>[];
  for (final item in value) {
    final normalized = _normalizeAsJsonMap(item);
    if (normalized == null) continue;
    regions.add(CountryRegionModel.fromJson(normalized));
  }
  return regions;
}

Object? _readUnknownJson(Object? value) {
  if (value == null) return null;
  if (value is String || value is num || value is bool) return value;
  if (value is Map || value is List) return _normalizeJsonValue(value);
  return value.toString();
}

Object? _writeUnknownJson(Object? value) => value;

Object? _normalizeJsonValue(Object? value) {
  if (value == null) return null;
  if (value is String || value is num || value is bool) return value;
  if (value is Map) return _normalizeJsonMap(value);
  if (value is List) {
    return value.map<Object?>((item) => _normalizeJsonValue(item)).toList();
  }
  return value.toString();
}

Map<String, dynamic>? _normalizeAsJsonMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return _normalizeJsonMap(value);
  return null;
}

Map<String, dynamic> _normalizeJsonMap(Map value) {
  final result = <String, dynamic>{};

  for (final entry in value.entries) {
    final key = entry.key?.toString();
    if (key == null || key.isEmpty) continue;
    result[key] = _normalizeJsonValue(entry.value);
  }

  return result;
}
