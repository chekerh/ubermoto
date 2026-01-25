import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../widgets/map/map_search_bar.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../models/delivery_model.dart';
import '../../../core/animations/sheet_animations.dart';
import '../../../core/map/types.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final String? deliveryId;

  const DeliveryTrackingScreen({
    super.key,
    this.deliveryId,
  });

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  late DeliveryModel _delivery;
  late String _currentStatus;
  double? _driverLat;
  double? _driverLng;

  @override
  void initState() {
    super.initState();
    // Mock delivery data - in real app, this would come from API
    _delivery = _createMockDelivery();
    _currentStatus = _delivery.status.toString().split('.').last;
    _driverLat = _delivery.driverLatitude;
    _driverLng = _delivery.driverLongitude;
  }

  DeliveryModel _createMockDelivery() {
    return DeliveryModel(
      id: 'mock-delivery-1',
      pickupLocation: 'Downtown Mall, Tunis',
      deliveryAddress: 'Residential Area, Tunis',
      deliveryType: 'Food Delivery',
      status: DeliveryStatus.pickedUp,
      distance: 5.2,
      estimatedCost: 12.50,
      pickupLatitude: 36.8065,
      pickupLongitude: 10.1815,
      deliveryLatitude: 36.8188,
      deliveryLongitude: 10.1658,
      driverLatitude: 36.8120,
      driverLongitude: 10.1750,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
  }

  final Map<String, Map<String, dynamic>> _statusConfig = {
    'pending': {
      'title': 'Order Placed',
      'description': 'Waiting for driver assignment',
      'color': Colors.orange,
      'icon': Icons.schedule,
    },
    'accepted': {
      'title': 'Driver Assigned',
      'description': 'Driver is on the way to pickup',
      'color': Colors.blue,
      'icon': Icons.person_pin_circle,
    },
    'picked_up': {
      'title': 'Package Picked Up',
      'description': 'Driver has picked up your package',
      'color': Colors.purple,
      'icon': Icons.inventory_2,
    },
    'delivered': {
      'title': 'Delivered',
      'description': 'Package successfully delivered',
      'color': Colors.green,
      'icon': Icons.check_circle,
    },
  };

  @override
  Widget build(BuildContext context) {
    final currentStatusData = _statusConfig[_currentStatus]!;
    final theme = Theme.of(context);

    final pickupLocation = _delivery.pickupLatitude != null &&
            _delivery.pickupLongitude != null
        ? MapPoint(lat: _delivery.pickupLatitude!, lng: _delivery.pickupLongitude!)
        : null;
    final deliveryLocation = _delivery.deliveryLatitude != null &&
            _delivery.deliveryLongitude != null
        ? MapPoint(lat: _delivery.deliveryLatitude!, lng: _delivery.deliveryLongitude!)
        : null;
    final driverLocation = _driverLat != null && _driverLng != null
        ? MapPoint(lat: _driverLat!, lng: _driverLng!)
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Full-screen map
          if (pickupLocation != null && deliveryLocation != null)
            HomeMapWidget(
              initialLocation: pickupLocation,
              showUserLocation: true,
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Search bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MapSearchBar(
              placeholder: 'Tracking delivery...',
              showBackButton: true,
              onTap: () {}, // Placeholder - can be implemented later
            ),
          ),

          // Status bottom sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DraggableBottomSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              child: _DeliveryStatusSheet(
                currentStatus: _currentStatus,
                statusConfig: _statusConfig,
                delivery: _delivery,
                driverLocation: driverLocation,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryStatusSheet extends StatelessWidget {
  final String currentStatus;
  final Map<String, Map<String, dynamic>> statusConfig;
  final DeliveryModel delivery;
  final MapPoint? driverLocation;

  const _DeliveryStatusSheet({
    required this.currentStatus,
    required this.statusConfig,
    required this.delivery,
    this.driverLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStatusData = statusConfig[currentStatus]!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: (currentStatusData['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentStatusData['icon'],
                  size: 32,
                  color: currentStatusData['color'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentStatusData['title'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentStatusData['description'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress timeline
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTimelineStep(
                    context,
                    'Order Placed',
                    'Your delivery request has been received',
                    isCompleted: true,
                    isActive: currentStatus == 'pending',
                  ),
                  _buildTimelineStep(
                    context,
                    'Driver Assigned',
                    'Driver has been assigned to your delivery',
                    isCompleted: ['accepted', 'picked_up', 'delivered']
                        .contains(currentStatus),
                    isActive: currentStatus == 'accepted',
                  ),
                  _buildTimelineStep(
                    context,
                    'Package Picked Up',
                    'Driver has picked up your package',
                    isCompleted: ['picked_up', 'delivered'].contains(currentStatus),
                    isActive: currentStatus == 'picked_up',
                  ),
                  _buildTimelineStep(
                    context,
                    'Delivered',
                    'Package delivered successfully',
                    isCompleted: currentStatus == 'delivered',
                    isActive: currentStatus == 'delivered',
                  ),
                ],
              ),
            ),
          ),

          // Driver info (if assigned)
          if (['accepted', 'picked_up', 'delivered'].contains(currentStatus))
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
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
                            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            const Text('4.8'),
                            const SizedBox(width: 16),
                            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            const Text('23 min'),
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
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildTimelineStep(
    BuildContext context,
    String title,
    String description, {
    required bool isCompleted,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                  border: Border.all(
                    color: isActive ? theme.colorScheme.primary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              if (title != 'Delivered')
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? Colors.green : Colors.grey.shade300,
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? theme.colorScheme.primary : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}