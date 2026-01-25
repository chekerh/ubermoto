import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/map/types.dart';

enum DriverStatus { online, busy, offline }

class DriverMarker {
  final String driverId;
  final MapPoint position;
  final DriverStatus status;
  final double? bearing; // For rotation

  const DriverMarker({
    required this.driverId,
    required this.position,
    required this.status,
    this.bearing,
  });

  /// Get color based on driver status
  Color get color {
    switch (status) {
      case DriverStatus.online:
        return AppTheme.driverOnlineColor;
      case DriverStatus.busy:
        return AppTheme.driverBusyColor;
      case DriverStatus.offline:
        return AppTheme.driverOfflineColor;
    }
  }

}
