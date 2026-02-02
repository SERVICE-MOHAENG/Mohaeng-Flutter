import 'package:mohaeng_app_service/features/main/data/model/pagination_models.dart';

class BlogsResponse {
  const BlogsResponse({required this.blogs, required this.meta});

  final List<BlogResponse> blogs;
  final PaginationMeta meta;

  factory BlogsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;

    final blogsRaw = payload['blogs'];
    final blogsList = blogsRaw is List
        ? blogsRaw
              .whereType<Map<String, dynamic>>()
              .map(BlogResponse.fromJson)
              .toList()
        : const <BlogResponse>[];

    return BlogsResponse(
      blogs: blogsList,
      meta: PaginationMeta.fromJson(payload),
    );
  }

  Map<String, dynamic> toJson() {
    return {'blogs': blogs.map((e) => e.toJson()).toList(), ...meta.toJson()};
  }
}

class BlogResponse {
  const BlogResponse({
    this.id,
    this.title,
    this.description,
    this.countryCode,
    this.thumbnailUrl,
    this.likeCount,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String? title;
  final String? description;
  final String? countryCode;
  final String? thumbnailUrl;
  final int? likeCount;
  final List<String> tags;

  /// ISO8601 string.
  final String? createdAt;

  /// ISO8601 string.
  final String? updatedAt;

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];

    return BlogResponse(
      id: _readIntNullable(json['id'] ?? json['blogId']),
      title: _readStringNullable(json['title']),
      description: _readStringNullable(
        json['description'] ?? json['summary'] ?? json['content'],
      ),
      countryCode: _readStringNullable(json['countryCode']),
      thumbnailUrl: _readStringNullable(
        json['thumbnailUrl'] ?? json['imageUrl'] ?? json['thumbnail'],
      ),
      likeCount: _readIntNullable(json['likeCount'] ?? json['likes']),
      tags: _readStringList(tagsRaw),
      createdAt: _readStringNullable(json['createdAt']),
      updatedAt: _readStringNullable(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'countryCode': countryCode,
      'thumbnailUrl': thumbnailUrl,
      'likeCount': likeCount,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

List<String> _readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((e) => e is String ? e : e?.toString())
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}
