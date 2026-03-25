import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/providers/auth_provider.dart';
import '../settings/providers/merchant_billing_provider.dart';

/// Return URLs for Stripe Checkout (test-friendly). Replace with app deep links in production.
const _kStripeMerchantSuccessUrl = 'https://example.com/nassib/merchant/billing/success';
const _kStripeMerchantCancelUrl = 'https://example.com/nassib/merchant/billing/cancel';
const _kStripePortalReturnUrl = 'https://example.com/nassib/merchant/billing/portal-return';

class MerchantHomeScreen extends ConsumerStatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  ConsumerState<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends ConsumerState<MerchantHomeScreen> {
  bool _checkoutBusy = false;
  bool _portalBusy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(merchantBillingProvider.notifier).refresh();
    });
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open billing page')),
      );
    }
  }

  Future<void> _startCheckout(String planKey) async {
    final billing = ref.read(billingServiceProvider);
    final mid = ref.read(merchantBillingProvider).selectedMerchantId;
    setState(() => _checkoutBusy = true);
    try {
      final url = await billing.createCheckoutSessionForMe(
        planKey: planKey,
        successUrl: _kStripeMerchantSuccessUrl,
        cancelUrl: _kStripeMerchantCancelUrl,
        merchantId: mid,
      );
      await _openExternalUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _checkoutBusy = false);
    }
  }

  Future<void> _openPortal() async {
    final billing = ref.read(billingServiceProvider);
    final mid = ref.read(merchantBillingProvider).selectedMerchantId;
    setState(() => _portalBusy = true);
    try {
      final url = await billing.createPortalSessionForMe(
        returnUrl: _kStripePortalReturnUrl,
        merchantId: mid,
      );
      await _openExternalUrl(url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Billing portal unavailable: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _portalBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final billingState = ref.watch(merchantBillingProvider);
    final authUser = ref.watch(authStateProvider).user;

    final summary = billingState.merchantSummary;
    final merchant = summary?['merchant'] as Map<String, dynamic>?;
    final subscription = summary?['subscription'] as Map<String, dynamic>?;
    final usage = billingState.merchantUsage;
    final products = usage?['products'] as Map<String, dynamic>?;

    final subStatus = subscription?['status']?.toString().toLowerCase() ?? '';
    final canUsePortal = subStatus == 'active' ||
        subStatus == 'trialing' ||
        subStatus == 'past_due';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: billingState.isLoading
                ? null
                : () => ref.read(merchantBillingProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login1', (_) => false);
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(merchantBillingProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (authUser != null)
              Text(
                authUser.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 8),
            if (billingState.error != null)
              MaterialBanner(
                content: Text(billingState.error!),
                actions: [
                  TextButton(
                    onPressed: () =>
                        ref.read(merchantBillingProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            if (billingState.isLoading && billingState.plans.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (billingState.memberships.length > 1) ...[
              Text('Store', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              InputDecorator(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                  labelText: 'Active store',
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: () {
                      final ids = billingState.memberships
                          .map((m) => m['merchantId']?.toString())
                          .whereType<String>()
                          .toList();
                      final sel = billingState.selectedMerchantId;
                      if (sel != null && ids.contains(sel)) return sel;
                      return ids.isNotEmpty ? ids.first : null;
                    }(),
                    items: [
                      for (final m in billingState.memberships)
                        DropdownMenuItem<String>(
                          value: m['merchantId']?.toString(),
                          child: Text(
                            (m['merchant'] is Map
                                    ? (m['merchant'] as Map)['name']
                                    : null)
                                ?.toString() ??
                                (m['merchantId']?.toString() ?? 'Merchant'),
                          ),
                        ),
                    ],
                    onChanged: (id) {
                      if (id != null) {
                        ref.read(merchantBillingProvider.notifier).selectMerchant(id);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (merchant != null) ...[
              Card(
                child: ListTile(
                  title: Text(merchant['name']?.toString() ?? 'Your store'),
                  subtitle: Text(
                    'Region: ${merchant['region'] ?? '—'} · '
                    '${merchant['isActive'] == true ? 'Active' : 'Inactive'}',
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text('Subscription', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(
                  subscription == null
                      ? 'No subscription on file'
                      : 'Plan: ${subscription['planKey'] ?? '—'}',
                ),
                subtitle: Text(
                  subscription == null
                      ? 'Choose a plan below or open the portal if you already subscribed.'
                      : 'Status: ${subscription['status'] ?? '—'}',
                ),
                trailing: canUsePortal
                    ? TextButton(
                        onPressed: _portalBusy ? null : _openPortal,
                        child: _portalBusy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Portal'),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Catalog usage', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                title: Text(
                  products == null
                      ? '—'
                      : () {
                          final used = products['used'];
                          final max = products['max'];
                          if (max == null) {
                            return '$used products (no plan cap)';
                          }
                          return '$used / $max products';
                        }(),
                ),
                subtitle: products != null && products['remaining'] != null
                    ? Text('Remaining slots: ${products['remaining']}')
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Plans', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (billingState.plans.isEmpty && !billingState.isLoading)
              const Text('No plans loaded. Is the API running and seeded?'),
            ...billingState.plans.whereType<Map>().map((p) {
              final map = Map<String, dynamic>.from(p);
              final key = map['key']?.toString() ?? '';
              final name = map['name']?.toString() ?? key;
              final desc = map['description']?.toString() ?? '';
              return Card(
                child: ListTile(
                  title: Text(name),
                  subtitle: desc.isEmpty ? null : Text(desc),
                  trailing: TextButton(
                    onPressed: (_checkoutBusy || key.isEmpty)
                        ? null
                        : () => _startCheckout(key),
                    child: _checkoutBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Subscribe'),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            if (billingState.memberships.isEmpty && !billingState.isLoading)
              const Text(
                'No merchant membership is linked to this account. '
                'Ask an admin to assign you to a store, or register a merchant account.',
              ),
          ],
        ),
      ),
    );
  }
}
