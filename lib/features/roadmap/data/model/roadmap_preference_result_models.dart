import 'package:flutter/foundation.dart';

@immutable
class RoadmapPreferenceResultItem {
  const RoadmapPreferenceResultItem({
    required this.regionName,
    this.description,
    this.imageUrl,
    this.regionId,
    this.likeCount,
    this.isLiked,
  });

  final String regionName;
  final Object? description;
  final Object? imageUrl;
  final Object? regionId;
  final int? likeCount;
  final bool? isLiked;

  factory RoadmapPreferenceResultItem.fromJson(Map<String, dynamic> json) {
    return RoadmapPreferenceResultItem(
      regionName:
          _readStringValue(json, keys: const ['regionName', 'region_name']) ??
          '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      regionId: json['regionId'] ?? json['region_id'],
      likeCount: _readIntValue(
        json,
        keys: const ['likeCount', 'like_count', 'likes'],
      ),
      isLiked: _readBoolValue(
        json,
        keys: const ['isLiked', 'is_liked', 'liked'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'regionName': regionName,
      'description': description,
      'imageUrl': imageUrl,
      'regionId': regionId,
      'likeCount': likeCount,
      'isLiked': isLiked,
    };
  }
}

String? _readStringValue(
  Map<String, dynamic> json, {
  required List<String> keys,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

int? _readIntValue(Map<String, dynamic> json, {required List<String> keys}) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
  }
  return null;
}

bool? _readBoolValue(Map<String, dynamic> json, {required List<String> keys}) {
  for (final key in keys) {
    final value = json[key];
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
  }
  return null;
}
