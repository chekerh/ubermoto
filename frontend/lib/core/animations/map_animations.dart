import 'package:flutter/material.dart';
import '../map/map_controller.dart';
import '../map/types.dart';

/// Utilities for smooth map camera animations
class MapAnimations {
  /// Default animation duration for smooth camera movements
  static const Duration defaultDuration = Duration(milliseconds: 800);

  /// Animate camera to a specific location with smooth movement
  static Future<void> animateToLocation(
    MapController controller,
    MapPoint location, {
    double zoom = 15.0,
    Duration? duration,
    Curve curve = Curves.easeInOutCubic,
  }) async {
    await controller.animateToLocation(
      location,
      zoom: zoom,
      duration: duration ?? defaultDuration,
    );
  }

  /// Animate camera to fit bounds with padding
  static Future<void> animateToBounds(
    MapController controller,
    MapBounds bounds, {
    double padding = 50.0,
    Duration? duration,
    Curve curve = Curves.easeInOutCubic,
  }) async {
    await controller.animateToBounds(
      bounds,
      padding: padding,
      duration: duration ?? defaultDuration,
    );
  }

  /// Smoothly move camera following a location (for driver tracking)
  static Future<void> followLocation(
    MapController controller,
    MapPoint location, {
    double zoom = 16.0,
    Duration? duration,
    Curve curve = Curves.easeInOutCubic,
  }) async {
    await controller.followLocation(
      location,
      zoom: zoom,
      duration: duration ?? defaultDuration,
    );
  }
}
