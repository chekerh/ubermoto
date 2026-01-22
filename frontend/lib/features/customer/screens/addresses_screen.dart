import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/address_service.dart';
import '../../../models/address_model.dart';
import '../../../widgets/error_message.dart';
import '../../../core/errors/app_exception.dart';
import 'add_address_screen.dart';

final addressesProvider = FutureProvider<List<AddressModel>>((ref) async {
  final addressService = AddressService();
  return addressService.getAddresses();
});

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Addresses'),
        elevation: 0,
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return _EmptyAddressesView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(addressesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(
                  address: address,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddAddressScreen(address: address),
                      ),
                    );
                  },
                  onSetDefault: () async {
                    await _handleSetDefault(context, ref, address.id);
                  },
                  onDelete: () async {
                    await _handleDelete(context, ref, address.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ErrorMessage(message: error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(addressesProvider);
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
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }

  Future<void> _handleSetDefault(
    BuildContext context,
    WidgetRef ref,
    String addressId,
  ) async {
    try {
      final addressService = AddressService();
      await addressService.setDefaultAddress(addressId);
      ref.invalidate(addressesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default address updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set default: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    String addressId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final addressService = AddressService();
      await addressService.deleteAddress(addressId);
      ref.invalidate(addressesProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address deleted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onTap;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onSetDefault,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: address.isDefault
              ? Theme.of(context).primaryColor
              : Colors.grey.shade300,
          child: Icon(
            _getLabelIcon(address.label),
            color: address.isDefault ? Colors.white : Colors.grey.shade600,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                address.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            if (address.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(address.address),
            const SizedBox(height: 4),
            Text('${address.city}${address.postalCode != null ? ', ${address.postalCode}' : ''}'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!address.isDefault)
              PopupMenuItem(
                onTap: () {
                  Future.delayed(Duration.zero, onSetDefault);
                },
                child: const Row(
                  children: [
                    Icon(Icons.star, size: 20),
                    SizedBox(width: 8),
                    Text('Set as Default'),
                  ],
                ),
              ),
            PopupMenuItem(
              onTap: onTap,
              child: const Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              onTap: () {
                Future.delayed(Duration.zero, onDelete);
              },
              child: const Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'work':
        return Icons.work;
      default:
        return Icons.location_on;
    }
  }
}

class _EmptyAddressesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No addresses saved',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first address to get started',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Address'),
            ),
          ],
        ),
      ),
    );
  }
}
