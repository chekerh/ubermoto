import 'package:flutter/material.dart';

/// Hero animation utilities for smooth transitions between screens
class HeroAnimations {
  /// Create a hero widget with a unique tag
  static Widget createHero({
    required String tag,
    required Widget child,
  }) {
    return Hero(
      tag: tag,
      child: child,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        final Hero toHero = toHeroContext.widget as Hero;
        return RotationTransition(
          turns: animation,
          child: toHero.child,
        );
      },
    );
  }

  /// Standard hero transition duration
  static const Duration transitionDuration = Duration(milliseconds: 300);
}
