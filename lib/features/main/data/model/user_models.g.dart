// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainUserResponse _$MainUserResponseFromJson(Map<String, dynamic> json) =>
    MainUserResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      profileImage: json['profileImage'] as String?,
      visitedCountries: _readIntNullable(json['visitedCountries']),
      isActivate: _readBoolNullable(json['isActivate']),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$MainUserResponseToJson(MainUserResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'profileImage': instance.profileImage,
      'visitedCountries': _writeIntNullable(instance.visitedCountries),
      'isActivate': _writeBoolNullable(instance.isActivate),
      'createdAt': instance.createdAt,
    };
