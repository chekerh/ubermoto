import 'geolocation_service.dart';
import '../map/types.dart';

class DistanceCalculator {
  static Future<double?> calculateDistanceBetweenAddresses(
    String pickupAddress,
    String deliveryAddress,
  ) async {
    try {
      final pickupLocations = await GeolocationService.getLocationsFromAddress(
        pickupAddress,
      );
      final deliveryLocations = await GeolocationService.getLocationsFromAddress(
        deliveryAddress,
      );

      if (pickupLocations.isEmpty || deliveryLocations.isEmpty) {
        return null;
      }

      final pickup = pickupLocations.first;
      final delivery = deliveryLocations.first;

      return await GeolocationService.calculateDistance(
        pickup.lat,
        pickup.lng,
        delivery.lat,
        delivery.lng,
      );
    } catch (e) {
      return null;
    }
  }
}
