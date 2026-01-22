import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  @JsonKey(name: '_id', fromJson: _idFromJson)
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isVerified;
  final String? phoneNumber;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isVerified = false,
    this.phoneNumber,
    this.avatarUrl,
  });

  static String _idFromJson(dynamic json) {
    if (json is String) return json;
    if (json is Map && json.containsKey('\$oid')) return json['\$oid'] as String;
    return json.toString();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle both _id and id fields
    final jsonCopy = Map<String, dynamic>.from(json);
    if (jsonCopy.containsKey('_id') && !jsonCopy.containsKey('id')) {
      jsonCopy['id'] = jsonCopy['_id'].toString();
    }
    // Ensure role field exists (default to CUSTOMER if missing)
    if (!jsonCopy.containsKey('role')) {
      jsonCopy['role'] = 'CUSTOMER';
    }
    return _$UserModelFromJson(jsonCopy);
  }

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  List<Object?> get props => [id, email, name, role, isVerified, phoneNumber, avatarUrl];
}
