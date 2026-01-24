import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animation utilities for bottom sheets
class SheetAnimations {
  /// Standard fade and slide animation for sheet content
  static Widget fadeSlide({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    double slideOffset = 0.1,
  }) {
    return child
        .animate()
        .fadeIn(duration: duration)
        .slideY(
          begin: slideOffset,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }

  /// Stagger animation for list items in sheets
  static Widget stagger({
    required Widget child,
    required int index,
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return child
        .animate()
        .fadeIn(duration: 200.ms, delay: delay * index)
        .slideX(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          delay: delay * index,
          curve: Curves.easeOutCubic,
        );
  }

  /// Scale animation for buttons and cards
  static Widget scale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 200),
  }) {
    return child
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: duration);
  }
}
