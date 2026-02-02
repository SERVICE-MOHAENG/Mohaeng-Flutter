import 'package:json_annotation/json_annotation.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/pagination_models.dart';

part 'blog_models.g.dart';

@JsonSerializable(explicitToJson: true)
class BlogsResponse {
  const BlogsResponse({
    required this.blogs,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @JsonKey(fromJson: _readBlogsList, toJson: _writeBlogsList)
  final List<BlogResponse> blogs;

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

  factory BlogsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;
    return _$BlogsResponseFromJson(payload);
  }

  Map<String, dynamic> toJson() => _$BlogsResponseToJson(this);
}

/// Used by `/blogs/me/likes` response.
@JsonSerializable(explicitToJson: true)
class BlogItemsResponse {
  const BlogItemsResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @JsonKey(fromJson: _readBlogsList, toJson: _writeBlogsList)
  final List<BlogResponse> items;

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

  factory BlogItemsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;
    return _$BlogItemsResponseFromJson(payload);
  }

  Map<String, dynamic> toJson() => _$BlogItemsResponseToJson(this);
}

@JsonSerializable()
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

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? id;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? title;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? description;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? countryCode;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? thumbnailUrl;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? likeCount;

  @JsonKey(fromJson: _readStringList, toJson: _writeStringList)
  final List<String> tags;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? createdAt;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? updatedAt;

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};

    if (!normalized.containsKey('id') && normalized['blogId'] != null) {
      normalized['id'] = normalized['blogId'];
    }
    if (!normalized.containsKey('description')) {
      normalized['description'] =
          normalized['summary'] ??
          normalized['content'] ??
          normalized['description'];
    }
    if (!normalized.containsKey('thumbnailUrl')) {
      normalized['thumbnailUrl'] =
          normalized['imageUrl'] ??
          normalized['thumbnail'] ??
          normalized['thumbnailUrl'];
    }
    if (!normalized.containsKey('likeCount') && normalized['likes'] != null) {
      normalized['likeCount'] = normalized['likes'];
    }

    return _$BlogResponseFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$BlogResponseToJson(this);
}

List<BlogResponse> _readBlogsList(Object? value) {
  if (value is! List) return const <BlogResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(BlogResponse.fromJson)
      .toList();
}

List<Map<String, dynamic>> _writeBlogsList(List<BlogResponse> value) =>
    value.map((e) => e.toJson()).toList();

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int _readPageInt(Object? value) => _readIntWithFallback(value, 1);

int _readLimitInt(Object? value) => _readIntWithFallback(value, 6);

int _readTotalInt(Object? value) => _readIntWithFallback(value, 0);

int _readTotalPagesInt(Object? value) => _readIntWithFallback(value, 0);

int _writeInt(int value) => value;

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int? _writeIntNullable(int? value) => value;

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

String? _writeStringNullable(String? value) => value;

List<String> _readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((e) => e is String ? e : e?.toString())
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

List<String> _writeStringList(List<String> value) => value;
