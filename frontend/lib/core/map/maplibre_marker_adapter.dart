import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart' as ml;
import 'map_marker_adapter.dart';
import 'types.dart';

/// MapLibre implementation for marker management
class MaplibreMarkerAdapter {
  final ml.MaplibreMapController _controller;
  final Map<String, Symbol> _symbols = {};
  final Map<String, VoidCallback> _onTapCallbacks = {};
  final Map<String, Timer> _idleAnimationTimers = {};
  final Map<String, bool> _isIdleAnimated = {};

  MaplibreMarkerAdapter(this._controller);

  /// Add a marker to the map
  Future<void> addMarker(MarkerData marker, {bool isIdle = false}) async {
    if (_symbols.containsKey(marker.id)) {
      await removeMarker(marker.id);
    }

    // Create symbol options
    // Note: MapLibre requires icons to be in the style
    // For production, add custom motor icons to the map style JSON
    final baseIconSize = 1.3; // Slightly larger for better visibility
    final options = ml.SymbolOptions(
      geometry: marker.position.toMapLibreCoordinates(),
      iconImage: _getIconImageForColor(marker.color),
      iconSize: baseIconSize,
      iconRotate: marker.bearing ?? 0,
      iconAnchor: ml.SymbolAnchor.CENTER,
      iconColor: _colorToHexString(marker.color),
      iconHaloColor: '#FFFFFF', // White halo for better contrast
      iconHaloWidth: 1.5, // Halo width for outline effect
      iconHaloBlur: 1.0, // Subtle blur on halo
    );

    final symbol = await _controller.addSymbol(options);
    _symbols[marker.id] = symbol;
    
    if (marker.onTap != null) {
      _onTapCallbacks[marker.id] = marker.onTap!;
    }

    // Start idle animation if requested
    if (isIdle) {
      _startIdleAnimation(marker.id, baseIconSize);
    }
  }

  /// Start idle animation (pulse) for a marker
  void _startIdleAnimation(String markerId, double baseIconSize) {
    // Stop existing animation if any
    _stopIdleAnimation(markerId);
    
    _isIdleAnimated[markerId] = true;
    final startTime = DateTime.now();
    const animationDuration = Duration(seconds: 2);
    
    _idleAnimationTimers[markerId] = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (timer) {
        final symbol = _symbols[markerId];
        if (symbol == null) {
          timer.cancel();
          return;
        }

        final elapsed = DateTime.now().difference(startTime);
        final progress = (elapsed.inMilliseconds % animationDuration.inMilliseconds) /
            animationDuration.inMilliseconds;
        
        // Create sine wave for smooth pulsing (0 to 1)
        final sineValue = (progress * 2 * 3.14159).sin();
        final normalizedValue = (sineValue + 1) / 2; // Normalize to 0-1
        
        // Pulse between baseIconSize and 1.1x baseIconSize
        final minSize = baseIconSize;
        final maxSize = baseIconSize * 1.1;
        final currentSize = minSize + (maxSize - minSize) * normalizedValue;
        
        // Update icon size
        _controller.updateSymbol(
          symbol,
          ml.SymbolOptions(iconSize: currentSize),
        );
      },
    );
  }

  /// Stop idle animation for a marker
  void _stopIdleAnimation(String markerId) {
    _idleAnimationTimers[markerId]?.cancel();
    _idleAnimationTimers.remove(markerId);
    _isIdleAnimated.remove(markerId);
  }

  /// Remove a marker from the map
  Future<void> removeMarker(String id) async {
    _stopIdleAnimation(id);
    final symbol = _symbols.remove(id);
    if (symbol != null) {
      await _controller.removeSymbol(symbol);
    }
    _onTapCallbacks.remove(id);
  }

  /// Update marker position
  Future<void> updateMarkerPosition(String id, MapPoint position) async {
    final symbol = _symbols[id];
    if (symbol != null) {
      await _controller.updateSymbol(
        symbol,
        ml.SymbolOptions(
          geometry: position.toMapLibreCoordinates(),
        ),
      );
    }
  }

  /// Update marker color
  Future<void> updateMarkerColor(String id, Color color) async {
    final symbol = _symbols[id];
    if (symbol != null) {
      await _controller.updateSymbol(
        symbol,
        ml.SymbolOptions(
          iconImage: _getIconImageForColor(color),
        ),
      );
    }
  }

  /// Update marker bearing (rotation)
  Future<void> updateMarkerBearing(String id, double bearing) async {
    final symbol = _symbols[id];
    if (symbol != null) {
      await _controller.updateSymbol(
        symbol,
        ml.SymbolOptions(
          iconRotate: bearing,
        ),
      );
    }
  }

  /// Update marker position and bearing together
  Future<void> updateMarkerPositionAndBearing(
    String id,
    MapPoint position,
    double? bearing,
  ) async {
    final symbol = _symbols[id];
    if (symbol != null) {
      await _controller.updateSymbol(
        symbol,
        ml.SymbolOptions(
          geometry: position.toMapLibreCoordinates(),
          iconRotate: bearing ?? 0,
        ),
      );
    }
  }

  /// Handle symbol tap
  void handleSymbolTap(ml.Symbol symbol) {
    // Find which marker was tapped
    for (final entry in _symbols.entries) {
      if (entry.value == symbol) {
        final callback = _onTapCallbacks[entry.key];
        callback?.call();
        break;
      }
    }
  }

  /// Check if a marker exists
  bool hasMarker(String id) {
    return _symbols.containsKey(id);
  }

  /// Set marker idle animation state
  void setMarkerIdle(String id, bool isIdle, {double baseIconSize = 1.2}) {
    if (isIdle && !_isIdleAnimated.containsKey(id)) {
      _startIdleAnimation(id, baseIconSize);
    } else if (!isIdle && _isIdleAnimated.containsKey(id)) {
      _stopIdleAnimation(id);
      // Reset icon size to base
      final symbol = _symbols[id];
      if (symbol != null) {
        _controller.updateSymbol(
          symbol,
          ml.SymbolOptions(iconSize: baseIconSize),
        );
      }
    }
  }

  /// Clear all markers
  Future<void> clearAll() async {
    // Stop all animations
    for (final timer in _idleAnimationTimers.values) {
      timer.cancel();
    }
    _idleAnimationTimers.clear();
    _isIdleAnimated.clear();
    
    for (final symbol in _symbols.values) {
      await _controller.removeSymbol(symbol);
    }
    _symbols.clear();
    _onTapCallbacks.clear();
  }

  /// Get icon image name based on color
  /// MapLibre requires icons to be in the style JSON
  /// For now, we'll use a default marker from the style
  /// In production, you would add custom motor icons to the map style
  String _getIconImageForColor(Color color) {
    // Use default marker from MapLibre style
    // The color will be handled via iconColor property if supported
    // For now, return a generic marker that exists in most MapLibre styles
    return 'marker';
  }

  /// Convert Color to hex string for MapLibre
  String _colorToHexString(Color color) {
    return '#${color.value.toRadixString(16).substring(2, 8)}';
  }
}
