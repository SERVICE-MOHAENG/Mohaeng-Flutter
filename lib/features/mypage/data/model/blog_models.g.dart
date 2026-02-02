// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BlogsResponse _$BlogsResponseFromJson(Map<String, dynamic> json) =>
    BlogsResponse(
      blogs: _readBlogsList(json['blogs']),
      page: _readPageInt(json['page']),
      limit: _readLimitInt(json['limit']),
      total: _readTotalInt(json['total']),
      totalPages: _readTotalPagesInt(json['totalPages']),
    );

Map<String, dynamic> _$BlogsResponseToJson(BlogsResponse instance) =>
    <String, dynamic>{
      'blogs': _writeBlogsList(instance.blogs),
      'page': _writeInt(instance.page),
      'limit': _writeInt(instance.limit),
      'total': _writeInt(instance.total),
      'totalPages': _writeInt(instance.totalPages),
    };

BlogItemsResponse _$BlogItemsResponseFromJson(Map<String, dynamic> json) =>
    BlogItemsResponse(
      items: _readBlogsList(json['items']),
      page: _readPageInt(json['page']),
      limit: _readLimitInt(json['limit']),
      total: _readTotalInt(json['total']),
      totalPages: _readTotalPagesInt(json['totalPages']),
    );

Map<String, dynamic> _$BlogItemsResponseToJson(BlogItemsResponse instance) =>
    <String, dynamic>{
      'items': _writeBlogsList(instance.items),
      'page': _writeInt(instance.page),
      'limit': _writeInt(instance.limit),
      'total': _writeInt(instance.total),
      'totalPages': _writeInt(instance.totalPages),
    };

BlogResponse _$BlogResponseFromJson(Map<String, dynamic> json) => BlogResponse(
  id: _readIntNullable(json['id']),
  title: _readStringNullable(json['title']),
  description: _readStringNullable(json['description']),
  countryCode: _readStringNullable(json['countryCode']),
  thumbnailUrl: _readStringNullable(json['thumbnailUrl']),
  likeCount: _readIntNullable(json['likeCount']),
  tags: json['tags'] == null ? const [] : _readStringList(json['tags']),
  createdAt: _readStringNullable(json['createdAt']),
  updatedAt: _readStringNullable(json['updatedAt']),
);

Map<String, dynamic> _$BlogResponseToJson(BlogResponse instance) =>
    <String, dynamic>{
      'id': _writeIntNullable(instance.id),
      'title': _writeStringNullable(instance.title),
      'description': _writeStringNullable(instance.description),
      'countryCode': _writeStringNullable(instance.countryCode),
      'thumbnailUrl': _writeStringNullable(instance.thumbnailUrl),
      'likeCount': _writeIntNullable(instance.likeCount),
      'tags': _writeStringList(instance.tags),
      'createdAt': _writeStringNullable(instance.createdAt),
      'updatedAt': _writeStringNullable(instance.updatedAt),
    };
