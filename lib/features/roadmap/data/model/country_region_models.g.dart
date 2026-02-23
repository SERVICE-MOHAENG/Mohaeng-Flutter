// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'country_region_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountryRegionsResponse _$CountryRegionsResponseFromJson(
  Map<String, dynamic> json,
) => CountryRegionsResponse(
  regions: json['regions'] == null
      ? const <CountryRegionModel>[]
      : _readRegions(json['regions']),
);

Map<String, dynamic> _$CountryRegionsResponseToJson(
  CountryRegionsResponse instance,
) => <String, dynamic>{'regions': instance.regions};

CountryRegionModel _$CountryRegionModelFromJson(Map<String, dynamic> json) =>
    CountryRegionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: _readUnknownJson(json['imageUrl']),
    );

Map<String, dynamic> _$CountryRegionModelToJson(CountryRegionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': _writeUnknownJson(instance.imageUrl),
    };
