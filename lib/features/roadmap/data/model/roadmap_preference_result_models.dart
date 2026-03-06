import 'package:flutter/foundation.dart';

@immutable
class RoadmapPreferenceResultItem {
  const RoadmapPreferenceResultItem({
    required this.regionName,
    this.description,
    this.imageUrl,
    this.regionId,
  });

  final String regionName;
  final Object? description;
  final Object? imageUrl;
  final Object? regionId;

  factory RoadmapPreferenceResultItem.fromJson(Map<String, dynamic> json) {
    return RoadmapPreferenceResultItem(
      regionName:
          _readStringValue(json, keys: const ['regionName', 'region_name']) ??
          '',
      description: json['description'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      regionId: json['regionId'] ?? json['region_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'regionName': regionName,
      'description': description,
      'imageUrl': imageUrl,
      'regionId': regionId,
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
