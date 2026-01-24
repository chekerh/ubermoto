import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/animations/sheet_animations.dart';
import '../../../core/utils/map_utils.dart';
import '../../../core/map/types.dart';
import '../../motor_taxi/providers/motor_taxi_provider.dart';
import '../providers/delivery_provider.dart';
import '../screens/delivery_list_screen.dart';

class PriceEstimationSheet extends ConsumerWidget {
  final String packageType;
  final double weight;
  final String notes;

  const PriceEstimationSheet({
    super.key,
    required this.packageType,
    required this.weight,
    required this.notes,
  });

  static Future<void> show({
    required BuildContext context,
    required String packageType,
    required double weight,
    required String notes,
  }) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      child: PriceEstimationSheet(
        packageType: packageType,
        weight: weight,
        notes: notes,
      ),
    );
  }

  double _calculatePrice(double distance) {
    // Simple calculation: base fee + distance * rate
    const baseFee = 5.0;
    const ratePerKm = 2.0;
    return baseFee + (distance * ratePerKm);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pickup = ref.watch(pickupLocationProvider);
    final destination = ref.watch(destinationLocationProvider);
    final deliveryState = ref.watch(deliveryStateProvider);

    double? distance;
    double? estimatedPrice;

    if (pickup != null && destination != null) {
      distance = MapUtils.calculateDistance(pickup, destination);
      estimatedPrice = _calculatePrice(distance);
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Estimate',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Cost card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Estimated Price',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                if (estimatedPrice != null)
                  Text(
                    '\$${estimatedPrice!.toStringAsFixed(2)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                else
                  const Text('Calculating...'),
                if (distance != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${distance!.toStringAsFixed(1)} km',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Package info summary
          _InfoRow(label: 'Package Type', value: packageType),
          const SizedBox(height: 12),
          _InfoRow(label: 'Weight', value: '${weight.toStringAsFixed(1)} kg'),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            _InfoRow(label: 'Notes', value: notes),
          ],
          
          const Spacer(),
          
          // Create delivery button
          CustomButton(
            text: 'Create Delivery',
            onPressed: estimatedPrice != null && pickup != null && destination != null
                ? () async {
                    // Create delivery
                    await ref.read(deliveryStateProvider.notifier).createDelivery(
                          pickupLocation: '${pickup.lat}, ${pickup.lng}',
                          deliveryAddress: '${destination.lat}, ${destination.lng}',
                          deliveryType: packageType,
                          distance: distance,
                        );
                    
                    if (context.mounted && deliveryState.createdDelivery != null) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const DeliveryListScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                : null,
            isLoading: deliveryState.isLoading,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
