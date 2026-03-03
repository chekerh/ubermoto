import 'package:flutter/material.dart';
import 'dart:io';
import 'unified_map_widget.dart';
import '../core/map/types.dart';
import '../services/osrm_service.dart';
import '../core/utils/map_utils.dart';

class DeliveryMap extends StatefulWidget {
  final MapPoint pickupLocation;
  final MapPoint deliveryLocation;
  final MapPoint? driverLocation;
  final String status;

  const DeliveryMap({
    super.key,
    required this.pickupLocation,
    required this.deliveryLocation,
    this.driverLocation,
    required this.status,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class SimpleMarker {
  final double latitude;
  final double longitude;
  final Color color;
  final IconData icon;
  final String label;

  const SimpleMarker({
    required this.latitude,
    required this.longitude,
    required this.color,
    required this.icon,
    required this.label,
  });
}

class _DeliveryMapState extends State<DeliveryMap> {
  bool _isLoading = false;
  bool _isUsingFallbackRoute = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() {
      _isLoading = true;
      _isUsingFallbackRoute = false;
    });

    try {
      final routeResult = await OSRMService.getRoute(
        widget.pickupLocation,
        widget.deliveryLocation,
      );

      setState(() {
        _isUsingFallbackRoute = routeResult.isFallback;
      });
    } catch (e) {
      setState(() {
        _isUsingFallbackRoute = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<SimpleMarker> _getMarkers() {
    final markers = <SimpleMarker>[];
    
    // Pickup marker
    markers.add(const SimpleMarker(
      latitude: 24.7136, // Default Riyadh coordinates
      longitude: 46.6753,
      color: Colors.green,
      icon: Icons.location_on,
      label: 'Pickup',
    ));
    
    // Delivery marker
    markers.add(const SimpleMarker(
      latitude: 24.7236, // Slightly different for demo
      longitude: 46.6853,
      color: Colors.red,
      icon: Icons.flag,
      label: 'Delivery',
    ));
    
    // Driver marker (if available)
    if (widget.driverLocation != null && widget.status == 'IN_TRANSIT') {
      markers.add(const SimpleMarker(
        latitude: 24.7186, // Between pickup and delivery
        longitude: 46.6803,
        color: Colors.blue,
        icon: Icons.directions_car,
        label: 'Driver',
      ));
    }
    
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status bar
        if (_isLoading || _isUsingFallbackRoute)
          Container(
            padding: const EdgeInsets.all(8),
            color: _isUsingFallbackRoute ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(Icons.warning, color: Colors.orange[700], size: 16),
                const SizedBox(width: 8),
                Text(
                  _isLoading ? 'Loading route...' : 'Using offline route',
                  style: TextStyle(
                    color: _isUsingFallbackRoute ? Colors.orange[700] : Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        
        // Map
        Expanded(
          child: UnifiedMapWidget(
            latitude: widget.pickupLocation.lat,
            longitude: widget.pickupLocation.lng,
            markers: _getMarkers()
                .map((m) => MapMarkerData(
                      id: m.label,
                      latitude: m.latitude,
                      longitude: m.longitude,
                      color: m.color,
                      icon: m.icon,
                    ))
                .toList(),
            onTap: (lat, lng) {
              // Handle map tap
            },
          ),
        ),
        
        // Route info
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Status: ${widget.status}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Pickup: ${widget.pickupLocation.lat.toStringAsFixed(4)}, ${widget.pickupLocation.lng.toStringAsFixed(4)}'),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text('Delivery: ${widget.deliveryLocation.lat.toStringAsFixed(4)}, ${widget.deliveryLocation.lng.toStringAsFixed(4)}'),
                ],
              ),
              if (widget.driverLocation != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text('Driver: ${widget.driverLocation!.lat.toStringAsFixed(4)}, ${widget.driverLocation!.lng.toStringAsFixed(4)}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
