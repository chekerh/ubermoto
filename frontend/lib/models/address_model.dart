import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel extends Equatable {
  final String id;
  final String userId;
  final String label;
  final String address;
  final String city;
  final String? postalCode;
  final Coordinates? coordinates;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.address,
    required this.city,
    this.postalCode,
    this.coordinates,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        userId,
        label,
        address,
        city,
        postalCode,
        coordinates,
        isDefault,
        createdAt,
        updatedAt,
      ];
}

@JsonSerializable()
class Coordinates extends Equatable {
  final double lat;
  final double lng;

  const Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);

  @override
  List<Object> get props => [lat, lng];
}
