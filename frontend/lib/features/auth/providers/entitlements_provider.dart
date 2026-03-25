import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/entitlements_service.dart';

class EntitlementsState {
  final Map<String, dynamic>? payload;
  final bool isLoading;
  final String? error;

  const EntitlementsState({this.payload, this.isLoading = false, this.error});

  EntitlementsState copyWith({Map<String, dynamic>? payload, bool? isLoading, String? error}) {
    return EntitlementsState(
      payload: payload ?? this.payload,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EntitlementsNotifier extends StateNotifier<EntitlementsState> {
  EntitlementsNotifier(this._service) : super(const EntitlementsState());

  final EntitlementsService _service;

  /// Loads `/billing/me/entitlements`, optionally scoped to a merchant membership.
  Future<void> refresh({String? merchantId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = await _service.getMyEntitlements(merchantId: merchantId);
      state = state.copyWith(payload: payload, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = const EntitlementsState();
  }
}

final entitlementsServiceProvider = Provider((ref) => EntitlementsService());

final entitlementsProvider =
    StateNotifierProvider<EntitlementsNotifier, EntitlementsState>((ref) {
  return EntitlementsNotifier(ref.read(entitlementsServiceProvider));
});

