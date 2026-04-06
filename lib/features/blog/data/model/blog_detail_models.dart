class BlogDetailResponse {
  const BlogDetailResponse({
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

  List<String> get displayImageUrls {
    final primary = _readStringNullable(imageUrl);
    final urls = <String>[if (primary != null) primary, ...imageUrls];
    return urls.toSet().toList(growable: false);
  }

  factory BlogDetailResponse.fromJson(Map<String, dynamic> json) {
    final payload = <String, dynamic>{...json};

    _assignFirstNonEmpty(payload, 'id', <Object?>[payload['blogId']]);
    _assignFirstNonEmpty(payload, 'travelCourseId', <Object?>[
      payload['travel_course_id'],
      payload['courseId'],
      _readObjectField(payload['travelCourse'], const <String>['id']),
      _readObjectField(payload['travelCourseId'], const <String>['id']),
    ]);
    _assignFirstNonEmpty(payload, 'imageUrl', <Object?>[
      payload['thumbnailUrl'],
      payload['thumbnail_url'],
      _readObjectField(payload['imageUrl'], const <String>[
        'url',
        'imageUrl',
        'thumbnailUrl',
        'src',
      ]),
      _readObjectField(payload['image'], const <String>[
        'url',
        'imageUrl',
        'thumbnailUrl',
        'src',
      ]),
    ]);
    if (payload['tags'] is! List && payload['hashTags'] is List) {
      payload['tags'] = payload['hashTags'];
    }

    return BlogDetailResponse(
      id: _readStringNullable(payload['id']),
      travelCourseId: _readStringNullable(payload['travelCourseId']),
      title: _readStringNullable(payload['title']),
      content: _readStringNullable(payload['content']),
      imageUrl: _readStringNullable(payload['imageUrl']),
      imageUrls: _readImageUrlList(payload['imageUrls']),
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

  BlogDetailResponse copyWith({
    String? id,
    String? travelCourseId,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? imageUrls,
    List<String>? tags,
    bool? isPublic,
    int? viewCount,
    int? likeCount,
    String? createdAt,
    String? updatedAt,
    String? userId,
    String? userName,
    bool? isLiked,
  }) {
    return BlogDetailResponse(
      id: id ?? this.id,
      travelCourseId: travelCourseId ?? this.travelCourseId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      isPublic: isPublic ?? this.isPublic,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLiked: isLiked ?? this.isLiked,
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

String? _readObjectField(Object? value, List<String> candidateKeys) {
  if (value is! Map) return null;

  for (final key in candidateKeys) {
    final resolved = _readStringNullable(value[key]);
    if (resolved != null) {
      return resolved;
    }
  }

  return null;
}

String? _readStringNullable(Object? value) {
  if (value == null || value is List || value is Map) return null;
  final resolved = value.toString().trim();
  return resolved.isEmpty ? null : resolved;
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((entry) => _readStringNullable(entry))
      .whereType<String>()
      .toList(growable: false);
}

List<String> _readImageUrlList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((entry) {
        final direct = _readStringNullable(entry);
        if (direct != null) return direct;
        return _readObjectField(entry, const <String>[
          'url',
          'imageUrl',
          'thumbnailUrl',
          'src',
        ]);
      })
      .whereType<String>()
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
