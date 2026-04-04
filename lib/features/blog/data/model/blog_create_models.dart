class CreateBlogRequest {
  const CreateBlogRequest({
    required this.travelCourseId,
    required this.title,
    required this.content,
    this.imageUrls = const <String>[],
    this.tags = const <String>[],
    this.isPublic = true,
  });

  final String travelCourseId;
  final String title;
  final String content;
  final List<String> imageUrls;
  final List<String> tags;
  final bool isPublic;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'travelCourseId': travelCourseId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'tags': tags,
      'isPublic': isPublic,
    };
  }
}

class CreatedBlogResponse {
  const CreatedBlogResponse({
    this.id,
    this.travelCourseId,
    this.title,
    this.content,
    this.imageUrl,
    this.imageUrls = const <String>[],
    this.tags = const <String>[],
    this.isPublic,
    this.viewCount,
    this.likeCount,
    this.createdAt,
    this.updatedAt,
    this.userId,
    this.userName,
    this.isLiked,
  });

  final String? id;
  final String? travelCourseId;
  final String? title;
  final String? content;
  final String? imageUrl;
  final List<String> imageUrls;
  final List<String> tags;
  final bool? isPublic;
  final int? viewCount;
  final int? likeCount;
  final String? createdAt;
  final String? updatedAt;
  final String? userId;
  final String? userName;
  final bool? isLiked;

  factory CreatedBlogResponse.fromJson(Map<String, dynamic> json) {
    final payload = <String, dynamic>{...json};

    _assignFirstNonEmpty(payload, 'id', [payload['blogId']]);
    _assignFirstNonEmpty(payload, 'travelCourseId', [
      payload['travel_course_id'],
      payload['courseId'],
    ]);
    _assignFirstNonEmpty(payload, 'imageUrl', [
      payload['thumbnailUrl'],
      payload['thumbnail_url'],
    ]);
    if (payload['tags'] is! List && payload['hashTags'] is List) {
      payload['tags'] = payload['hashTags'];
    }

    return CreatedBlogResponse(
      id: _readStringNullable(payload['id']),
      travelCourseId: _readStringNullable(payload['travelCourseId']),
      title: _readStringNullable(payload['title']),
      content: _readStringNullable(payload['content']),
      imageUrl: _readStringNullable(payload['imageUrl']),
      imageUrls: _readStringList(payload['imageUrls']),
      tags: _readStringList(payload['tags']),
      isPublic: _readBoolNullable(payload['isPublic']),
      viewCount: _readIntNullable(payload['viewCount']),
      likeCount: _readIntNullable(payload['likeCount']),
      createdAt: _readStringNullable(payload['createdAt']),
      updatedAt: _readStringNullable(payload['updatedAt']),
      userId: _readStringNullable(payload['userId']),
      userName: _readStringNullable(payload['userName']),
      isLiked: _readBoolNullable(payload['isLiked']),
    );
  }
}

void _assignFirstNonEmpty(
  Map<String, dynamic> target,
  String key,
  List<Object?> candidates,
) {
  final current = target[key];
  if (_readStringNullable(current) != null) return;

  for (final candidate in candidates) {
    if (_readStringNullable(candidate) != null) {
      target[key] = candidate;
      return;
    }
  }
}

String? _readStringNullable(Object? value) {
  if (value == null || value is Map || value is List) return null;
  final resolved = value.toString().trim();
  return resolved.isEmpty ? null : resolved;
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((entry) => entry?.toString().trim())
      .whereType<String>()
      .where((entry) => entry.isNotEmpty)
      .toList(growable: false);
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

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}
