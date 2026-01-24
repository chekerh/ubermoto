import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../widgets/map/map_search_bar.dart';
import '../../../widgets/empty_states/no_drivers_widget.dart';
import '../../../core/animations/map_animations.dart';
import '../../../core/map/types.dart';
import '../providers/motor_taxi_provider.dart';
import '../../../widgets/map/driver_marker.dart';
import 'live_ride_screen.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  const MatchingScreen({super.key});

  static Future<void> show({required BuildContext context}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const MatchingScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  bool _isSearching = true;
  int _elapsedSeconds = 0;
  Timer? _elapsedTimer;
  Timer? _matchingTimer;

  @override
  void initState() {
    super.initState();
    _startMatching();
    _startElapsedTimer();
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _matchingTimer?.cancel();
    super.dispose();
  }

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _isSearching) {
        setState(() {
          _elapsedSeconds++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _startMatching() async {
    // Simulate searching for driver
    _matchingTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        
        // Navigate to live ride screen
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const LiveRideScreen(),
                fullscreenDialog: true,
              ),
            );
          }
        });
      }
    });
  }

  void _cancelMatching() {
    _matchingTimer?.cancel();
    _elapsedTimer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _getSearchingMessage() {
    if (_elapsedSeconds >= 20) {
      return 'Still searching…';
    } else if (_elapsedSeconds >= 10) {
      return 'Searching longer than usual…';
    }
    return 'Finding nearby drivers...';
  }

  String _getSearchingSubtitle() {
    if (_elapsedSeconds >= 20) {
      return 'This is taking longer than expected';
    } else if (_elapsedSeconds >= 10) {
      return 'Please wait a bit longer';
    }
    return 'Please wait';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drivers = ref.watch(nearbyDriversProvider);
    final pickup = ref.watch(pickupLocationProvider);
    final destination = ref.watch(destinationLocationProvider);

    // Filter only online drivers
    final availableDrivers = drivers
        .where((d) => d.status == DriverStatus.online)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          HomeMapWidget(
            drivers: availableDrivers,
            initialLocation: pickup,
            showUserLocation: true,
          ),

          // Search bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              placeholder: 'Finding your ride...',
              showBackButton: true,
            ),
          ),

          // Empty state if no drivers available
          if (!_isSearching && availableDrivers.isEmpty)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: NoDriversWidget(
                  customMessage: 'No drivers found nearby.\nTry again or check back later.',
                  onRetry: () {
                    setState(() {
                      _isSearching = true;
                      _elapsedSeconds = 0;
                    });
                    ref.invalidate(nearbyDriversProvider);
                    _startMatching();
                    _startElapsedTimer();
                  },
                ),
              ),
            ),

          // Searching overlay
          if (_isSearching)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getSearchingMessage(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getSearchingSubtitle(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_elapsedSeconds >= 10) ...[
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: _cancelMatching,
                          icon: const Icon(Icons.close, color: Colors.white),
                          label: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

          // Bottom info
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (pickup != null && destination != null) ...[
                      _LocationRow(
                        icon: Icons.location_on,
                        color: Colors.green,
                        label: 'Pickup',
                        location: '${pickup.lat.toStringAsFixed(4)}, ${pickup.lng.toStringAsFixed(4)}',
                      ),
                      const SizedBox(height: 12),
                      _LocationRow(
                        icon: Icons.flag,
                        color: Colors.red,
                        label: 'Destination',
                        location: '${destination.lat.toStringAsFixed(4)}, ${destination.lng.toStringAsFixed(4)}',
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String location;

  const _LocationRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              Text(
                location,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
