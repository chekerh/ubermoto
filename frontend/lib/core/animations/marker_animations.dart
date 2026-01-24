import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../map/map_marker_adapter.dart';
import '../map/types.dart';
import '../../widgets/map/driver_marker.dart';

/// Animation utilities for map markers
class MarkerAnimations {
  /// Create a pulse animation effect for idle markers
  /// Returns animation configuration for flutter_animate
  static Effect pulseAnimation({
    Duration duration = const Duration(seconds: 2),
    double minScale = 1.0,
    double maxScale = 1.1,
    double minOpacity = 0.8,
    double maxOpacity = 1.0,
  }) {
    return Effect.custom(
      duration: duration,
      begin: 0.0,
      end: 1.0,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Create sine wave for smooth pulsing
        final sineValue = (value * 2 * 3.14159).sin();
        final normalizedValue = (sineValue + 1) / 2; // Normalize to 0-1
        
        final scale = minScale + (maxScale - minScale) * normalizedValue;
        final opacity = minOpacity + (maxOpacity - minOpacity) * normalizedValue;
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
    );
  }

  /// Create a bounce animation effect for markers
  static Effect bounceAnimation({
    Duration duration = const Duration(seconds: 1),
    double bounceHeight = 4.0,
  }) {
    return Effect.custom(
      duration: duration,
      begin: 0.0,
      end: 1.0,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // Bounce effect using sine wave
        final bounceValue = (value * 2 * 3.14159).sin().abs();
        final offset = -bounceValue * bounceHeight;
        
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
    );
  }

  /// Apply idle animation to a marker widget
  /// This is for Flutter widgets, not MapLibre markers
  static Widget applyIdleAnimation(
    Widget markerWidget,
    DriverStatus status, {
    bool usePulse = true,
    bool useBounce = false,
  }) {
    if (status != DriverStatus.online) {
      return markerWidget;
    }

    Widget animated = markerWidget;

    if (usePulse) {
      animated = animated.animate(
        onPlay: (controller) => controller.repeat(),
      ).effect(
        pulseAnimation(),
      );
    }

    if (useBounce) {
      animated = animated.animate(
        onPlay: (controller) => controller.repeat(),
      ).effect(
        bounceAnimation(),
      );
    }

    return animated;
  }
}
