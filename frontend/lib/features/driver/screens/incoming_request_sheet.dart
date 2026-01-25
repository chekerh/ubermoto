import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../core/animations/sheet_animations.dart';
import '../../../core/map/types.dart';

class IncomingRequestSheet extends StatelessWidget {
  final String requestId;
  final String pickupAddress;
  final String deliveryAddress;
  final double distance;
  final double estimatedCost;
  final int estimatedTimeMinutes;
  final MapPoint pickupLocation;
  final MapPoint deliveryLocation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingRequestSheet({
    super.key,
    required this.requestId,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.distance,
    required this.estimatedCost,
    required this.estimatedTimeMinutes,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.onAccept,
    required this.onDecline,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String requestId,
    required String pickupAddress,
    required String deliveryAddress,
    required double distance,
    required double estimatedCost,
    required int estimatedTimeMinutes,
    required MapPoint pickupLocation,
    required MapPoint deliveryLocation,
  }) {
    bool? result;

    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      isDismissible: false,
      child: IncomingRequestSheet(
        requestId: requestId,
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        distance: distance,
        estimatedCost: estimatedCost,
        estimatedTimeMinutes: estimatedTimeMinutes,
        pickupLocation: pickupLocation,
        deliveryLocation: deliveryLocation,
        onAccept: () {
          result = true;
          Navigator.of(context).pop(true);
        },
        onDecline: () {
          result = false;
          Navigator.of(context).pop(false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Delivery Request',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tap to view details',
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

          // Map preview
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: HomeMapWidget(
                initialLocation: pickupLocation,
                showUserLocation: false,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Route details
          _DetailRow(
            icon: Icons.location_on,
            label: 'Pickup',
            value: pickupAddress,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.flag,
            label: 'Delivery',
            value: deliveryAddress,
            color: Colors.red,
          ),
          const SizedBox(height: 24),

          // Stats
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${distance.toStringAsFixed(1)} km',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '$estimatedTimeMinutes min',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.attach_money,
                  label: 'Earnings',
                  value: '\$${estimatedCost.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
          const Spacer(),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: theme.colorScheme.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300))
        .slideY(begin: 0.1, end: 0, duration: const Duration(milliseconds: 300));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
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
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
