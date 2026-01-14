import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'motorcycle_model.g.dart';

@JsonSerializable()
class MotorcycleModel extends Equatable {
  final String id;
  final String model;
  final String brand;
  final double fuelConsumption; // Liters per 100 km
  final String? engineType;
  final int? capacity;
  final int? year;

  const MotorcycleModel({
    required this.id,
    required this.model,
    required this.brand,
    required this.fuelConsumption,
    this.engineType,
    this.capacity,
    this.year,
  });

  factory MotorcycleModel.fromJson(Map<String, dynamic> json) =>
      _$MotorcycleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MotorcycleModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        model,
        brand,
        fuelConsumption,
        engineType,
        capacity,
        year,
      ];
}
