/// Provider-agnostic map types to replace Google Maps types

/// Represents a geographic point (replaces LatLng)
class MapPoint {
  final double lat;
  final double lng;

  const MapPoint({
    required this.lat,
    required this.lng,
  });

  /// Create from latitude and longitude
  factory MapPoint.fromLatLng(double lat, double lng) {
    return MapPoint(lat: lat, lng: lng);
  }

  /// Convert to MapLibre format [lng, lat]
  List<double> toMapLibreCoordinates() {
    return [lng, lat];
  }

  /// Convert from MapLibre format [lng, lat]
  factory MapPoint.fromMapLibreCoordinates(List<double> coordinates) {
    return MapPoint(lat: coordinates[1], lng: coordinates[0]);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPoint &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;

  @override
  String toString() => 'MapPoint(lat: $lat, lng: $lng)';
}

/// Represents geographic bounds (replaces LatLngBounds)
class MapBounds {
  final MapPoint southwest;
  final MapPoint northeast;

  const MapBounds({
    required this.southwest,
    required this.northeast,
  });

  /// Create bounds from a list of points
  factory MapBounds.fromPoints(List<MapPoint> points) {
    if (points.isEmpty) {
      throw ArgumentError('Points list cannot be empty');
    }

    double minLat = points[0].lat;
    double maxLat = points[0].lat;
    double minLng = points[0].lng;
    double maxLng = points[0].lng;

    for (final point in points) {
      minLat = minLat < point.lat ? minLat : point.lat;
      maxLat = maxLat > point.lat ? maxLat : point.lat;
      minLng = minLng < point.lng ? minLng : point.lng;
      maxLng = maxLng > point.lng ? maxLng : point.lng;
    }

    return MapBounds(
      southwest: MapPoint(lat: minLat, lng: minLng),
      northeast: MapPoint(lat: maxLat, lng: maxLng),
    );
  }

  /// Get center point of bounds
  MapPoint get center {
    return MapPoint(
      lat: (southwest.lat + northeast.lat) / 2,
      lng: (southwest.lng + northeast.lng) / 2,
    );
  }

  @override
  String toString() =>
      'MapBounds(southwest: $southwest, northeast: $northeast)';
}

/// Represents camera position
class MapCameraPosition {
  final MapPoint target;
  final double zoom;
  final double? bearing;
  final double? tilt;

  const MapCameraPosition({
    required this.target,
    required this.zoom,
    this.bearing,
    this.tilt,
  });

  @override
  String toString() =>
      'MapCameraPosition(target: $target, zoom: $zoom, bearing: $bearing, tilt: $tilt)';
}
