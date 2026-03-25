import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/billing_service.dart';
import '../../../services/entitlements_service.dart';
import '../../auth/providers/entitlements_provider.dart'
    show entitlementsProvider, entitlementsServiceProvider;

class MerchantBillingState {
  final bool isLoading;
  final List<dynamic> plans;
  final Map<String, dynamic>? entitlements;
  final Map<String, dynamic>? merchantSummary;
  final Map<String, dynamic>? merchantUsage;
  final List<Map<String, dynamic>> memberships;
  final String? selectedMerchantId;
  final String? error;

  const MerchantBillingState({
    this.isLoading = false,
    this.plans = const [],
    this.entitlements,
    this.merchantSummary,
    this.merchantUsage,
    this.memberships = const [],
    this.selectedMerchantId,
    this.error,
  });

  MerchantBillingState copyWith({
    bool? isLoading,
    List<dynamic>? plans,
    Map<String, dynamic>? entitlements,
    Map<String, dynamic>? merchantSummary,
    Map<String, dynamic>? merchantUsage,
    List<Map<String, dynamic>>? memberships,
    String? selectedMerchantId,
    String? error,
  }) {
    return MerchantBillingState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      entitlements: entitlements ?? this.entitlements,
      merchantSummary: merchantSummary ?? this.merchantSummary,
      merchantUsage: merchantUsage ?? this.merchantUsage,
      memberships: memberships ?? this.memberships,
      selectedMerchantId: selectedMerchantId ?? this.selectedMerchantId,
      error: error,
    );
  }
}

final billingServiceProvider = Provider((ref) => BillingService());

class MerchantBillingNotifier extends StateNotifier<MerchantBillingState> {
  MerchantBillingNotifier(
    this._billing,
    this._entitlements, {
    required Future<void> Function(String? merchantId) syncGlobalEntitlements,
  })  : _syncGlobalEntitlements = syncGlobalEntitlements,
        super(const MerchantBillingState());

  final BillingService _billing;
  final EntitlementsService _entitlements;
  final Future<void> Function(String? merchantId) _syncGlobalEntitlements;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final memberships = await _billing.getMyMemberships();
      final selected =
          state.selectedMerchantId ??
          (memberships.isNotEmpty ? memberships.first['merchantId']?.toString() : null);
      final results = await Future.wait([
        _billing.listPlans(),
        _entitlements.getMyEntitlements(merchantId: selected),
        _billing.getMerchantSummaryForMe(merchantId: selected),
        _billing.getMerchantUsageForMe(merchantId: selected),
      ]);
      state = state.copyWith(
        isLoading: false,
        plans: results[0] as List<dynamic>,
        entitlements: results[1] as Map<String, dynamic>,
        merchantSummary: results[2] as Map<String, dynamic>,
        merchantUsage: results[3] as Map<String, dynamic>,
        memberships: memberships,
        selectedMerchantId: selected,
      );
      await _syncGlobalEntitlements(selected);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectMerchant(String merchantId) async {
    state = state.copyWith(selectedMerchantId: merchantId, isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _entitlements.getMyEntitlements(merchantId: merchantId),
        _billing.getMerchantSummaryForMe(merchantId: merchantId),
        _billing.getMerchantUsageForMe(merchantId: merchantId),
      ]);
      state = state.copyWith(
        isLoading: false,
        entitlements: results[0],
        merchantSummary: results[1],
        merchantUsage: results[2],
      );
      await _syncGlobalEntitlements(merchantId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const MerchantBillingState();
  }
}

final merchantBillingProvider =
    StateNotifierProvider<MerchantBillingNotifier, MerchantBillingState>((ref) {
  return MerchantBillingNotifier(
    ref.read(billingServiceProvider),
    ref.read(entitlementsServiceProvider),
    syncGlobalEntitlements: (merchantId) =>
        ref.read(entitlementsProvider.notifier).refresh(merchantId: merchantId),
  );
});

