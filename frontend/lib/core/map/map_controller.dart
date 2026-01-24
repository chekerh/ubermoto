import 'types.dart';

/// Abstract interface for map controller operations
/// Allows UI to work with any map provider (Google Maps, MapLibre, etc.)
abstract class MapController {
  /// Animate camera to a specific location
  Future<void> animateToLocation(
    MapPoint location, {
    double zoom = 15.0,
    Duration? duration,
  });

  /// Animate camera to fit bounds with padding
  Future<void> animateToBounds(
    MapBounds bounds, {
    double padding = 50.0,
    Duration? duration,
  });

  /// Smoothly move camera following a location (for driver tracking)
  Future<void> followLocation(
    MapPoint location, {
    double zoom = 16.0,
    Duration? duration,
  });

  /// Get current map center point
  MapPoint? getCurrentCenter();

  /// Get current zoom level
  double? getCurrentZoom();

  /// Move camera instantly (without animation)
  Future<void> moveToLocation(
    MapPoint location, {
    double zoom = 15.0,
  });
}
