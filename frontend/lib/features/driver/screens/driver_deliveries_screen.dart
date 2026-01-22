import 'package:flutter/material.dart';

class DriverDeliveriesScreen extends StatelessWidget {
  const DriverDeliveriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5, // TODO: Replace with actual deliveries
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.delivery_dining,
                  color: Colors.orange.shade700,
                ),
              ),
              title: Text('Delivery #${index + 1}'),
              subtitle: const Text('Pickup: Downtown → Delivery: Uptown'),
              trailing: Chip(
                label: const Text('In Progress'),
                backgroundColor: Colors.blue.shade100,
                labelStyle: TextStyle(color: Colors.blue.shade800),
              ),
              onTap: () {
                // TODO: Navigate to delivery details
              },
            ),
          );
        },
      ),
    );
  }
}