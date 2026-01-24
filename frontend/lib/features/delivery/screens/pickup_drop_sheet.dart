import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/utils/geolocation_service.dart';
import '../../../core/animations/sheet_animations.dart';
import '../../../core/map/types.dart';
import '../../motor_taxi/providers/motor_taxi_provider.dart';
import 'delivery_details_sheet.dart';

class PickupDropSheet extends ConsumerStatefulWidget {
  const PickupDropSheet({super.key});

  static Future<void> show({required BuildContext context}) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      child: const PickupDropSheet(),
    );
  }

  @override
  ConsumerState<PickupDropSheet> createState() => _PickupDropSheetState();
}

class _PickupDropSheetState extends ConsumerState<PickupDropSheet> {
  final _pickupController = TextEditingController();
  final _deliveryController = TextEditingController();
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await GeolocationService.getCurrentPosition();
      final placemarks = await GeolocationService.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks;
        final address =
            '${placemark['street']}, ${placemark['locality']}, ${placemark['country']}';
        _pickupController.text = address;
        ref.read(pickupLocationProvider.notifier).state =
            MapPoint(lat: position.latitude, lng: position.longitude);
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _continueToDetails() async {
    if (_pickupController.text.isNotEmpty &&
        _deliveryController.text.isNotEmpty) {
      try {
        final locations = await GeolocationService.getLocationsFromAddress(
          _deliveryController.text,
        );
        if (locations.isNotEmpty) {
          ref.read(destinationLocationProvider.notifier).state = locations.first;
          
          // Navigate to delivery details
          if (mounted) {
            Navigator.of(context).pop();
            await DeliveryDetailsSheet.show(context: context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find address: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Pickup location
          CustomTextField(
            label: 'Pickup Address',
            hint: 'Enter pickup address',
            controller: _pickupController,
            prefixIcon: const Icon(Icons.location_on),
            suffixIcon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            onTap: () {
              // In production, open map picker
            },
          ),
          
          const SizedBox(height: 16),
          
          // Delivery address
          CustomTextField(
            label: 'Delivery Address',
            hint: 'Enter delivery address',
            controller: _deliveryController,
            prefixIcon: const Icon(Icons.flag),
            onTap: () {
              // In production, open map picker
            },
          ),
          
          const Spacer(),
          
          // Continue button
          CustomButton(
            text: 'Continue',
            onPressed: _pickupController.text.isNotEmpty &&
                    _deliveryController.text.isNotEmpty
                ? _continueToDetails
                : null,
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
