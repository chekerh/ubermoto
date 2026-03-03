import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/user_model.dart';
import '../../../services/user_service.dart';
import '../../../services/drivers_service.dart';
import '../../../services/delivery_service.dart';
import '../../../models/delivery_model.dart';

final driverProfileProvider = FutureProvider<UserModel>((ref) async {
  final userService = UserService();
  return userService.getProfile();
});

/// Stores the driver document ID (from Driver collection, not User ID)
final driverDocIdProvider = StateProvider<String?>((ref) => null);

final driversServiceProvider = Provider<DriversService>((ref) => DriversService());
final deliveryServiceProvider = Provider<DeliveryService>((ref) => DeliveryService());

final driverAvailabilityProvider = StateNotifierProvider<DriverAvailabilityNotifier, DriverAvailabilityState>(
  (ref) => DriverAvailabilityNotifier(ref),
);

/// Provider for available deliveries (for driver to accept)
final availableDeliveriesProvider = FutureProvider<List<DeliveryModel>>((ref) async {
  final service = ref.read(deliveryServiceProvider);
  return service.getAvailableDeliveries();
});

/// Provider for driver's active deliveries
final activeDeliveriesProvider = FutureProvider<List<DeliveryModel>>((ref) async {
  final service = ref.read(deliveryServiceProvider);
  return service.getActiveDriverDeliveries();
});

class DriverAvailabilityState {
  final bool isLoading;
  final String? error;
  final bool isAvailable;
  final String? driverDocId;

  const DriverAvailabilityState({
    this.isLoading = false,
    this.error,
    this.isAvailable = false,
    this.driverDocId,
  });

  DriverAvailabilityState copyWith({
    bool? isLoading,
    String? error,
    bool? isAvailable,
    String? driverDocId,
  }) {
    return DriverAvailabilityState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAvailable: isAvailable ?? this.isAvailable,
      driverDocId: driverDocId ?? this.driverDocId,
    );
  }
}

class DriverAvailabilityNotifier extends StateNotifier<DriverAvailabilityState> {
  final Ref _ref;
  
  DriverAvailabilityNotifier(this._ref) : super(const DriverAvailabilityState());

  /// Load the driver profile to get the driver document ID and current availability
  Future<void> loadDriverProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final driversService = _ref.read(driversServiceProvider);
      final profile = await driversService.getDriverProfile(userId);
      final driverDocId = profile['_id']?.toString() ?? profile['id']?.toString();
      final isAvailable = profile['isAvailable'] as bool? ?? false;
      state = state.copyWith(
        isLoading: false,
        driverDocId: driverDocId,
        isAvailable: isAvailable,
      );
      // Store the driver doc ID for other providers
      _ref.read(driverDocIdProvider.notifier).state = driverDocId;
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load driver profile');
    }
  }

  Future<void> toggleAvailability() async {
    final driverDocId = state.driverDocId;
    if (driverDocId == null) {
      state = state.copyWith(error: 'Driver profile not loaded');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final driversService = _ref.read(driversServiceProvider);
      final newAvailability = !state.isAvailable;
      await driversService.updateAvailability(driverDocId, newAvailability);
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