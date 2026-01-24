import 'dart:async';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'map_controller.dart';
import 'types.dart';

/// MapLibre implementation of MapController
class MaplibreMapControllerImpl implements MapController {
  final ml.MaplibreMapController _controller;
  MapPoint? _currentCenter;
  double? _currentZoom;

  MaplibreMapControllerImpl(this._controller);

  @override
  Future<void> animateToLocation(
    MapPoint location, {
    double zoom = 15.0,
    Duration? duration,
  }) async {
    _currentCenter = location;
    _currentZoom = zoom;
    
    await _controller.animateCamera(
      ml.CameraUpdate.newCameraPosition(
        ml.CameraPosition(
          target: ml.LatLng(location.lat, location.lng),
          zoom: zoom,
        ),
      ),
      duration: duration ?? const Duration(milliseconds: 800),
    );
  }

  @override
  Future<void> animateToBounds(
    MapBounds bounds, {
    double padding = 50.0,
    Duration? duration,
  }) async {
    final center = bounds.center;
    _currentCenter = center;
    
    // Calculate zoom level to fit bounds
    // This is a simplified calculation - MapLibre will handle the actual fitting
    final latDiff = bounds.northeast.lat - bounds.southwest.lat;
    final lngDiff = bounds.northeast.lng - bounds.southwest.lng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    // Approximate zoom calculation
    double zoom = 15.0;
    if (maxDiff > 0.1) {
      zoom = 12.0;
    } else if (maxDiff > 0.05) {
      zoom = 13.0;
    } else if (maxDiff > 0.01) {
      zoom = 14.0;
    }
    
    await _controller.animateCamera(
      ml.CameraUpdate.newLatLngBounds(
        ml.LatLngBounds(
          southwest: ml.LatLng(bounds.southwest.lat, bounds.southwest.lng),
          northeast: ml.LatLng(bounds.northeast.lat, bounds.northeast.lng),
        ),
        left: padding,
        top: padding,
        right: padding,
        bottom: padding,
      ),
      duration: duration ?? const Duration(milliseconds: 800),
    );
    
    _currentZoom = zoom;
  }

  @override
  Future<void> followLocation(
    MapPoint location, {
    double zoom = 16.0,
    Duration? duration,
  }) async {
    _currentCenter = location;
    _currentZoom = zoom;
    
    await _controller.animateCamera(
      ml.CameraUpdate.newLatLngZoom(
        ml.LatLng(location.lat, location.lng),
        zoom,
      ),
      duration: duration ?? const Duration(milliseconds: 800),
    );
  }

  @override
  MapPoint? getCurrentCenter() {
    return _currentCenter;
  }

  @override
  double? getCurrentZoom() {
    return _currentZoom;
  }

  @override
  Future<void> moveToLocation(
    MapPoint location, {
    double zoom = 15.0,
  }) async {
    _currentCenter = location;
    _currentZoom = zoom;
    
    await _controller.moveCamera(
      ml.CameraUpdate.newCameraPosition(
        ml.CameraPosition(
          target: ml.LatLng(location.lat, location.lng),
          zoom: zoom,
        ),
      ),
    );
  }

  /// Get the underlying MapLibre controller for advanced operations
  ml.MaplibreMapController get controller => _controller;
}
