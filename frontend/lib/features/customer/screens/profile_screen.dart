import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';
import '../../../services/delivery_service.dart';
import '../../../models/user_model.dart';
import '../../../models/delivery_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'payment_methods_screen.dart';
import 'settings_screen.dart';

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final userService = UserService();
  return userService.getProfile();
});

final customerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final deliveryService = DeliveryService();
    final deliveries = await deliveryService.getDeliveries();
    
    final completedDeliveries = deliveries.where((d) => d.status == DeliveryStatus.completed).length;
    final totalSpent = deliveries
        .where((d) => d.status == DeliveryStatus.completed)
        .fold<double>(0, (sum, d) => sum + (d.estimatedCost ?? 0));

    return {
      'totalOrders': deliveries.length,
      'completedOrders': completedDeliveries,
      'totalSpent': totalSpent,
    };
  } catch (e) {
    // Return default values if there's an error
    return {
      'totalOrders': 0,
      'completedOrders': 0,
      'totalSpent': 0.0,
    };
  }
});

class CustomerProfileScreen extends ConsumerWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(customerStatsProvider);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CustomerSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(customerStatsProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header
              userAsync.when(
                data: (user) => _ProfileHeader(user: user),
                loading: () => const _ProfileHeaderPlaceholder(),
                error: (_, __) => const _ProfileHeaderPlaceholder(),
              ),

              const SizedBox(height: 24),

              // Stats Cards
              statsAsync.when(
                data: (stats) => _StatsRow(
                  totalOrders: stats['totalOrders'] as int,
                  totalSpent: stats['totalSpent'] as double,
                ),
                loading: () => const _StatsRowPlaceholder(),
                error: (_, __) => const _StatsRowPlaceholder(),
              ),

              const SizedBox(height: 24),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _QuickActionCard(
                icon: Icons.edit,
                title: 'Edit Profile',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                  );
                },
              ),

              _QuickActionCard(
                icon: Icons.location_on,
                title: 'Saved Addresses',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AddressesScreen()),
                  );
                },
              ),

              _QuickActionCard(
                icon: Icons.payment,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Recent Orders
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // TODO: Replace with actual recent deliveries
              _RecentOrdersPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        );
      },
      child: Container(
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
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            if (user.phoneNumber != null) ...[
              const SizedBox(height: 4),
              Text(
                user.phoneNumber!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderPlaceholder extends StatelessWidget {
  const _ProfileHeaderPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int totalOrders;
  final double totalSpent;

  const _StatsRow({
    required this.totalOrders,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: totalOrders.toString(),
            label: 'Total Orders',
            icon: Icons.shopping_bag,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            value: '${totalSpent.toStringAsFixed(2)} TND',
            label: 'Total Spent',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatsRowPlaceholder extends StatelessWidget {
  const _StatsRowPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 100, color: Colors.grey.shade200)),
        const SizedBox(width: 16),
        Expanded(child: Container(height: 100, color: Colors.grey.shade200)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _RecentOrdersPreview extends StatelessWidget {
  const _RecentOrdersPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.delivery_dining, color: Colors.grey),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent orders',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Your delivery history will appear here',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        ],
      ),
    );
  }
}
