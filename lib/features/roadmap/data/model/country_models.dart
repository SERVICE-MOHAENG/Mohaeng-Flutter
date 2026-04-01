import 'package:flutter/foundation.dart';

@immutable
class CountriesResponse {
  const CountriesResponse({this.countries = const <CountryModel>[]});

  final List<CountryModel> countries;

  factory CountriesResponse.fromJson(Map<String, dynamic> json) {
    return CountriesResponse(countries: _readCountries(json['countries']));
  }

  Map<String, dynamic> toJson() {
    return {
      'countries': countries.map((country) => country.toJson()).toList(),
    };
  }
}

@immutable
class CountryModel {
  const CountryModel({
    required this.id,
    required this.name,
    required this.code,
    required this.countryCode,
    required this.continent,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String code;
  final String countryCode;
  final String continent;
  final String? imageUrl;

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: _readString(_firstNonNull([
        json['id'],
        json['countryId'],
        json['country_id'],
      ])),
      name: _readString(_firstNonNull([
        json['name'],
        json['countryName'],
        json['country_name'],
      ])),
      code: _readString(_firstNonNull([
        json['code'],
        json['countryCode'],
        json['country_code'],
      ])),
      countryCode: _readString(_firstNonNull([
        json['countryCode'],
        json['country_code'],
        json['code'],
      ])),
      continent: _readString(_firstNonNull([
        json['continent'],
        json['continentName'],
        json['continent_name'],
      ])),
      imageUrl: _resolveImageUrl(_firstNonNull([
        json['imageUrl'],
        json['imageURL'],
        json['image_url'],
        json['image'],
        json['img'],
        json['thumbnailUrl'],
        json['thumbnail_url'],
        json['originalUrl'],
        json['original_url'],
      ])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'countryCode': countryCode,
      'continent': continent,
      'imageUrl': imageUrl,
    };
  }
}

List<CountryModel> _readCountries(Object? value) {
  if (value is! List) return const <CountryModel>[];

  final countries = <CountryModel>[];
  for (final item in value) {
    final normalized = _normalizeAsJsonMap(item);
    if (normalized == null) continue;
    countries.add(CountryModel.fromJson(normalized));
  }
  return countries;
}

String _readString(Object? value) => value?.toString().trim() ?? '';

Object? _firstNonNull(List<Object?> values) {
  for (final value in values) {
    if (value != null) return value;
  }
  return null;
}

String? _resolveImageUrl(Object? value) {
  final raw = _extractString(value);
  if (raw == null || raw.isEmpty) return null;

  final uri = Uri.tryParse(raw);
  if (uri != null && uri.hasScheme) return raw;

  if (raw.startsWith('/')) {
    return raw;
  }

  return raw;
}

String? _extractString(Object? value) {
  if (value == null) return null;
  if (value is String) return value.trim();
  if (value is num || value is bool) return value.toString().trim();
  if (value is Map) {
    const preferredKeys = [
      'url',
      'imageUrl',
      'imageURL',
      'image_url',
      'src',
      'path',
      'original',
      'originalUrl',
      'original_url',
      'large',
      'medium',
      'small',
      'thumbnail',
      'thumbnailUrl',
      'thumbnail_url',
      'fileUrl',
      'file_url',
    ];

    for (final key in preferredKeys) {
      final candidate = _extractString(value[key]);
      if (candidate != null && candidate.isNotEmpty) return candidate;
    }

    for (final entry in value.entries) {
      final candidate = _extractString(entry.value);
      if (candidate != null && candidate.isNotEmpty) return candidate;
    }
    return null;
  }
  if (value is List) {
    for (final item in value) {
      final candidate = _extractString(item);
      if (candidate != null && candidate.isNotEmpty) return candidate;
    }
    return null;
  }
  return value.toString().trim();
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
    final item = entry.value;
    if (item is Map) {
      result[key] = _normalizeJsonMap(item);
    } else if (item is List) {
      result[key] = item.map((e) => e is Map ? _normalizeJsonMap(e) : e).toList();
    } else {
      result[key] = item;
    }
  }

  return result;
}
