import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/delivery_provider.dart';
import '../../../models/delivery_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/auth/screens/login_screen.dart';
import 'delivery_create_screen.dart';

class DeliveryListScreen extends ConsumerWidget {
  const DeliveryListScreen({super.key});

  String _getStatusText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.inProgress:
        return 'In Progress';
      case DeliveryStatus.completed:
        return 'Completed';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Colors.orange;
      case DeliveryStatus.accepted:
        return Colors.blue.shade600;
      case DeliveryStatus.pickedUp:
        return Colors.purple;
      case DeliveryStatus.inProgress:
        return Colors.blue;
      case DeliveryStatus.completed:
        return Colors.green;
      case DeliveryStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(deliveriesProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: deliveriesAsync.when(
        data: (deliveries) {
          if (deliveries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No deliveries yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first delivery',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(deliveriesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    onTap: () {
                      // Navigate to tracking if delivery has a driver
                      if (delivery.driverId != null && delivery.status != DeliveryStatus.pending) {
                        Navigator.of(context).pushNamed(
                          '/customer/delivery/tracking',
                          arguments: delivery.id,
                        );
                      }
                    },
                    title: Text(
                      delivery.deliveryType,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'From: ${delivery.pickupLocation}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_city, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'To: ${delivery.deliveryAddress}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(delivery.status)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: _getStatusColor(delivery.status),
                                ),
                              ),
                              child: Text(
                                _getStatusText(delivery.status),
                                style: TextStyle(
                                  color: _getStatusColor(delivery.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (delivery.estimatedCost != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue.shade300,
                                  ),
                                ),
                                child: Text(
                                  '${delivery.estimatedCost!.toStringAsFixed(2)} TND',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading deliveries',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(deliveriesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed('/customer/delivery/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Delivery'),
      ),
    );
  }
}
