import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'map_route_adapter.dart';
import 'types.dart';

/// MapLibre implementation for route/polyline management
class MaplibreRouteAdapter {
  final ml.MaplibreMapController _controller;
  final Map<String, ml.Line> _lines = {};

  MaplibreRouteAdapter(this._controller);

  /// Add a route to the map
  Future<void> addRoute(RouteData route) async {
    if (_lines.containsKey(route.id)) {
      await removeRoute(route.id);
    }

    // Convert points to MapLibre format
    final coordinates = route.points
        .map((point) => point.toMapLibreCoordinates())
        .toList();

    // Create line options with improved styling
    final options = LineOptions(
      geometry: coordinates,
      lineColor: _colorToHexString(route.color),
      lineWidth: route.width,
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineOpacity: 0.8, // Slight transparency for better visibility
      lineBlur: 0.5, // Subtle blur for smoother appearance
    );

    final line = await _controller.addLine(options);
    _lines[route.id] = line;
  }

  /// Remove a route from the map
  Future<void> removeRoute(String id) async {
    final line = _lines.remove(id);
    if (line != null) {
      await _controller.removeLine(line);
    }
  }

  /// Update route geometry
  Future<void> updateRouteGeometry(String id, List<MapPoint> points) async {
    final line = _lines[id];
    if (line != null) {
      final coordinates = points
          .map((point) => point.toMapLibreCoordinates())
          .toList();
      
      await _controller.updateLine(
        line,
        ml.LineOptions(geometry: coordinates),
      );
    }
  }

  /// Update route color
  Future<void> updateRouteColor(String id, Color color) async {
    final line = _lines[id];
    if (line != null) {
      await _controller.updateLine(
        line,
        ml.LineOptions(lineColor: _colorToHexString(color)),
      );
    }
  }

  /// Clear all routes
  Future<void> clearAll() async {
    for (final line in _lines.values) {
      await _controller.removeLine(line);
    }
    _lines.clear();
  }

  /// Convert Color to hex string for MapLibre
  String _colorToHexString(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}
