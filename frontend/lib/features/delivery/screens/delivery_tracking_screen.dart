import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../widgets/delivery_map.dart';
import '../../../models/delivery_model.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Delivery'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: currentStatusData['color'].withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    currentStatusData['icon'],
                    size: 64,
                    color: currentStatusData['color'],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentStatusData['title'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: currentStatusData['color'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentStatusData['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Delivery Map
            if (_delivery.pickupLatitude != null &&
                _delivery.pickupLongitude != null &&
                _delivery.deliveryLatitude != null &&
                _delivery.deliveryLongitude != null)
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: DeliveryMap(
                    pickupLocation: LatLng(
                      _delivery.pickupLatitude!,
                      _delivery.pickupLongitude!,
                    ),
                    deliveryLocation: LatLng(
                      _delivery.deliveryLatitude!,
                      _delivery.deliveryLongitude!,
                    ),
                    driverLocation: _driverLat != null && _driverLng != null
                        ? LatLng(_driverLat!, _driverLng!)
                        : null,
                    status: _currentStatus,
                  ),
                ),
              ),

            // Progress Timeline
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildTimelineStep(
                    'Order Placed',
                    'Your delivery request has been received',
                    '10:30 AM',
                    isCompleted: true,
                    isActive: _currentStatus == 'pending',
                  ),
                  _buildTimelineStep(
                    'Driver Assigned',
                    'John Driver has been assigned to your delivery',
                    '10:35 AM',
                    isCompleted: ['accepted', 'picked_up', 'delivered'].contains(_currentStatus),
                    isActive: _currentStatus == 'accepted',
                  ),
                  _buildTimelineStep(
                    'Package Picked Up',
                    'Driver has picked up your package',
                    '10:45 AM',
                    isCompleted: ['picked_up', 'delivered'].contains(_currentStatus),
                    isActive: _currentStatus == 'picked_up',
                  ),
                  _buildTimelineStep(
                    'Delivered',
                    'Package delivered successfully',
                    '11:00 AM',
                    isCompleted: _currentStatus == 'delivered',
                    isActive: _currentStatus == 'delivered',
                  ),
                ],
              ),
            ),

            // Driver Information (only show if driver assigned)
            if (['accepted', 'picked_up', 'delivered'].contains(_currentStatus))
              _buildDriverInfo(),

            // Map Placeholder (in real app, integrate Google Maps)
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Live Map View',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_currentStatus != 'delivered')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Implement call driver
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Driver'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement chat with driver
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Message Driver'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  if (_currentStatus == 'delivered')
                    const SizedBox(height: 12),

                  if (_currentStatus == 'delivered')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to rating screen
                        },
                        icon: const Icon(Icons.star),
                        label: const Text('Rate Delivery'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String description,
    String time,
    {
      required bool isCompleted,
      required bool isActive,
    }
  ) {
    return Row(
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
                  color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
            ),
            if (title != 'Delivered') // Don't show line after last item
              Container(
                width: 2,
                height: 60,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Theme.of(context).primaryColor : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDriverInfo() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              child: const Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Driver',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '4.8',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Honda Forza 300cc',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(
                  '23 min',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'away',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}