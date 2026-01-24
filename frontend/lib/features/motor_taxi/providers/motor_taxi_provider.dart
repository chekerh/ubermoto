import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/map/driver_marker.dart';
import '../../../widgets/bottom_sheets/service_selector_sheet.dart';
import '../../../core/map/types.dart';

/// Provider for current service selection
final serviceSelectionProvider = StateProvider<ServiceType?>((ref) => null);

/// Provider for nearby drivers (would be connected to backend in production)
final nearbyDriversProvider = StateProvider<List<DriverMarker>>((ref) {
  // Mock data - in production, this would fetch from backend/WebSocket
  return [
    DriverMarker(
      driverId: 'driver1',
      position: const MapPoint(lat: 36.8065, lng: 10.1815),
      status: DriverStatus.online,
      bearing: 45,
    ),
    DriverMarker(
      driverId: 'driver2',
      position: const MapPoint(lat: 36.8080, lng: 10.1830),
      status: DriverStatus.online,
      bearing: 90,
    ),
    DriverMarker(
      driverId: 'driver3',
      position: const MapPoint(lat: 36.8050, lng: 10.1800),
      status: DriverStatus.busy,
      bearing: 180,
    ),
  ];
});

/// Provider for selected pickup location
final pickupLocationProvider = StateProvider<MapPoint?>((ref) => null);

/// Provider for selected destination location
final destinationLocationProvider = StateProvider<MapPoint?>((ref) => null);
