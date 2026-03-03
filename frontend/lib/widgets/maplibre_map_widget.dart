import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLibreMapWidget extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final List<Marker> markers;
  final void Function(LatLng)? onTap;

  const MapLibreMapWidget({
    super.key,
    required this.center,
    this.zoom = 15.0,
    this.markers = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: zoom,
        onTap: onTap != null ? (tapPosition, point) => onTap!(point) : null,
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
