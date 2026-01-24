import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'draggable_bottom_sheet.dart';
import '../../core/animations/sheet_animations.dart';

enum ServiceType { motorTaxi, delivery }

class ServiceSelectorSheet extends StatelessWidget {
  final ServiceType? selectedService;
  final Function(ServiceType) onServiceSelected;

  const ServiceSelectorSheet({
    super.key,
    this.selectedService,
    required this.onServiceSelected,
  });

  static Future<ServiceType?> show({
    required BuildContext context,
    ServiceType? initialSelection,
  }) {
    ServiceType? selected = initialSelection;

    return DraggableBottomSheet.show<ServiceType>(
      context: context,
      initialChildSize: 0.3,
      minChildSize: 0.25,
      maxChildSize: 0.35,
      child: ServiceSelectorSheet(
        selectedService: initialSelection,
        onServiceSelected: (service) {
          selected = service;
          Navigator.of(context).pop(service);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Service',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: '🛵',
                  title: 'Motor Taxi',
                  isSelected: selectedService == ServiceType.motorTaxi,
                  onTap: () => onServiceSelected(ServiceType.motorTaxi),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ServiceCard(
                  icon: '📦',
                  title: 'Delivery',
                  isSelected: selectedService == ServiceType.delivery,
                  onTap: () => onServiceSelected(ServiceType.delivery),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 200.ms,
        )
        .fadeIn(duration: 200.ms);
  }
}
