import 'package:flutter/material.dart';
import 'types.dart';

/// Abstract marker interface for map-agnostic marker operations
abstract class MapMarker {
  String get id;
  MapPoint get position;
  Color get color;
  double? get bearing;
}

/// Marker data class
class MarkerData {
  final String id;
  final MapPoint position;
  final Color color;
  final double? bearing;
  final VoidCallback? onTap;

  const MarkerData({
    required this.id,
    required this.position,
    required this.color,
    this.bearing,
    this.onTap,
  });
}
