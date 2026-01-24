import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/map/types.dart';

/// Nominatim geocoding service (replaces Google geocoding)
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'UberMoto/1.0';
  static const Duration _cacheTTL = Duration(hours: 1);
  static const Duration _rateLimitDelay = Duration(seconds: 1);
  
  static DateTime? _lastRequestTime;

  /// Forward geocoding: address string to coordinates
  static Future<List<MapPoint>> searchAddress(String query) async {
    // Check cache first
    final cached = await _getCachedGeocode(query);
    if (cached != null) {
      return cached;
    }

    // Rate limiting
    await _enforceRateLimit();

    try {
      final url = Uri.parse(
        '$_baseUrl/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final results = data
            .map((item) => MapPoint(
                  lat: double.parse(item['lat'].toString()),
                  lng: double.parse(item['lon'].toString()),
                ))
            .toList();

        // Cache results
        await _cacheGeocode(query, results);
        
        return results;
      } else {
        throw Exception('Nominatim API error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to geocode address: $e');
    }
  }

  /// Reverse geocoding: coordinates to address
  static Future<String> reverseGeocode(MapPoint point) async {
    final cacheKey = 'reverse_${point.lat}_${point.lng}';
    
    // Check cache first
    final cached = await _getCachedReverse(cacheKey);
    if (cached != null) {
      return cached;
    }

    // Rate limiting
    await _enforceRateLimit();

    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=${point.lat}&lon=${point.lng}&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        
        String addressString = '';
        if (address != null) {
          // Build address string from components
          final parts = <String>[];
          if (address['road'] != null) parts.add(address['road'].toString());
          if (address['house_number'] != null) parts.add(address['house_number'].toString());
          if (address['city'] != null || address['town'] != null) {
            parts.add((address['city'] ?? address['town']).toString());
          }
          if (address['country'] != null) parts.add(address['country'].toString());
          addressString = parts.join(', ');
        }
        
        if (addressString.isEmpty) {
          addressString = data['display_name']?.toString() ?? '${point.lat}, ${point.lng}';
        }

        // Cache result
        await _cacheReverse(cacheKey, addressString);
        
        return addressString;
      } else {
        throw Exception('Nominatim API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to coordinates if reverse geocoding fails
      return '${point.lat}, ${point.lng}';
    }
  }

  /// Get placemark details from coordinates
  static Future<Map<String, String>> placemarkFromCoordinates(MapPoint point) async {
    final cacheKey = 'placemark_${point.lat}_${point.lng}';
    
    // Check cache
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      final cached = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);
      if (DateTime.now().difference(timestamp) < _cacheTTL) {
        return Map<String, String>.from(cached['data'] as Map);
      }
    }

    // Rate limiting
    await _enforceRateLimit();

    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?lat=${point.lat}&lon=${point.lng}&format=json&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        
        final placemark = <String, String>{
          'street': address['road']?.toString() ?? '',
          'locality': address['city']?.toString() ?? 
                      address['town']?.toString() ?? 
                      address['village']?.toString() ?? '',
          'country': address['country']?.toString() ?? '',
          'postalCode': address['postcode']?.toString() ?? '',
        };

        // Cache result
        await prefs.setString(cacheKey, jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
          'data': placemark,
        }));

        return placemark;
      } else {
        throw Exception('Nominatim API error: ${response.statusCode}');
      }
    } catch (e) {
      return {
        'street': '',
        'locality': '',
        'country': '',
        'postalCode': '',
      };
    }
  }

  /// Enforce rate limiting (1 request per second)
  static Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _rateLimitDelay) {
        await Future.delayed(_rateLimitDelay - elapsed);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Cache geocoding results
  static Future<void> _cacheGeocode(String query, List<MapPoint> results) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'geocode_${query.hashCode}';
    await prefs.setString(cacheKey, jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'results': results.map((p) => {'lat': p.lat, 'lng': p.lng}).toList(),
    }));
  }

  /// Get cached geocoding results
  static Future<List<MapPoint>?> _getCachedGeocode(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'geocode_${query.hashCode}';
    final cachedJson = prefs.getString(cacheKey);
    
    if (cachedJson != null) {
      final cached = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) < _cacheTTL) {
        final results = (cached['results'] as List)
            .map((item) => MapPoint(
                  lat: (item as Map)['lat'] as double,
                  lng: item['lng'] as double,
                ))
            .toList();
        return results;
      }
    }
    return null;
  }

  /// Cache reverse geocoding results
  static Future<void> _cacheReverse(String key, String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'address': address,
    }));
  }

  /// Get cached reverse geocoding result
  static Future<String?> _getCachedReverse(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString(key);
    
    if (cachedJson != null) {
      final cached = jsonDecode(cachedJson) as Map<String, dynamic>;
      final timestamp = DateTime.parse(cached['timestamp'] as String);
      
      if (DateTime.now().difference(timestamp) < _cacheTTL) {
        return cached['address'] as String;
      }
    }
    return null;
  }
}
