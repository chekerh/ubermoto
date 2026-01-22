import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';

final driverProfileProvider = FutureProvider<UserModel>((ref) async {
  final userService = UserService();
  return userService.getProfile();
});

final driverAvailabilityProvider = StateNotifierProvider<DriverAvailabilityNotifier, DriverAvailabilityState>(
  (ref) => DriverAvailabilityNotifier(),
);

class DriverAvailabilityState {
  final bool isLoading;
  final String? error;
  final bool isAvailable;

  const DriverAvailabilityState({
    this.isLoading = false,
    this.error,
    this.isAvailable = false,
  });

  DriverAvailabilityState copyWith({
    bool? isLoading,
    String? error,
    bool? isAvailable,
  }) {
    return DriverAvailabilityState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class DriverAvailabilityNotifier extends StateNotifier<DriverAvailabilityState> {
  DriverAvailabilityNotifier() : super(const DriverAvailabilityState());

  Future<void> toggleAvailability() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement API call to update driver availability
      // For now, just toggle the local state
      final newAvailability = !state.isAvailable;
      state = state.copyWith(
        isLoading: false,
        isAvailable: newAvailability,
      );
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