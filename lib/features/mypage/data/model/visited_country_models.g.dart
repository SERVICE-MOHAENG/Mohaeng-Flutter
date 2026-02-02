// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visited_country_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitedCountryItemsResponse _$VisitedCountryItemsResponseFromJson(
  Map<String, dynamic> json,
) => VisitedCountryItemsResponse(
  items: _readVisitedCountriesList(json['items']),
  page: _readPageInt(json['page']),
  limit: _readLimitInt(json['limit']),
  total: _readTotalInt(json['total']),
  totalPages: _readTotalPagesInt(json['totalPages']),
);

Map<String, dynamic> _$VisitedCountryItemsResponseToJson(
  VisitedCountryItemsResponse instance,
) => <String, dynamic>{
  'items': _writeVisitedCountriesList(instance.items),
  'page': _writeInt(instance.page),
  'limit': _writeInt(instance.limit),
  'total': _writeInt(instance.total),
  'totalPages': _writeInt(instance.totalPages),
};

VisitedCountryResponse _$VisitedCountryResponseFromJson(
  Map<String, dynamic> json,
) => VisitedCountryResponse(
  id: json['id'] as String?,
  countryName: json['countryName'] as String?,
  visitDate: json['visitDate'] as String?,
  createdAt: json['createdAt'] as String?,
);

Map<String, dynamic> _$VisitedCountryResponseToJson(
  VisitedCountryResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'countryName': instance.countryName,
  'visitDate': instance.visitDate,
  'createdAt': instance.createdAt,
};
