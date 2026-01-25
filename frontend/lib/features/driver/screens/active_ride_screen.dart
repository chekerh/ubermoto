import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../widgets/map/map_search_bar.dart';
import '../../../core/map/types.dart';

enum RideStatus { enRoute, arrived, pickedUp, inTransit, completed }

class ActiveRideScreen extends ConsumerStatefulWidget {
  final String rideId;
  final MapPoint pickupLocation;
  final MapPoint deliveryLocation;
  final String pickupAddress;
  final String deliveryAddress;

  const ActiveRideScreen({
    super.key,
    required this.rideId,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupAddress,
    required this.deliveryAddress,
  });

  @override
  ConsumerState<ActiveRideScreen> createState() => _ActiveRideScreenState();
}

class _ActiveRideScreenState extends ConsumerState<ActiveRideScreen> {
  RideStatus _currentStatus = RideStatus.enRoute;

  void _updateStatus(RideStatus newStatus) {
    setState(() {
      _currentStatus = newStatus;
    });
  }

  String _getStatusButtonText() {
    switch (_currentStatus) {
      case RideStatus.enRoute:
        return 'Arrived at Pickup';
      case RideStatus.arrived:
        return 'Picked Up';
      case RideStatus.pickedUp:
        return 'In Transit';
      case RideStatus.inTransit:
        return 'Completed';
      case RideStatus.completed:
        return 'Completed';
    }
  }

  void _handleStatusButton() {
    switch (_currentStatus) {
      case RideStatus.enRoute:
        _updateStatus(RideStatus.arrived);
        break;
      case RideStatus.arrived:
        _updateStatus(RideStatus.pickedUp);
        break;
      case RideStatus.pickedUp:
        _updateStatus(RideStatus.inTransit);
        break;
      case RideStatus.inTransit:
        _updateStatus(RideStatus.completed);
        // Navigate back to dashboard
        Navigator.of(context).pop();
        break;
      case RideStatus.completed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          HomeMapWidget(
            initialLocation: _currentStatus == RideStatus.enRoute ||
                    _currentStatus == RideStatus.arrived
                ? widget.pickupLocation
                : widget.deliveryLocation,
            showUserLocation: true,
          ),

          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              placeholder: 'Active ride',
              showBackButton: true,
              onTap: () {}, // Placeholder - can be implemented later
            ),
          ),

          // Bottom controls
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
                    // Current location info
                    _LocationInfo(
                      icon: _currentStatus == RideStatus.enRoute ||
                              _currentStatus == RideStatus.arrived
                          ? Icons.location_on
                          : Icons.flag,
                      address: _currentStatus == RideStatus.enRoute ||
                              _currentStatus == RideStatus.arrived
                          ? widget.pickupAddress
                          : widget.deliveryAddress,
                      color: _currentStatus == RideStatus.enRoute ||
                              _currentStatus == RideStatus.arrived
                          ? Colors.green
                          : Colors.red,
                    ),
                    const SizedBox(height: 20),

                    // Status button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _currentStatus != RideStatus.completed
                            ? _handleStatusButton
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _getStatusButtonText(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

class _LocationInfo extends StatelessWidget {
  final IconData icon;
  final String address;
  final Color color;

  const _LocationInfo({
    required this.icon,
    required this.address,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                icon == Icons.location_on ? 'Pickup' : 'Delivery',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                address,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
