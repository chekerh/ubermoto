import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'draggable_bottom_sheet.dart';

class DriverInfo {
  final String id;
  final String name;
  final double rating;
  final int totalRides;
  final String? vehicleInfo;
  final double? distance; // in km
  final int? etaMinutes;

  const DriverInfo({
    required this.id,
    required this.name,
    required this.rating,
    required this.totalRides,
    this.vehicleInfo,
    this.distance,
    this.etaMinutes,
  });
}

class DriverInfoSheet extends StatelessWidget {
  final DriverInfo driverInfo;
  final VoidCallback? onRequestRide;

  const DriverInfoSheet({
    super.key,
    required this.driverInfo,
    this.onRequestRide,
  });

  static Future<void> show({
    required BuildContext context,
    required DriverInfo driverInfo,
    VoidCallback? onRequestRide,
  }) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
      child: DriverInfoSheet(
        driverInfo: driverInfo,
        onRequestRide: onRequestRide,
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
          // Driver header
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: theme.colorScheme.primary,
                child: Text(
                  driverInfo.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
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
                      driverInfo.name,
                      style: theme.textTheme.titleLarge?.copyWith(
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
                        Text(
                          '${driverInfo.rating.toStringAsFixed(1)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${driverInfo.totalRides} rides',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Vehicle info
          if (driverInfo.vehicleInfo != null) ...[
            Row(
              children: [
                Icon(Icons.motorcycle, size: 20, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  driverInfo.vehicleInfo!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Distance and ETA
          if (driverInfo.distance != null || driverInfo.etaMinutes != null)
            Row(
              children: [
                if (driverInfo.distance != null) ...[
                  Icon(Icons.straighten, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${driverInfo.distance!.toStringAsFixed(1)} km away',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                if (driverInfo.distance != null &&
                    driverInfo.etaMinutes != null)
                  const SizedBox(width: 16),
                if (driverInfo.etaMinutes != null) ...[
                  Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    '${driverInfo.etaMinutes} min',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          
          const Spacer(),
          
          // Request ride button
          if (onRequestRide != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRequestRide,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Request Ride',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }
}
