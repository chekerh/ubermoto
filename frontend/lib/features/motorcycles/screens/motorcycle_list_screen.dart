import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/motorcycle_provider.dart';
import '../../../models/motorcycle_model.dart';
import 'motorcycle_register_screen.dart';

class MotorcycleListScreen extends ConsumerWidget {
  const MotorcycleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final motorcyclesAsync = ref.watch(motorcyclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Motorcycles'),
        centerTitle: true,
      ),
      body: motorcyclesAsync.when(
        data: (motorcycles) {
          if (motorcycles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.two_wheeler_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No motorcycles registered',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Register your first motorcycle',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(motorcyclesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: motorcycles.length,
              itemBuilder: (context, index) {
                final motorcycle = motorcycles[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Icon(
                      Icons.two_wheeler,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      '${motorcycle.brand} ${motorcycle.model}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Fuel Consumption: ${motorcycle.fuelConsumption} L/100km',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (motorcycle.capacity != null)
                          Text(
                            'Capacity: ${motorcycle.capacity} cc',
                            style: const TextStyle(fontSize: 12),
                          ),
                        if (motorcycle.year != null)
                          Text(
                            'Year: ${motorcycle.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading motorcycles',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(motorcyclesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
    );
  }
}
