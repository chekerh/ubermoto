import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/delivery_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import '../../../features/motorcycles/providers/motorcycle_provider.dart';
import '../../../models/motorcycle_model.dart';
import '../../../core/utils/distance_calculator.dart';
import 'delivery_list_screen.dart';

class DeliveryCreateScreen extends ConsumerStatefulWidget {
  const DeliveryCreateScreen({super.key});

  @override
  ConsumerState<DeliveryCreateScreen> createState() =>
      _DeliveryCreateScreenState();
}

class _DeliveryCreateScreenState extends ConsumerState<DeliveryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pickupLocationController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _deliveryTypeController = TextEditingController();
  final _distanceController = TextEditingController();
  String? _selectedMotorcycleId;
  double? _estimatedCost;
  bool _isCalculatingDistance = false;

  @override
  void dispose() {
    _pickupLocationController.dispose();
    _deliveryAddressController.dispose();
    _deliveryTypeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  Future<void> _calculateDistance() async {
    if (_pickupLocationController.text.isEmpty ||
        _deliveryAddressController.text.isEmpty) {
      return;
    }

    setState(() {
      _isCalculatingDistance = true;
    });

    try {
      final distance = await DistanceCalculator.calculateDistanceBetweenAddresses(
        _pickupLocationController.text.trim(),
        _deliveryAddressController.text.trim(),
      );

      if (distance != null) {
        _distanceController.text = distance.toStringAsFixed(2);
        _calculateCost();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not calculate distance. Please enter it manually.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating distance: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculatingDistance = false;
        });
      }
    }
  }

  void _calculateCost() {
    if (_distanceController.text.isNotEmpty && _selectedMotorcycleId != null) {
      final distance = double.tryParse(_distanceController.text);
      if (distance != null && distance > 0) {
        final motorcyclesAsync = ref.read(motorcyclesProvider);
        motorcyclesAsync.whenData((motorcycles) {
          final motorcycle = motorcycles.firstWhere(
            (m) => m.id == _selectedMotorcycleId,
          );
          // Simple calculation: base fee + (distance / 100) * fuelConsumption * fuelPrice
          const baseFee = 5.0;
          const fuelPrice = 2.5; // Price per liter
          final fuelCost = (distance / 100) * motorcycle.fuelConsumption * fuelPrice;
          setState(() {
            _estimatedCost = baseFee + fuelCost;
          });
        });
      }
    }
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      final distance = _distanceController.text.isNotEmpty
          ? double.tryParse(_distanceController.text)
          : null;

      ref.read(deliveryStateProvider.notifier).createDelivery(
            pickupLocation: _pickupLocationController.text.trim(),
            deliveryAddress: _deliveryAddressController.text.trim(),
            deliveryType: _deliveryTypeController.text.trim(),
            distance: distance,
            motorcycleId: _selectedMotorcycleId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deliveryState = ref.watch(deliveryStateProvider);
    final motorcyclesAsync = ref.watch(motorcyclesProvider);

    // Navigate back to list if delivery created successfully
    ref.listen<DeliveryState>(deliveryStateProvider, (previous, next) {
      if (next.createdDelivery != null &&
          previous?.createdDelivery != next.createdDelivery) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DeliveryListScreen(),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'New Delivery',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ErrorMessage(message: deliveryState.error),
                CustomTextField(
                  label: 'Pickup Location',
                  hint: 'Enter pickup address',
                  controller: _pickupLocationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pickup location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Delivery Address',
                  hint: 'Enter delivery address',
                  controller: _deliveryAddressController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter delivery address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Delivery Type',
                  hint: 'e.g., Food, Package, Document',
                  controller: _deliveryTypeController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter delivery type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Distance (km)',
                        hint: 'Enter distance or use auto-calculate',
                        controller: _distanceController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateCost(),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final distance = double.tryParse(value);
                            if (distance == null || distance <= 0) {
                              return 'Please enter a valid distance';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isCalculatingDistance ? null : _calculateDistance,
                      icon: _isCalculatingDistance
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.location_searching),
                      label: const Text('Auto'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                motorcyclesAsync.when(
                  data: (motorcycles) {
                    if (motorcycles.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No motorcycles registered. Register one to calculate delivery costs.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedMotorcycleId,
                      decoration: const InputDecoration(
                        labelText: 'Motorcycle (for cost calculation)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: motorcycles.map((motorcycle) {
                        return DropdownMenuItem<String>(
                          value: motorcycle.id,
                          child: Text(
                            '${motorcycle.brand} ${motorcycle.model} (${motorcycle.fuelConsumption} L/100km)',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMotorcycleId = value;
                        });
                        _calculateCost();
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                if (_estimatedCost != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Estimated Cost: ${_estimatedCost!.toStringAsFixed(2)} TND',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Create Delivery',
                  isLoading: deliveryState.isLoading,
                  onPressed: _handleCreate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
