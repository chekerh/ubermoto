import 'dart:math' as math;
import '../map/types.dart';

/// Utility functions for map operations
class MapUtils {
  /// Calculate bounds that include all given points
  static MapBounds calculateBounds(List<MapPoint> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points[0].lat;
    double maxLat = points[0].lat;
    double minLng = points[0].lng;
    double maxLng = points[0].lng;

    for (final point in points) {
      minLat = math.min(minLat, point.lat);
      maxLat = math.max(maxLat, point.lat);
      minLng = math.min(minLng, point.lng);
      maxLng = math.max(maxLng, point.lng);
    }

    return MapBounds(
      southwest: MapPoint(lat: minLat, lng: minLng),
      northeast: MapPoint(lat: maxLat, lng: maxLng),
    );
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(MapPoint point1, MapPoint point2) {
    const double earthRadius = 6371; // km

    final double dLat = _toRadians(point2.lat - point1.lat);
    final double dLng = _toRadians(point2.lng - point1.lng);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(point1.lat)) *
            math.cos(_toRadians(point2.lat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Convert degrees to radians
  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }

  /// Check if a point is within bounds
  static bool isPointInBounds(MapPoint point, MapBounds bounds) {
    return point.lat >= bounds.southwest.lat &&
        point.lat <= bounds.northeast.lat &&
        point.lng >= bounds.southwest.lng &&
        point.lng <= bounds.northeast.lng;
  }

  /// Get center point of bounds
  static MapPoint getBoundsCenter(MapBounds bounds) {
    return bounds.center;
  }

  /// Calculate bearing (direction) from one point to another in degrees
  /// Returns bearing in degrees (0-360), where 0 is North, 90 is East, etc.
  /// Uses the initial bearing formula for great circle navigation
  static double calculateBearing(MapPoint from, MapPoint to) {
    final lat1 = _toRadians(from.lat);
    final lat2 = _toRadians(to.lat);
    final deltaLng = _toRadians(to.lng - from.lng);

    final y = math.sin(deltaLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

    final bearing = math.atan2(y, x);
    
    // Convert from radians to degrees and normalize to 0-360
    final bearingDegrees = _toDegrees(bearing);
    return (bearingDegrees + 360) % 360;
  }

  /// Convert radians to degrees
  static double _toDegrees(double radians) {
    return radians * (180 / math.pi);
  }
}
