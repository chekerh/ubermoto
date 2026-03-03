import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Conditional imports
import 'maplibre_map_widget.dart'
    if (dart.library.io) 'maplibre_map_widget.dart'
    if (dart.library.html) 'maplibre_map_widget.dart';

class PlatformMapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final void Function(LatLng)? onTap;

  const PlatformMapWidget({
    super.key,
    required this.center,
    this.zoom = 15.0,
    this.markers = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use MapLibre on Android, OpenStreetMap on iOS
    if (defaultTargetPlatform == TargetPlatform.android) {
      return MapLibreMapWidget(
        center: center,
        zoom: zoom,
        markers: markers,
        onTap: onTap,
      );
    } else {
      // iOS: Use flutter_map with OpenStreetMap
      return FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
          onTap: onTap != null
              ? (tapPosition, point) => onTap!(point)
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.ubertaxi_frontend',
          ),
          MarkerLayer(markers: markers),
        ],
      );
    }
  }
}
