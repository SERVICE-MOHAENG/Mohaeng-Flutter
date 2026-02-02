// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pagination_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      page: _readPageInt(json['page']),
      limit: _readLimitInt(json['limit']),
      total: _readTotalInt(json['total']),
      totalPages: _readTotalPagesInt(json['totalPages']),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'page': _writeInt(instance.page),
      'limit': _writeInt(instance.limit),
      'total': _writeInt(instance.total),
      'totalPages': _writeInt(instance.totalPages),
    };
