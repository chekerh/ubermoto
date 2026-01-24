import 'package:geolocator/geolocator.dart';
import '../map/types.dart';
import '../../services/nominatim_service.dart';

class GeolocationService {
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  static Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    ) / 1000; // Convert meters to kilometers
  }

  /// Get locations from address using Nominatim (replaces Google geocoding)
  static Future<List<MapPoint>> getLocationsFromAddress(String address) async {
    return await NominatimService.searchAddress(address);
  }

  /// Get placemark from coordinates using Nominatim (replaces Google geocoding)
  static Future<Map<String, String>> placemarkFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    final point = MapPoint(lat: latitude, lng: longitude);
    return await NominatimService.placemarkFromCoordinates(point);
  }
}
