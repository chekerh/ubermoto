import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/motorcycle_model.dart';
import '../../../services/motorcycle_service.dart';

final motorcycleServiceProvider = Provider<MotorcycleService>((ref) {
  return MotorcycleService();
});

final motorcyclesProvider = FutureProvider<List<MotorcycleModel>>((ref) async {
  final service = ref.read(motorcycleServiceProvider);
  return await service.getMotorcycles();
});

final motorcycleStateProvider =
    StateNotifierProvider<MotorcycleNotifier, MotorcycleState>(
  (ref) {
    return MotorcycleNotifier(ref.read(motorcycleServiceProvider), ref);
  },
);

class MotorcycleState {
  final bool isLoading;
  final String? error;
  final MotorcycleModel? createdMotorcycle;

  const MotorcycleState({
    this.isLoading = false,
    this.error,
    this.createdMotorcycle,
  });

  MotorcycleState copyWith({
    bool? isLoading,
    String? error,
    MotorcycleModel? createdMotorcycle,
  }) {
    return MotorcycleState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdMotorcycle: createdMotorcycle ?? this.createdMotorcycle,
    );
  }
}

class MotorcycleNotifier extends StateNotifier<MotorcycleState> {
  final MotorcycleService _motorcycleService;
  final Ref _ref;

  MotorcycleNotifier(this._motorcycleService, this._ref)
      : super(const MotorcycleState());

  Future<void> createMotorcycle(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final motorcycle = await _motorcycleService.createMotorcycle(data);
      state = state.copyWith(
        isLoading: false,
        createdMotorcycle: motorcycle,
      );

      // Refresh the motorcycles list
      _ref.invalidate(motorcyclesProvider);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> updateMotorcycle(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _motorcycleService.updateMotorcycle(id, data);
      state = state.copyWith(isLoading: false);

      // Refresh the motorcycles list
      _ref.invalidate(motorcyclesProvider);
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }
}
