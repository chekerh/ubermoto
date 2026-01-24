import 'package:flutter/material.dart';
import 'types.dart';

/// Abstract route interface for map-agnostic route operations
abstract class MapRoute {
  String get id;
  List<MapPoint> get points;
  Color get color;
  double get width;
}

/// Route data class
class RouteData {
  final String id;
  final List<MapPoint> points;
  final Color color;
  final double width;
  final List<double>? pattern; // For dashed lines [dashLength, gapLength]

  const RouteData({
    required this.id,
    required this.points,
    required this.color,
    this.width = 4.0,
    this.pattern,
  });
}
