import 'package:flutter/material.dart';
import '../../widgets/map/driver_marker.dart';

/// Placeholder animation utilities; currently return the base widget without animation.
class MarkerAnimations {
  static Widget applyIdleAnimation(
    Widget markerWidget,
    DriverStatus status, {
    bool usePulse = true,
    bool useBounce = false,
  }) {
    return markerWidget;
  }
}
