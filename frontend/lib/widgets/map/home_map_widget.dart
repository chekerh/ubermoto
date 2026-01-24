import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'driver_marker.dart';
import '../../core/utils/geolocation_service.dart';
import '../../core/utils/map_utils.dart';
import '../../core/animations/map_animations.dart';
import '../../core/map/types.dart';
import '../../core/map/map_controller.dart';
import '../../core/map/maplibre_controller.dart';
import '../../core/map/maplibre_marker_adapter.dart';
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
  ml.MaplibreMapController? _maplibreController;
  MapController? _mapController;
  MapPoint? _userLocation;
  MaplibreMarkerAdapter? _markerAdapter;
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
      // Use initial location if provided, or default location
      if (widget.initialLocation != null) {
        _userLocation = widget.initialLocation;
        _updateMapCamera();
      }
    }
  }

  void _onMapCreated(ml.MaplibreMapController controller) {
    _maplibreController = controller;
    _mapController = MaplibreMapControllerImpl(controller);
    _markerAdapter = MaplibreMarkerAdapter(controller);
    
    _updateMarkers();
    _updateMapCamera();
  }

  void _updateMapCamera() {
    if (_mapController != null && _userLocation != null) {
      MapAnimations.animateToLocation(
        _mapController!,
        _userLocation!,
        zoom: 14.0,
      );
    }
  }

  Future<void> _updateMarkers() async {
    if (_markerAdapter == null) return;

    // Add user location marker
    if (widget.showUserLocation && _userLocation != null) {
      await _markerAdapter!.addMarker(
        MarkerData(
          id: 'user_location',
          position: _userLocation!,
          color: Colors.blue,
        ),
      );
    }

    // Update driver markers with interpolation and bearing
    if (widget.drivers != null) {
      final currentDriverIds = widget.drivers!.map((d) => d.driverId).toSet();
      
      // Remove drivers that are no longer in the list
      final driversToRemove = _previousDriverPositions.keys
          .where((id) => !currentDriverIds.contains(id))
          .toList();
      for (final driverId in driversToRemove) {
        _interpolationService.removeDriver(driverId);
        _previousDriverPositions.remove(driverId);
        await _markerAdapter!.removeMarker(driverId);
      }

      // Update or add driver markers
      for (final driver in widget.drivers!) {
        final previousPosition = _previousDriverPositions[driver.driverId];
        
        // Update interpolation service with new position
        _interpolationService.updateDriverPosition(driver.driverId, driver.position);
        
        // Calculate bearing if we have previous position
        double? bearing;
        if (previousPosition != null) {
          bearing = MapUtils.calculateBearing(previousPosition, driver.position);
        } else if (driver.bearing != null) {
          bearing = driver.bearing;
        }
        
        // Get interpolated position (or use actual if not interpolating)
        final interpolatedPosition = _interpolationService.getCurrentPosition(driver.driverId) ?? driver.position;
        
        // Register callback for interpolation updates
        _interpolationService.onPositionUpdate(driver.driverId, (updatedPosition) {
          if (mounted && _markerAdapter != null) {
            // Calculate bearing for interpolated position
            final prevPos = _previousDriverPositions[driver.driverId];
            double? updatedBearing;
            if (prevPos != null) {
              updatedBearing = MapUtils.calculateBearing(prevPos, updatedPosition);
            }
            
            // Update marker position and bearing smoothly
            _markerAdapter!.updateMarkerPositionAndBearing(
              driver.driverId,
              updatedPosition,
              updatedBearing,
            );
          }
        });
        
        // Store previous position for next update
        _previousDriverPositions[driver.driverId] = driver.position;
        
        // Add or update marker
        if (_markerAdapter!.hasMarker(driver.driverId)) {
          // Update existing marker
          await _markerAdapter!.updateMarkerPositionAndBearing(
            driver.driverId,
            interpolatedPosition,
            bearing,
          );
        } else {
          // Add new marker with idle animation for online drivers
          await _markerAdapter!.addMarker(
            MarkerData(
              id: driver.driverId,
              position: interpolatedPosition,
              color: driver.color,
              bearing: bearing,
              onTap: widget.onDriverTap != null
                  ? () => widget.onDriverTap!(driver)
                  : null,
            ),
            isIdle: driver.status == DriverStatus.online,
          );
          
          // Also set idle state for existing markers that might have changed status
          _markerAdapter!.setMarkerIdle(
            driver.driverId,
            driver.status == DriverStatus.online,
          );
        }
      }
    } else {
      // No drivers - clear all driver markers
      for (final driverId in _previousDriverPositions.keys) {
        _interpolationService.removeDriver(driverId);
        await _markerAdapter!.removeMarker(driverId);
      }
      _previousDriverPositions.clear();
    }
  }

  @override
  void didUpdateWidget(HomeMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drivers != widget.drivers) {
      _updateMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocation) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final initialLocation = _userLocation ?? 
        widget.initialLocation ?? 
        const MapPoint(lat: 36.8065, lng: 10.1815);

    return ml.MaplibreMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: ml.CameraPosition(
        target: ml.LatLng(initialLocation.lat, initialLocation.lng),
        zoom: 14.0,
      ),
      styleString: 'https://demotiles.maplibre.org/style.json',
      myLocationEnabled: widget.showUserLocation,
      myLocationTrackingMode: ml.MyLocationTrackingMode.Tracking,
      onMapClick: widget.onMapTap != null
          ? (point, latLng) {
              widget.onMapTap!(MapPoint(
                lat: latLng.latitude,
                lng: latLng.longitude,
              ));
            }
          : null,
      onSymbolTapped: (symbol) {
        _markerAdapter?.handleSymbolTap(symbol);
      },
    );
  }

  @override
  void dispose() {
    _interpolationService.clear();
    _maplibreController?.dispose();
    super.dispose();
  }
}
