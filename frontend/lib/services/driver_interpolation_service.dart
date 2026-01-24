import 'dart:async';
import 'dart:math' as math;
import '../core/map/types.dart';

/// Interpolation state for a single driver
class _DriverInterpolationState {
  final String driverId;
  MapPoint? previousPosition;
  MapPoint? targetPosition;
  DateTime? interpolationStartTime;
  Duration interpolationDuration;
  Timer? interpolationTimer;
  MapPoint? currentInterpolatedPosition;

  _DriverInterpolationState({
    required this.driverId,
    this.previousPosition,
    this.targetPosition,
    this.interpolationStartTime,
    this.interpolationDuration = const Duration(milliseconds: 1500),
  });
}

/// Service for smoothly interpolating driver positions between GPS updates
/// Prevents marker teleportation by animating movement over time
class DriverInterpolationService {
  static final DriverInterpolationService _instance = DriverInterpolationService._internal();
  factory DriverInterpolationService() => _instance;
  DriverInterpolationService._internal();

  final Map<String, _DriverInterpolationState> _driverStates = {};
  final Map<String, Function(MapPoint)> _positionCallbacks = {};
  Timer? _updateTimer;

  /// Update driver position and start interpolation if position changed
  void updateDriverPosition(
    String driverId,
    MapPoint newPosition, {
    Duration? interpolationDuration,
  }) {
    final state = _driverStates[driverId];

    if (state == null) {
      // First position for this driver - set immediately
      _driverStates[driverId] = _DriverInterpolationState(
        driverId: driverId,
        previousPosition: newPosition,
        targetPosition: newPosition,
        currentInterpolatedPosition: newPosition,
        interpolationDuration: interpolationDuration ?? const Duration(milliseconds: 1500),
      );
      _startUpdateTimer();
      return;
    }

    // Check if position actually changed
    if (state.targetPosition != null &&
        state.targetPosition!.lat == newPosition.lat &&
        state.targetPosition!.lng == newPosition.lng) {
      return; // No change
    }

    // If interpolation is in progress, use current interpolated position as start
    final startPosition = state.currentInterpolatedPosition ?? state.previousPosition ?? newPosition;

    // Update state for new interpolation
    state.previousPosition = startPosition;
    state.targetPosition = newPosition;
    state.interpolationStartTime = DateTime.now();
    state.interpolationDuration = interpolationDuration ?? const Duration(milliseconds: 1500);
    state.currentInterpolatedPosition = startPosition;

    _startUpdateTimer();
  }

  /// Get current interpolated position for a driver
  MapPoint? getCurrentPosition(String driverId) {
    final state = _driverStates[driverId];
    return state?.currentInterpolatedPosition ?? state?.targetPosition;
  }

  /// Get target position for a driver
  MapPoint? getTargetPosition(String driverId) {
    return _driverStates[driverId]?.targetPosition;
  }

  /// Check if driver is currently interpolating
  bool isInterpolating(String driverId) {
    final state = _driverStates[driverId];
    if (state == null || state.previousPosition == null || state.targetPosition == null) {
      return false;
    }

    final startTime = state.interpolationStartTime;
    if (startTime == null) return false;

    final elapsed = DateTime.now().difference(startTime);
    return elapsed < state.interpolationDuration;
  }

  /// Register callback for position updates
  void onPositionUpdate(String driverId, Function(MapPoint) callback) {
    _positionCallbacks[driverId] = callback;
  }

  /// Remove driver from interpolation tracking
  void removeDriver(String driverId) {
    _driverStates[driverId]?.interpolationTimer?.cancel();
    _driverStates.remove(driverId);
    _positionCallbacks.remove(driverId);
    
    // Stop timer if no drivers left
    if (_driverStates.isEmpty) {
      _updateTimer?.cancel();
      _updateTimer = null;
    }
  }

  /// Clear all drivers
  void clear() {
    for (final state in _driverStates.values) {
      state.interpolationTimer?.cancel();
    }
    _driverStates.clear();
    _positionCallbacks.clear();
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// Start update timer if not already running
  void _startUpdateTimer() {
    if (_updateTimer != null && _updateTimer!.isActive) {
      return;
    }

    // Update at 60fps (every 16ms)
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateInterpolations();
    });
  }

  /// Update all active interpolations
  void _updateInterpolations() {
    final now = DateTime.now();
    final driversToRemove = <String>[];

    for (final entry in _driverStates.entries) {
      final driverId = entry.key;
      final state = entry.value;

      if (state.previousPosition == null || state.targetPosition == null) {
        continue;
      }

      final startTime = state.interpolationStartTime;
      if (startTime == null) {
        continue;
      }

      final elapsed = now.difference(startTime);
      
      if (elapsed >= state.interpolationDuration) {
        // Interpolation complete
        state.currentInterpolatedPosition = state.targetPosition;
        state.previousPosition = state.targetPosition;
        
        // Notify callback
        final callback = _positionCallbacks[driverId];
        if (callback != null) {
          callback(state.targetPosition!);
        }
      } else {
        // Calculate interpolation progress (0.0 to 1.0)
        final progress = elapsed.inMilliseconds / state.interpolationDuration.inMilliseconds;
        
        // Apply easing curve (easeInOutCubic)
        final easedProgress = _easeInOutCubic(progress);
        
        // Interpolate position
        final interpolated = _interpolatePosition(
          state.previousPosition!,
          state.targetPosition!,
          easedProgress,
        );
        
        state.currentInterpolatedPosition = interpolated;
        
        // Notify callback
        final callback = _positionCallbacks[driverId];
        if (callback != null) {
          callback(interpolated);
        }
      }
    }

    // Clean up completed interpolations
    for (final driverId in driversToRemove) {
      _driverStates.remove(driverId);
    }

    // Stop timer if no active interpolations
    bool hasActiveInterpolations = _driverStates.values.any((state) {
      if (state.previousPosition == null || state.targetPosition == null) {
        return false;
      }
      final startTime = state.interpolationStartTime;
      if (startTime == null) return false;
      final elapsed = DateTime.now().difference(startTime);
      return elapsed < state.interpolationDuration;
    });

    if (!hasActiveInterpolations && _driverStates.isEmpty) {
      _updateTimer?.cancel();
      _updateTimer = null;
    }
  }

  /// Interpolate between two positions
  MapPoint _interpolatePosition(MapPoint from, MapPoint to, double progress) {
    // Clamp progress to 0.0-1.0
    final clampedProgress = progress.clamp(0.0, 1.0);
    
    // Linear interpolation
    final lat = from.lat + (to.lat - from.lat) * clampedProgress;
    final lng = from.lng + (to.lng - from.lng) * clampedProgress;
    
    return MapPoint(lat: lat, lng: lng);
  }

  /// Easing function: easeInOutCubic
  /// Provides smooth acceleration and deceleration
  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  /// Dispose resources
  void dispose() {
    clear();
  }
}
