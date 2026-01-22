import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/motorcycle_provider.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import 'motorcycle_list_screen.dart';

class MotorcycleRegisterScreen extends ConsumerStatefulWidget {
  const MotorcycleRegisterScreen({super.key});

  @override
  ConsumerState<MotorcycleRegisterScreen> createState() =>
      _MotorcycleRegisterScreenState();
}

class _MotorcycleRegisterScreenState
    extends ConsumerState<MotorcycleRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _fuelConsumptionController = TextEditingController();
  final _engineTypeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void dispose() {
    _modelController.dispose();
    _brandController.dispose();
    _fuelConsumptionController.dispose();
    _engineTypeController.dispose();
    _capacityController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      final data = <String, dynamic>{
        'model': _modelController.text.trim(),
        'brand': _brandController.text.trim(),
        'fuelConsumption': double.parse(_fuelConsumptionController.text),
      };


      if (_engineTypeController.text.isNotEmpty) {
        data['engineType'] = _engineTypeController.text.trim();
      }

      if (_capacityController.text.isNotEmpty) {
        data['capacity'] = int.parse(_capacityController.text);
      }

      if (_yearController.text.isNotEmpty) {
        data['year'] = int.parse(_yearController.text);
      }

      ref.read(motorcycleStateProvider.notifier).createMotorcycle(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final motorcycleState = ref.watch(motorcycleStateProvider);

    // Navigate back to list if motorcycle created successfully
    ref.listen<MotorcycleState>(motorcycleStateProvider, (previous, next) {
      if (next.createdMotorcycle != null &&
          previous?.createdMotorcycle != next.createdMotorcycle) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const MotorcycleListScreen(),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Motorcycle'),
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
                  'Motorcycle Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your motorcycle details for accurate cost calculation',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ErrorMessage(message: motorcycleState.error),
                CustomTextField(
                  label: 'Brand *',
                  hint: 'e.g., Honda, Yamaha',
                  controller: _brandController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the brand';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Model *',
                  hint: 'e.g., Forza, MT-07',
                  controller: _modelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the model';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Fuel Consumption (L/100km) *',
                  hint: 'e.g., 3.5',
                  controller: _fuelConsumptionController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter fuel consumption';
                    }
                    final consumption = double.tryParse(value);
                    if (consumption == null || consumption <= 0 || consumption > 20) {
                      return 'Please enter a valid consumption (0.1 - 20 L/100km)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Engine Type',
                  hint: 'e.g., 4-stroke, 2-stroke',
                  controller: _engineTypeController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Capacity (cc)',
                  hint: 'e.g., 300',
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final capacity = int.tryParse(value);
                      if (capacity == null || capacity < 50 || capacity > 2000) {
                        return 'Please enter a valid capacity (50-2000 cc)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Year',
                  hint: 'e.g., 2020',
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final year = int.tryParse(value);
                      if (year == null || year < 1950 || year > 2030) {
                        return 'Please enter a valid year (1950-2030)';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Register Motorcycle',
                  isLoading: motorcycleState.isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
