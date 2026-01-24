import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'dart:async';
import '../core/map/types.dart';
import '../core/map/map_controller.dart';
import '../core/map/maplibre_controller.dart';
import '../core/map/maplibre_marker_adapter.dart';
import '../core/map/maplibre_route_adapter.dart';
import '../core/map/map_marker_adapter.dart';
import '../core/map/map_route_adapter.dart';
import '../services/osrm_service.dart';
import '../core/utils/map_utils.dart';
import '../core/animations/map_animations.dart';

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
  ml.MaplibreMapController? _maplibreController;
  MapController? _mapController;
  MaplibreMarkerAdapter? _markerAdapter;
  MaplibreRouteAdapter? _routeAdapter;
  MapBounds? _bounds;
  bool _isLoadingRoute = false;
  bool _isUsingFallbackRoute = false;

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

  void _onMapCreated(ml.MaplibreMapController controller) {
    _maplibreController = controller;
    _mapController = MaplibreMapControllerImpl(controller);
    _markerAdapter = MaplibreMarkerAdapter(controller);
    _routeAdapter = MaplibreRouteAdapter(controller);
    
    _initializeMapData();
    
    // Fit bounds to show all markers
    if (_bounds != null && _mapController != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        MapAnimations.animateToBounds(_mapController!, _bounds!, padding: 50.0);
      });
    }
  }

  Future<void> _initializeMapData() async {
    if (_markerAdapter == null || _routeAdapter == null) return;

    await _markerAdapter!.clearAll();
    await _routeAdapter!.clearAll();

    // Add pickup marker
    await _markerAdapter!.addMarker(
      MarkerData(
        id: 'pickup',
        position: widget.pickupLocation,
        color: Colors.green,
      ),
    );

    // Add delivery marker
    await _markerAdapter!.addMarker(
      MarkerData(
        id: 'delivery',
        position: widget.deliveryLocation,
        color: Colors.red,
      ),
    );

    // Add driver marker if available
    if (widget.driverLocation != null) {
      await _markerAdapter!.addMarker(
        MarkerData(
          id: 'driver',
          position: widget.driverLocation!,
          color: Colors.blue,
        ),
      );
    }

    // Calculate route using OSRM
    await _loadRoute();

    // Create driver route if driver is moving
    if (widget.driverLocation != null && _isDriverMoving()) {
      await _loadDriverRoute();
    }

    _calculateBounds();
  }

  Future<void> _loadRoute() async {
    if (_routeAdapter == null) return;

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
      });

      await _routeAdapter!.addRoute(
        RouteData(
          id: 'route',
          points: routeResult.geometry,
          color: Colors.blue,
          width: 4.0,
          pattern: const [10.0, 5.0], // Dashed line
        ),
      );
    } catch (e) {
      // Fallback to straight line
      setState(() {
        _isUsingFallbackRoute = true;
      });
      
      await _routeAdapter!.addRoute(
        RouteData(
          id: 'route',
          points: [widget.pickupLocation, widget.deliveryLocation],
          color: Colors.blue,
          width: 4.0,
          pattern: const [10.0, 5.0],
        ),
      );
    } finally {
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<void> _loadDriverRoute() async {
    if (_routeAdapter == null || widget.driverLocation == null) return;

    try {
      final routeResult = await OSRMService.getRoute(
        widget.pickupLocation,
        widget.driverLocation!,
      );

      await _routeAdapter!.addRoute(
        RouteData(
          id: 'driver_route',
          points: routeResult.geometry,
          color: Colors.green,
          width: 3.0,
        ),
      );
    } catch (e) {
      // Fallback to straight line
      await _routeAdapter!.addRoute(
        RouteData(
          id: 'driver_route',
          points: [widget.pickupLocation, widget.driverLocation!],
          color: Colors.green,
          width: 3.0,
        ),
      );
    }
  }

  void _updateMapData() {
    _initializeMapData();

    // Animate camera to show updated driver location
    if (widget.driverLocation != null && _mapController != null) {
      MapAnimations.followLocation(
        _mapController!,
        widget.driverLocation!,
        zoom: 16.0,
      );
    }
  }

  bool _isDriverMoving() {
    return widget.status == 'picked_up' || widget.status == 'in_progress';
  }

  void _calculateBounds() {
    final points = <MapPoint>[
      widget.pickupLocation,
      widget.deliveryLocation,
    ];
    
    if (widget.driverLocation != null) {
      points.add(widget.driverLocation!);
    }

    if (points.isNotEmpty) {
      _bounds = MapBounds.fromPoints(points);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          ml.MaplibreMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: ml.CameraPosition(
              target: ml.LatLng(
                widget.pickupLocation.lat,
                widget.pickupLocation.lng,
              ),
              zoom: 12,
            ),
            styleString: 'https://demotiles.maplibre.org/style.json',
            myLocationEnabled: false,
            zoomControlsEnabled: true,
          ),
          if (_isLoadingRoute)
            const Center(
              child: CircularProgressIndicator(),
            ),
          // Fallback route info banner
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

  @override
  void dispose() {
    _maplibreController?.dispose();
    super.dispose();
  }
}