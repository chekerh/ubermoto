import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../delivery/screens/delivery_list_screen.dart';
import '../../delivery/screens/delivery_tracking_screen.dart';
import '../../delivery/screens/pickup_drop_sheet.dart';
import '../../customer/screens/profile_screen.dart';
import '../../../widgets/map/home_map_widget.dart';
import '../../../widgets/map/map_search_bar.dart';
import '../../../widgets/bottom_sheets/service_selector_sheet.dart';
import '../../../widgets/bottom_sheets/driver_info_sheet.dart';
import '../../../widgets/empty_states/no_drivers_widget.dart';
import '../../../core/map/types.dart';
import '../../motor_taxi/providers/motor_taxi_provider.dart';
import '../../motor_taxi/screens/destination_selection_sheet.dart';
import '../../../widgets/map/driver_marker.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeTab(),
    OrdersTab(),
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(nearbyDriversProvider);
    final selectedService = ref.watch(serviceSelectionProvider);
    
    // Filter available drivers
    final availableDrivers = drivers.where((d) => d.status == DriverStatus.online).toList();

    return Stack(
      children: [
        // Full-screen map
        HomeMapWidget(
          drivers: drivers,
          showUserLocation: true,
          onDriverTap: (driver) {
            // Show driver info sheet
            DriverInfoSheet.show(
              context: context,
              driverInfo: DriverInfo(
                id: driver.driverId,
                name: 'Driver ${driver.driverId}',
                rating: 4.8,
                totalRides: 150,
                vehicleInfo: 'Motorcycle',
                distance: 0.5,
                etaMinutes: 3,
              ),
            );
          },
          onMapTap: (location) {
            // Handle map tap if needed
          },
        ),

        // Empty state overlay (only show if no available drivers)
        if (availableDrivers.isEmpty)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
              child: NoDriversWidget(
                onRetry: () {
                  // Refresh driver list
                  ref.invalidate(nearbyDriversProvider);
                },
              ),
            ),
          ),

        // Search bar at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MapSearchBar(
            placeholder: 'Where to?',
            onTap: () async {
              final service = await ServiceSelectorSheet.show(
                context: context,
                initialSelection: selectedService,
              );
              if (service != null && context.mounted) {
                ref.read(serviceSelectionProvider.notifier).state = service;
                // Open destination selection
                if (service == ServiceType.motorTaxi) {
                  DestinationSelectionSheet.show(context: context);
                } else {
                      // Open delivery flow
                      await PickupDropSheet.show(context: context);
                }
              }
            },
          ),
        ),

        // Service selector at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ServiceButton(
                      icon: '🛵',
                      label: 'Motor Taxi',
                      isSelected: selectedService == ServiceType.motorTaxi,
                      onTap: () async {
                        ref.read(serviceSelectionProvider.notifier).state =
                            ServiceType.motorTaxi;
                        if (context.mounted) {
                          await DestinationSelectionSheet.show(context: context);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    _ServiceButton(
                      icon: '📦',
                      label: 'Delivery',
                      isSelected: selectedService == ServiceType.delivery,
                      onTap: () {
                        ref.read(serviceSelectionProvider.notifier).state =
                            ServiceType.delivery;
                        Navigator.of(context).pushNamed('/customer/delivery/create');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceButton extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: theme.colorScheme.primary, width: 2)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your delivery orders will appear here',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomerProfileScreen();
  }
}

// Keep old ProfileTab code for reference but use new screen
class _OldProfileTab extends StatelessWidget {
  const _OldProfileTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'John Doe', // TODO: Get from auth state
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'john.doe@example.com', // TODO: Get from auth state
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Menu Items
            _ProfileMenuItem(
              icon: Icons.location_on,
              title: 'Saved Addresses',
              onTap: () {
                // Navigate to addresses
              },
            ),

            _ProfileMenuItem(
              icon: Icons.payment,
              title: 'Payment Methods',
              onTap: () {
                // Navigate to payment methods
              },
            ),

            _ProfileMenuItem(
              icon: Icons.notifications,
              title: 'Notifications',
              onTap: () {
                // Navigate to notifications settings
              },
            ),

            _ProfileMenuItem(
              icon: Icons.help,
              title: 'Help & Support',
              onTap: () {
                // Navigate to help
              },
            ),

            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: () {
                // Handle logout
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}