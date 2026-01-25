import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'driver_marker.dart';
import '../../core/utils/geolocation_service.dart';
import '../../core/utils/map_utils.dart';
import '../../core/map/types.dart';
import '../../services/driver_interpolation_service.dart';

class HomeMapWidget extends ConsumerStatefulWidget {
  final List<DriverMarker>? drivers;
  final MapPoint? initialLocation;
  final Function(DriverMarker)? onDriverTap;
  final Function(MapPoint)? onMapTap;
  final bool showUserLocation;

  const HomeMapWidget({
    super.key,
    this.drivers,
    this.initialLocation,
    this.onDriverTap,
    this.onMapTap,
    this.showUserLocation = true,
  });

  @override
  ConsumerState<HomeMapWidget> createState() => _HomeMapWidgetState();
}

class _HomeMapWidgetState extends ConsumerState<HomeMapWidget> {
  final fm.MapController _mapController = fm.MapController();
  MapPoint? _userLocation;
  bool _isLoadingLocation = true;
  final DriverInterpolationService _interpolationService = DriverInterpolationService();
  final Map<String, MapPoint> _previousDriverPositions = {};

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await GeolocationService.getCurrentPosition();
      setState(() {
        _userLocation = MapPoint(lat: position.latitude, lng: position.longitude);
        _isLoadingLocation = false;
      });
      _updateMapCamera();
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      if (widget.initialLocation != null) {
        _userLocation = widget.initialLocation;
        _updateMapCamera();
      }
    }
  }

  void _updateMapCamera() {
    if (_userLocation != null) {
      _mapController.move(
        LatLng(_userLocation!.lat, _userLocation!.lng),
        14.0,
      );
    }
  }

  List<fm.Marker> _buildMarkers() {
    final markers = <fm.Marker>[];

    // Add user location marker
    if (widget.showUserLocation && _userLocation != null) {
      markers.add(
        fm.Marker(
          point: LatLng(_userLocation!.lat, _userLocation!.lng),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    // Add driver markers
    if (widget.drivers != null) {
      for (final driver in widget.drivers!) {
        final previousPosition = _previousDriverPositions[driver.driverId];
        
        _interpolationService.updateDriverPosition(driver.driverId, driver.position);
        
        double? bearing;
        if (previousPosition != null) {
          bearing = MapUtils.calculateBearing(previousPosition, driver.position);
        } else if (driver.bearing != null) {
          bearing = driver.bearing;
        }
        
        final interpolatedPosition = _interpolationService.getCurrentPosition(driver.driverId) ?? driver.position;
        
        _interpolationService.onPositionUpdate(driver.driverId, (updatedPosition) {
          if (mounted) {
            setState(() {
              // Trigger rebuild to update marker position
            });
          }
        });
        
        _previousDriverPositions[driver.driverId] = driver.position;
        
        markers.add(
          fm.Marker(
            point: LatLng(interpolatedPosition.lat, interpolatedPosition.lng),
            width: 50,
            height: 50,
            child: GestureDetector(
              onTap: widget.onDriverTap != null
                  ? () => widget.onDriverTap!(driver)
                  : null,
              child: Transform.rotate(
                angle: bearing != null ? (bearing * 3.14159 / 180) : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: driver.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.motorcycle,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return markers;
  }

  @override
  void didUpdateWidget(HomeMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drivers != widget.drivers) {
      setState(() {
        // Trigger rebuild to update markers
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Temporarily disable iOS
    if (!Platform.isAndroid) {
      return const SizedBox();
    }

    if (_isLoadingLocation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final initialLocation = _userLocation ?? 
        widget.initialLocation ?? 
        const MapPoint(lat: 36.8065, lng: 10.1815);

    return fm.FlutterMap(
      mapController: _mapController,
      options: fm.MapOptions(
        initialCenter: LatLng(initialLocation.lat, initialLocation.lng),
        initialZoom: 14.0,
        onTap: widget.onMapTap != null
            ? (tapPosition, point) {
                widget.onMapTap!(MapPoint(
                  lat: point.latitude,
                  lng: point.longitude,
                ));
              }
            : null,
      ),
      children: [
        fm.TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.ubermoto.app',
        ),
        fm.MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _interpolationService.clear();
    super.dispose();
  }
}
