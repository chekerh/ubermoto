import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/content_service.dart';

class PricingContentState {
  final bool isLoading;
  final List<Map<String, dynamic>> plans;
  final String? error;

  const PricingContentState({
    this.isLoading = false,
    this.plans = const [],
    this.error,
  });

  PricingContentState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? plans,
    String? error,
  }) {
    return PricingContentState(
      isLoading: isLoading ?? this.isLoading,
      plans: plans ?? this.plans,
      error: error,
    );
  }
}

final pricingContentServiceProvider = Provider((ref) => ContentService());

class PricingContentNotifier extends StateNotifier<PricingContentState> {
  PricingContentNotifier(this._content) : super(const PricingContentState());

  final ContentService _content;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = await _content.getContent('pricing_table');
      final data = (payload['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      final rawPlans = (data['plans'] as List?) ?? const [];
      final plans = rawPlans
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(growable: false);
      state = state.copyWith(isLoading: false, plans: plans);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final pricingContentProvider =
    StateNotifierProvider<PricingContentNotifier, PricingContentState>((ref) {
  return PricingContentNotifier(ref.read(pricingContentServiceProvider));
});

