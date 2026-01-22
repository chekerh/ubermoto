import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/motorcycle_service.dart';
import '../../../models/motorcycle_model.dart';
import '../../motorcycles/screens/motorcycle_register_screen.dart';

final driverMotorcycleProvider = FutureProvider<MotorcycleModel?>((ref) async {
  // TODO: Get driver's motorcycle from backend
  // For now, return null as placeholder
  return null;
});

class MotorcycleScreen extends ConsumerWidget {
  const MotorcycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorcycleAsync = ref.watch(driverMotorcycleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Motorcycle'),
        elevation: 0,
      ),
      body: motorcycleAsync.when(
        data: (motorcycle) {
          if (motorcycle == null) {
            return _EmptyMotorcycleView();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 48,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${motorcycle.brand} ${motorcycle.model}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (motorcycle.year != null)
                                    Text(
                                      'Year: ${motorcycle.year}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _MotorcycleDetailRow(
                          label: 'Brand',
                          value: motorcycle.brand,
                        ),
                        _MotorcycleDetailRow(
                          label: 'Model',
                          value: motorcycle.model,
                        ),
                        if (motorcycle.capacity != null)
                          _MotorcycleDetailRow(
                            label: 'Capacity',
                            value: '${motorcycle.capacity} CC',
                          ),
                        _MotorcycleDetailRow(
                          label: 'Fuel Consumption',
                          value: '${motorcycle.fuelConsumption} L/100km',
                        ),
                        if (motorcycle.engineType != null)
                          _MotorcycleDetailRow(
                            label: 'Engine Type',
                            value: motorcycle.engineType!,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MotorcycleRegisterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Change Motorcycle'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(driverMotorcycleProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotorcycleDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _MotorcycleDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMotorcycleView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Motorcycle Registered',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your motorcycle to start accepting deliveries',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MotorcycleRegisterScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Register Motorcycle'),
            ),
          ],
        ),
      ),
    );
  }
}
