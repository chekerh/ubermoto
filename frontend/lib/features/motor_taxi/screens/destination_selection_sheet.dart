import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/utils/geolocation_service.dart';
import '../../../core/animations/sheet_animations.dart';
import '../../../core/map/types.dart';
import '../providers/motor_taxi_provider.dart';
import 'ride_options_sheet.dart';

class DestinationSelectionSheet extends ConsumerStatefulWidget {
  const DestinationSelectionSheet({super.key});

  static Future<void> show({required BuildContext context}) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      child: const DestinationSelectionSheet(),
    );
  }

  @override
  ConsumerState<DestinationSelectionSheet> createState() =>
      _DestinationSelectionSheetState();
}

class _DestinationSelectionSheetState
    extends ConsumerState<DestinationSelectionSheet> {
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();
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

  Future<void> _selectDestination() async {
    // In production, this would open a map picker or address autocomplete
    // For now, we'll use a simple text field
    if (_destinationController.text.isNotEmpty) {
      try {
        final locations = await GeolocationService.getLocationsFromAddress(
          _destinationController.text,
        );
        if (locations.isNotEmpty) {
          ref.read(destinationLocationProvider.notifier).state = locations.first;
          
          // Navigate to ride options
          if (mounted) {
            Navigator.of(context).pop();
            await RideOptionsSheet.show(context: context);
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
    _destinationController.dispose();
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
            'Where to?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Pickup location
          CustomTextField(
            label: 'Pickup',
            hint: 'Your current location',
            controller: _pickupController,
            enabled: false,
            suffixIcon: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
          ),
          
          const SizedBox(height: 16),
          
          // Destination
          CustomTextField(
            label: 'Destination',
            hint: 'Enter destination address',
            controller: _destinationController,
            prefixIcon: const Icon(Icons.location_on),
          ),
          
          const Spacer(),
          
          // Continue button
          CustomButton(
            text: 'Continue',
            onPressed: _destinationController.text.isNotEmpty
                ? _selectDestination
                : null,
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
