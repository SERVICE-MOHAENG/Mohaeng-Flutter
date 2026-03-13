class UserSummaryResponse {
  const UserSummaryResponse({required this.profile, required this.stats});

  final UserSummaryProfile profile;
  final UserSummaryStats stats;

  factory UserSummaryResponse.fromJson(Map<String, dynamic> json) {
    return UserSummaryResponse(
      profile: UserSummaryProfile.fromJson(
        _asStringKeyedMap(json['profile']) ?? const <String, dynamic>{},
      ),
      stats: UserSummaryStats.fromJson(
        _asStringKeyedMap(json['stats']) ?? const <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'stats': stats.toJson(),
  };
}

class UserSummaryProfile {
  const UserSummaryProfile({this.id, this.name, this.email, this.profileImage});

  final String? id;
  final String? name;
  final String? email;
  final Object? profileImage;

  String? get profileImageUrl => _extractImageUrl(profileImage);

  factory UserSummaryProfile.fromJson(Map<String, dynamic> json) {
    return UserSummaryProfile(
      id: _readStringNullable(json['id']),
      name: _readStringNullable(json['name']),
      email: _readStringNullable(json['email']),
      profileImage: _normalizeJsonValue(json['profileImage']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profileImage': _normalizeJsonValue(profileImage),
  };
}

class UserSummaryStats {
  const UserSummaryStats({
    this.createdRoadmaps = 0,
    this.visitedCountries = 0,
    this.writtenBlogs = 0,
    this.likedRegions = 0,
  });

  final int createdRoadmaps;
  final int visitedCountries;
  final int writtenBlogs;
  final int likedRegions;

  factory UserSummaryStats.fromJson(Map<String, dynamic> json) {
    return UserSummaryStats(
      createdRoadmaps: _readIntWithFallback(json['createdRoadmaps'], 0),
      visitedCountries: _readIntWithFallback(json['visitedCountries'], 0),
      writtenBlogs: _readIntWithFallback(json['writtenBlogs'], 0),
      likedRegions: _readIntWithFallback(json['likedRegions'], 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'createdRoadmaps': createdRoadmaps,
    'visitedCountries': visitedCountries,
    'writtenBlogs': writtenBlogs,
    'likedRegions': likedRegions,
  };
}

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? fallback;
  return fallback;
}

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final normalized = value.toString().trim();
  return normalized.isEmpty ? null : normalized;
}

String? _extractImageUrl(Object? value) {
  final candidate = _extractReadableText(value);
  if (candidate == null || candidate.isEmpty) return null;

  final uri = Uri.tryParse(candidate);
  if (uri == null || !uri.hasScheme) return null;
  return candidate;
}

String? _extractReadableText(Object? value) {
  if (value == null) return null;

  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
      return null;
    }
    return normalized;
  }

  if (value is List) {
    for (final item in value) {
      final nested = _extractReadableText(item);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  if (value is Map) {
    const preferredKeys = <String>[
      'url',
      'imageUrl',
      'downloadUrl',
      'src',
      'path',
      'value',
    ];

    for (final key in preferredKeys) {
      final nested = _extractReadableText(value[key]);
      if (nested != null) {
        return nested;
      }
    }

    for (final nestedValue in value.values) {
      final nested = _extractReadableText(nestedValue);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  final normalized = value.toString().trim();
  if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
    return null;
  }
  return normalized;
}

Map<String, dynamic>? _asStringKeyedMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map<String, dynamic>(
      (key, nestedValue) =>
          MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
    );
  }
  return null;
}

Object? _normalizeJsonValue(Object? value) {
  if (value is Map) {
    return value.map<String, dynamic>(
      (key, nestedValue) =>
          MapEntry(key.toString(), _normalizeJsonValue(nestedValue)),
    );
  }
  if (value is List) {
    return value.map<Object?>((item) => _normalizeJsonValue(item)).toList();
  }
  return value;
}
