import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'websocket_service.dart';

class LocationService {
  static StreamSubscription<Position>? _positionStreamSubscription;
  static Timer? _simulationTimer;
  static LatLng? _currentLocation;
  static bool _isSimulating = false;

  static Future<void> startLocationTracking(String deliveryId) async {
    // Try real GPS first
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Use real GPS
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).listen((Position position) {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _sendLocationUpdate(deliveryId);
      });
    } else {
      // Fall back to simulation
      _startSimulation(deliveryId);
    }
  }

  static void _startSimulation(String deliveryId) {
    _isSimulating = true;
    _currentLocation = LatLng(24.7136, 46.6753); // Start from Riyadh
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Simulate movement towards customer
      if (_currentLocation != null) {
        double newLat = _currentLocation!.latitude + (0.0001 * (timer.tick % 10));
        double newLng = _currentLocation!.longitude + (0.0001 * (timer.tick % 8));
        _currentLocation = LatLng(newLat, newLng);
        _sendLocationUpdate(deliveryId);
      }
    });
  }

  static void _sendLocationUpdate(String deliveryId) {
    if (_currentLocation != null) {
      WebSocketService.updateLocation(
        deliveryId,
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
    }
  }

  static void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _simulationTimer?.cancel();
    _positionStreamSubscription = null;
    _simulationTimer = null;
    _isSimulating = false;
  }

  static LatLng? get currentLocation => _currentLocation;
  static bool get isSimulating => _isSimulating;
}
