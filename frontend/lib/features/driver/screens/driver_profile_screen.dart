import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';
import '../../../models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'motorcycle_screen.dart';
import 'verification_screen.dart';
import 'earnings_screen.dart';
import 'settings_screen.dart';

final driverProfileProvider = FutureProvider<UserModel>((ref) async {
  final userService = UserService();
  return userService.getProfile();
});

final driverStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // TODO: Get driver stats from backend
  return {
    'rating': 4.8,
    'totalDeliveries': 127,
    'successRate': 98.0,
    'totalEarnings': 2450.50,
  };
});

class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(driverProfileProvider);
    final statsAsync = ref.watch(driverStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DriverSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(driverProfileProvider);
          ref.invalidate(driverStatsProvider);
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
                data: (stats) => _StatsGrid(
                  rating: stats['rating'] as double,
                  totalDeliveries: stats['totalDeliveries'] as int,
                  successRate: stats['successRate'] as double,
                  totalEarnings: stats['totalEarnings'] as double,
                ),
                loading: () => const _StatsGridPlaceholder(),
                error: (_, __) => const _StatsGridPlaceholder(),
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
                    MaterialPageRoute(builder: (_) => const DriverEditProfileScreen()),
                  );
                },
              ),

              _QuickActionCard(
                icon: Icons.directions_car,
                title: 'My Motorcycle',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MotorcycleScreen()),
                  );
                },
              ),

              _QuickActionCard(
                icon: Icons.verified_user,
                title: 'Verification Status',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VerificationScreen()),
                  );
                },
              ),

              _QuickActionCard(
                icon: Icons.account_balance_wallet,
                title: 'Earnings',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EarningsScreen()),
                  );
                },
              ),
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
          MaterialPageRoute(builder: (_) => const DriverEditProfileScreen()),
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
            if (user.isVerified) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Verified Driver',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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

class _StatsGrid extends StatelessWidget {
  final double rating;
  final int totalDeliveries;
  final double successRate;
  final double totalEarnings;

  const _StatsGrid({
    required this.rating,
    required this.totalDeliveries,
    required this.successRate,
    required this.totalEarnings,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _StatCard(
          value: rating.toStringAsFixed(1),
          label: 'Rating',
          icon: Icons.star,
          color: Colors.amber,
        ),
        _StatCard(
          value: totalDeliveries.toString(),
          label: 'Deliveries',
          icon: Icons.delivery_dining,
          color: Colors.blue,
        ),
        _StatCard(
          value: '${successRate.toStringAsFixed(0)}%',
          label: 'Success Rate',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _StatCard(
          value: '${totalEarnings.toStringAsFixed(2)} TND',
          label: 'Total Earnings',
          icon: Icons.attach_money,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _StatsGridPlaceholder extends StatelessWidget {
  const _StatsGridPlaceholder();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: List.generate(
        4,
        (index) => Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
        mainAxisAlignment: MainAxisAlignment.center,
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