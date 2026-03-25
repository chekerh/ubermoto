import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/billing_service.dart';
import '../../../services/entitlements_service.dart';

class MerchantBillingState {
  final bool isLoading;
  final List<dynamic> plans;
  final Map<String, dynamic>? entitlements;
  final String? error;

  const MerchantBillingState({
    this.isLoading = false,
    this.plans = const [],
    this.entitlements,
    this.error,
  });

  MerchantBillingState copyWith({
    bool? isLoading,
    List<dynamic>? plans,
    Map<String, dynamic>? entitlements,
    String? error,
  }) {
    return MerchantBillingState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      entitlements: entitlements ?? this.entitlements,
      error: error,
    );
  }
}

final billingServiceProvider = Provider((ref) => BillingService());
final entitlementsServiceProvider = Provider((ref) => EntitlementsService());

class MerchantBillingNotifier extends StateNotifier<MerchantBillingState> {
  MerchantBillingNotifier(this._billing, this._entitlements) : super(const MerchantBillingState());

  final BillingService _billing;
  final EntitlementsService _entitlements;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final results = await Future.wait([
        _billing.listPlans(),
        _entitlements.getMyEntitlements(),
      ]);
      state = state.copyWith(
        isLoading: false,
        plans: results[0] as List<dynamic>,
        entitlements: results[1] as Map<String, dynamic>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final merchantBillingProvider =
    StateNotifierProvider<MerchantBillingNotifier, MerchantBillingState>((ref) {
  return MerchantBillingNotifier(
    ref.read(billingServiceProvider),
    ref.read(entitlementsServiceProvider),
  );
});

