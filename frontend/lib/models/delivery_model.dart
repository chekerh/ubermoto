import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'delivery_model.g.dart';

enum DeliveryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

@JsonSerializable()
class DeliveryModel extends Equatable {
  final String id;
  final String pickupLocation;
  final String deliveryAddress;
  final String deliveryType;
  final DeliveryStatus status;
  final String? userId;
  final String? driverId;
  final String? motorcycleId;
  final double? distance;
  final double? estimatedCost;
  final double? actualCost;
  final int? estimatedTime;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const DeliveryModel({
    required this.id,
    required this.pickupLocation,
    required this.deliveryAddress,
    required this.deliveryType,
    required this.status,
    this.userId,
    this.driverId,
    this.motorcycleId,
    this.distance,
    this.estimatedCost,
    this.actualCost,
    this.estimatedTime,
    required this.createdAt,
    this.updatedAt,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) =>
      _$DeliveryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeliveryModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        pickupLocation,
        deliveryAddress,
        deliveryType,
        status,
        userId,
        driverId,
        motorcycleId,
        distance,
        estimatedCost,
        actualCost,
        estimatedTime,
        createdAt,
        updatedAt,
      ];
}
