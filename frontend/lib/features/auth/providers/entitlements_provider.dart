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

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = await _service.getMyEntitlements();
      state = state.copyWith(payload: payload, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final entitlementsServiceProvider = Provider((ref) => EntitlementsService());

final entitlementsProvider =
    StateNotifierProvider<EntitlementsNotifier, EntitlementsState>((ref) {
  return EntitlementsNotifier(ref.read(entitlementsServiceProvider));
});

