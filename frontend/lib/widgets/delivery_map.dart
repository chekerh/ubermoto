import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class DeliveryMap extends StatefulWidget {
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final LatLng? driverLocation;
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
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLngBounds? _bounds;

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

  void _initializeMapData() {
    _markers.clear();
    _polylines.clear();

    // Add pickup marker
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Pickup Location'),
      ),
    );

    // Add delivery marker
    _markers.add(
      Marker(
        markerId: const MarkerId('delivery'),
        position: widget.deliveryLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'Delivery Location'),
      ),
    );

    // Add driver marker if available
    if (widget.driverLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Driver Location'),
        ),
      );
    }

    // Create route polyline
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: [widget.pickupLocation, widget.deliveryLocation],
        color: Colors.blue,
        width: 4,
        patterns: [PatternItem.dash(10), PatternItem.gap(10)],
      ),
    );

    // Create driver route if driver is moving
    if (widget.driverLocation != null && _isDriverMoving()) {
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('driver_route'),
          points: [widget.pickupLocation, widget.driverLocation!],
          color: Colors.green,
          width: 3,
        ),
      );
    }

    _calculateBounds();
  }

  void _updateMapData() {
    setState(() {
      _initializeMapData();
    });

    // Animate camera to show updated driver location
    if (widget.driverLocation != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(widget.driverLocation!),
      );
    }
  }

  bool _isDriverMoving() {
    return widget.status == 'picked_up' || widget.status == 'in_progress';
  }

  void _calculateBounds() {
    if (_markers.isEmpty) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final marker in _markers) {
      final position = marker.position;
      minLat = minLat < position.latitude ? minLat : position.latitude;
      maxLat = maxLat > position.latitude ? maxLat : position.latitude;
      minLng = minLng < position.longitude ? minLng : position.longitude;
      maxLng = maxLng > position.longitude ? maxLng : position.longitude;
    }

    _bounds = LatLngBounds(
      southwest: LatLng(minLat - 0.01, minLng - 0.01),
      northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Fit bounds to show all markers
    if (_bounds != null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(_bounds!, 50),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.pickupLocation,
          zoom: 12,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapType: MapType.normal,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}