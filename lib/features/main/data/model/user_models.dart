import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
class MainUserResponse {
  const MainUserResponse({
    this.id,
    this.name,
    this.email,
    this.profileImage,
    this.isActivate,
    this.createdAt,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? profileImage;

  @JsonKey(fromJson: _readBoolNullable, toJson: _writeBoolNullable)
  final bool? isActivate;

  /// ISO8601 string.
  final String? createdAt;

  factory MainUserResponse.fromJson(Map<String, dynamic> json) =>
      _$MainUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MainUserResponseToJson(this);
}

bool? _readBoolNullable(Object? value) {
  if (value is bool) return value;
  if (value is String) {
    final lower = value.trim().toLowerCase();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  if (value is num) {
    if (value == 1) return true;
    if (value == 0) return false;
  }
  return null;
}

bool? _writeBoolNullable(bool? value) => value;
