import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final earningsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // TODO: Get earnings from backend
  return {
    'today': 47.50,
    'week': 247.50,
    'month': 1250.00,
    'total': 2450.50,
    'recentPayouts': [
      {'date': '2024-01-15', 'amount': 500.00, 'status': 'completed'},
      {'date': '2024-01-01', 'amount': 450.00, 'status': 'completed'},
    ],
  };
});

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsAsync = ref.watch(earningsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        elevation: 0,
      ),
      body: earningsAsync.when(
        data: (earnings) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Earnings Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade400,
                      Colors.green.shade600,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Earnings',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${earnings['total'].toStringAsFixed(2)} TND',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Earnings Breakdown
              const Text(
                'Earnings Breakdown',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _EarningsCard(
                      label: 'Today',
                      amount: earnings['today'] as double,
                      icon: Icons.today,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _EarningsCard(
                      label: 'This Week',
                      amount: earnings['week'] as double,
                      icon: Icons.calendar_view_week,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _EarningsCard(
                label: 'This Month',
                amount: earnings['month'] as double,
                icon: Icons.calendar_month,
                color: Colors.orange,
                fullWidth: true,
              ),

              const SizedBox(height: 24),

              // Earnings Chart Placeholder
              const Text(
                'Earnings Trend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Earnings Chart',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Chart visualization coming soon',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Payouts
              const Text(
                'Recent Payouts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              ...(earnings['recentPayouts'] as List).map((payout) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.green.shade700,
                      ),
                    ),
                    title: Text('${payout['amount'].toStringAsFixed(2)} TND'),
                    subtitle: Text(payout['date']),
                    trailing: Chip(
                      label: Text(payout['status']),
                      backgroundColor: Colors.green.shade50,
                      labelStyle: TextStyle(color: Colors.green.shade700),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Withdraw Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Withdrawal feature coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.account_balance_wallet),
                  label: const Text('Request Withdrawal'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(earningsProvider);
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

class _EarningsCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _EarningsCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${amount.toStringAsFixed(2)} TND',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
