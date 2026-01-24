import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../core/map/types.dart';

/// OSRM routing service for calculating routes
class OSRMService {
  static const String _baseUrl = 'https://router.project-osrm.org';
  
  /// Route result containing geometry and metadata
  class RouteResult {
    final List<MapPoint> geometry;
    final double distance; // in meters
    final double duration; // in seconds
    final bool isFallback; // true if using straight-line fallback

    RouteResult({
      required this.geometry,
      required this.distance,
      required this.duration,
      this.isFallback = false,
    });
  }

  /// Get route between two points
  static Future<RouteResult> getRoute(
    MapPoint start,
    MapPoint end, {
    String profile = 'driving',
  }) async {
    try {
      // OSRM expects coordinates in [lng, lat] format
      final url = Uri.parse(
        '$_baseUrl/route/v1/$profile/${start.lng},${start.lat};${end.lng},${end.lat}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['code'] == 'Ok' && data['routes'] != null) {
          final routes = data['routes'] as List;
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final geometry = route['geometry'] as Map<String, dynamic>;
            final coordinates = geometry['coordinates'] as List;
            
            // Parse GeoJSON LineString coordinates
            final points = coordinates
                .map((coord) => MapPoint(
                      lat: (coord as List)[1] as double,
                      lng: coord[0] as double,
                    ))
                .toList();

            final distance = (route['distance'] as num).toDouble();
            final duration = (route['duration'] as num).toDouble();

            return RouteResult(
              geometry: points,
              distance: distance,
              duration: duration,
              isFallback: false,
            );
          }
        }
      }

      // Fallback to straight line if OSRM fails
      return _fallbackRoute(start, end);
    } catch (e) {
      // Fallback to straight line on error
      return _fallbackRoute(start, end);
    }
  }

  /// Fallback route (straight line) when OSRM is unavailable
  static RouteResult _fallbackRoute(MapPoint start, MapPoint end) {
    // Calculate straight-line distance
    final distance = _calculateDistance(start, end);
    
    // Estimate duration (assuming average speed of 30 km/h for motorcycles)
    const averageSpeedKmh = 30.0;
    final duration = (distance / averageSpeedKmh) * 3600; // seconds

    return RouteResult(
      geometry: [start, end],
      distance: distance * 1000, // convert km to meters
      duration: duration,
      isFallback: true,
    );
  }

  /// Calculate distance between two points using Haversine formula
  static double _calculateDistance(MapPoint point1, MapPoint point2) {
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

  static double _toRadians(double degrees) {
    return degrees * (math.pi / 180);
  }
}
