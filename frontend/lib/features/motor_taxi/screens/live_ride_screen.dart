import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../widgets/map/map_search_bar.dart';
import '../../../widgets/bottom_sheets/driver_info_sheet.dart';
import '../../../core/animations/map_animations.dart';
import '../../../core/map/types.dart';
import '../providers/motor_taxi_provider.dart';

class LiveRideScreen extends ConsumerStatefulWidget {
  const LiveRideScreen({super.key});

  @override
  ConsumerState<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends ConsumerState<LiveRideScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pickup = ref.watch(pickupLocationProvider);
    final destination = ref.watch(destinationLocationProvider);

    // Mock driver location (in production, this would come from WebSocket)
    final driverLocation = pickup != null
        ? MapPoint(lat: pickup.lat + 0.001, lng: pickup.lng + 0.001)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          HomeMapWidget(
            drivers: driverLocation != null
                ? [
                    DriverMarker(
                      driverId: 'assigned_driver',
                      position: driverLocation,
                      status: DriverStatus.online,
                    ),
                  ]
                : null,
            initialLocation: pickup,
            showUserLocation: true,
          ),

          // Search bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              placeholder: 'Ride in progress',
              showBackButton: true,
            ),
          ),

          // Driver info bottom sheet
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
                    // Driver info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: theme.colorScheme.primary,
                          child: const Text(
                            'D',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Driver Name',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('4.8'),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('3 min'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.phone),
                          onPressed: () {
                            // Call driver
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Route info
                    if (pickup != null && destination != null)
                      Column(
                        children: [
                          _RouteStep(
                            icon: Icons.location_on,
                            color: Colors.green,
                            label: 'Pickup',
                            isCompleted: true,
                          ),
                          const SizedBox(height: 12),
                          _RouteStep(
                            icon: Icons.flag,
                            color: Colors.red,
                            label: 'Destination',
                            isCompleted: false,
                          ),
                        ],
                      ),
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

class _RouteStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isCompleted;

  const _RouteStep({
    required this.icon,
    required this.color,
    required this.label,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isCompleted ? Colors.white : Colors.grey.shade600,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? color : Colors.grey.shade600,
                ),
          ),
        ),
        if (isCompleted)
          Icon(
            Icons.check_circle,
            color: color,
            size: 20,
          ),
      ],
    );
  }
}
