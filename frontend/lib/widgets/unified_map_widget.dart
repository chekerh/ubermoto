import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'platform_map_widget.dart';

class MapMarkerData {
  final String id;
  final double latitude;
  final double longitude;
  final Color color;
  final IconData icon;

  const MapMarkerData({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.color,
    required this.icon,
  });
}

class UnifiedMapWidget extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final List<MapMarkerData> markers;
  final void Function(double lat, double lng)? onTap;

  const UnifiedMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 13,
    this.markers = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final center = LatLng(latitude, longitude);
    final markerWidgets = markers
        .map(
          (m) => Marker(
            point: LatLng(m.latitude, m.longitude),
            width: 40,
            height: 40,
            child: Icon(
              m.icon,
              color: m.color,
              size: 32,
            ),
          ),
        )
        .toList();

    return PlatformMapWidget(
      center: center,
      zoom: zoom,
      markers: markerWidgets,
      onTap: onTap != null ? (latLng) => onTap!(latLng.latitude, latLng.longitude) : null,
    );
  }
}
