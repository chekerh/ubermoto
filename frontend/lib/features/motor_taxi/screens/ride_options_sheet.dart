import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../core/animations/sheet_animations.dart';
import '../providers/motor_taxi_provider.dart';
import 'matching_screen.dart';

class RideOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final int etaMinutes;
  final double distance;

  const RideOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.etaMinutes,
    required this.distance,
  });
}

class RideOptionsSheet extends ConsumerWidget {
  const RideOptionsSheet({super.key});

  static Future<void> show({required BuildContext context}) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      child: const RideOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pickup = ref.watch(pickupLocationProvider);
    final destination = ref.watch(destinationLocationProvider);

    // Mock ride options - in production, this would come from backend
    final rideOptions = [
      const RideOption(
        id: 'standard',
        name: 'Standard Motor',
        description: 'Affordable and reliable',
        price: 8.50,
        etaMinutes: 5,
        distance: 3.2,
      ),
      const RideOption(
        id: 'premium',
        name: 'Premium Motor',
        description: 'Faster and more comfortable',
        price: 12.00,
        etaMinutes: 3,
        distance: 3.2,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose a ride',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (pickup != null && destination != null)
            Text(
              '${pickup.lat.toStringAsFixed(4)}, ${pickup.lng.toStringAsFixed(4)} → ${destination.lat.toStringAsFixed(4)}, ${destination.lng.toStringAsFixed(4)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView.builder(
              itemCount: rideOptions.length,
              itemBuilder: (context, index) {
                final option = rideOptions[index];
                return SheetAnimations.stagger(
                  index: index,
                  child: _RideOptionCard(
                    option: option,
                    onTap: () async {
                      Navigator.of(context).pop();
                      if (context.mounted) {
                        await MatchingScreen.show(context: context);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RideOptionCard extends StatelessWidget {
  final RideOption option;
  final VoidCallback onTap;

  const _RideOptionCard({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.motorcycle,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      option.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${option.etaMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.straighten,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${option.distance.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${option.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Est.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
