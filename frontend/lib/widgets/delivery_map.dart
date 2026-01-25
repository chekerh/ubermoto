import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'dart:async';
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

class _DeliveryMapState extends State<DeliveryMap> {
  final fm.MapController _mapController = fm.MapController();
  bool _isLoadingRoute = false;
  bool _isUsingFallbackRoute = false;
  List<LatLng> _routePoints = [];
  List<LatLng> _driverRoutePoints = [];

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  @override
  void didUpdateWidget(DeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.driverLocation != widget.driverLocation ||
        oldWidget.status != widget.status) {
      _updateMapData();
    }
  }

  Future<void> _initializeMapData() async {
    await _loadRoute();
    if (widget.driverLocation != null && _isDriverMoving()) {
      await _loadDriverRoute();
    }
    _fitBounds();
  }

  Future<void> _fitBounds() async {
    final points = <LatLng>[
      LatLng(widget.pickupLocation.lat, widget.pickupLocation.lng),
      LatLng(widget.deliveryLocation.lat, widget.deliveryLocation.lng),
    ];
    
    if (widget.driverLocation != null) {
      points.add(LatLng(widget.driverLocation!.lat, widget.driverLocation!.lng));
    }

    if (points.isNotEmpty) {
      final bounds = LatLngBounds.fromPoints(points);
      _mapController.fitCamera(
        fm.CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  Future<void> _loadRoute() async {
    setState(() {
      _isLoadingRoute = true;
      _isUsingFallbackRoute = false;
    });

    try {
      final routeResult = await OSRMService.getRoute(
        widget.pickupLocation,
        widget.deliveryLocation,
      );

      setState(() {
        _isUsingFallbackRoute = routeResult.isFallback;
        _routePoints = routeResult.geometry
            .map((point) => LatLng(point.lat, point.lng))
            .toList();
      });
    } catch (e) {
      setState(() {
        _isUsingFallbackRoute = true;
        _routePoints = [
          LatLng(widget.pickupLocation.lat, widget.pickupLocation.lng),
          LatLng(widget.deliveryLocation.lat, widget.deliveryLocation.lng),
        ];
      });
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _loadDriverRoute() async {
    if (widget.driverLocation == null) return;

    try {
      final routeResult = await OSRMService.getRoute(
        widget.pickupLocation,
        widget.driverLocation!,
      );

      setState(() {
        _driverRoutePoints = routeResult.geometry
            .map((point) => LatLng(point.lat, point.lng))
            .toList();
      });
    } catch (e) {
      setState(() {
        _driverRoutePoints = [
          LatLng(widget.pickupLocation.lat, widget.pickupLocation.lng),
          LatLng(widget.driverLocation!.lat, widget.driverLocation!.lng),
        ];
      });
    }
  }

  void _updateMapData() {
    _initializeMapData();

    // Animate camera to show updated driver location
    if (widget.driverLocation != null) {
      _mapController.move(
        LatLng(widget.driverLocation!.lat, widget.driverLocation!.lng),
        16.0,
      );
    }
  }

  bool _isDriverMoving() {
    return widget.status == 'picked_up' || widget.status == 'in_progress';
  }

  List<fm.Marker> _buildMarkers() {
    final markers = <fm.Marker>[];

    // Pickup marker
    markers.add(
      fm.Marker(
        point: LatLng(widget.pickupLocation.lat, widget.pickupLocation.lng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
      ),
    );

    // Delivery marker
    markers.add(
      fm.Marker(
        point: LatLng(widget.deliveryLocation.lat, widget.deliveryLocation.lng),
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(Icons.flag, color: Colors.white, size: 20),
        ),
      ),
    );

    // Driver marker
    if (widget.driverLocation != null) {
      markers.add(
        fm.Marker(
          point: LatLng(widget.driverLocation!.lat, widget.driverLocation!.lng),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.motorcycle, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily disable iOS
    if (!Platform.isAndroid) {
      return const SizedBox();
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          fm.FlutterMap(
            mapController: _mapController,
            options: fm.MapOptions(
              initialCenter: LatLng(
                widget.pickupLocation.lat,
                widget.pickupLocation.lng,
              ),
              initialZoom: 12,
            ),
            children: [
              fm.TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ubermoto.app',
              ),
              if (_routePoints.isNotEmpty)
                fm.PolylineLayer(
                  polylines: [
                    fm.Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                      borderStrokeWidth: 0,
                    ),
                  ],
                ),
              if (_driverRoutePoints.isNotEmpty)
                fm.PolylineLayer(
                  polylines: [
                    fm.Polyline(
                      points: _driverRoutePoints,
                      strokeWidth: 3,
                      color: Colors.green,
                      borderStrokeWidth: 0,
                    ),
                  ],
                ),
              fm.MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
          if (_isLoadingRoute)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_isUsingFallbackRoute && !_isLoadingRoute)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Using estimated route (routing service unavailable)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
