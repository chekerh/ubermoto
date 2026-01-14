import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/errors/app_exception.dart';
import '../../../models/delivery_model.dart';
import '../../../services/delivery_service.dart';

final deliveryServiceProvider = Provider<DeliveryService>((ref) {
  return DeliveryService();
});

final deliveriesProvider = FutureProvider<List<DeliveryModel>>((ref) async {
  final service = ref.read(deliveryServiceProvider);
  return await service.getDeliveries();
});

final deliveryStateProvider =
    StateNotifierProvider<DeliveryNotifier, DeliveryState>(
  (ref) {
    return DeliveryNotifier(ref.read(deliveryServiceProvider), ref);
  },
);

class DeliveryState {
  final bool isLoading;
  final String? error;
  final DeliveryModel? createdDelivery;

  const DeliveryState({
    this.isLoading = false,
    this.error,
    this.createdDelivery,
  });

  DeliveryState copyWith({
    bool? isLoading,
    String? error,
    DeliveryModel? createdDelivery,
  }) {
    return DeliveryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      createdDelivery: createdDelivery ?? this.createdDelivery,
    );
  }
}

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final DeliveryService _deliveryService;
  final Ref _ref;

  DeliveryNotifier(this._deliveryService, this._ref)
      : super(const DeliveryState());

  Future<void> createDelivery({
    required String pickupLocation,
    required String deliveryAddress,
    required String deliveryType,
    double? distance,
    String? motorcycleId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final delivery = await _deliveryService.createDelivery(
        pickupLocation: pickupLocation,
        deliveryAddress: deliveryAddress,
        deliveryType: deliveryType,
        distance: distance,
        motorcycleId: motorcycleId,
      );

      state = state.copyWith(
        isLoading: false,
        createdDelivery: delivery,
      );

      // Refresh the deliveries list
      _ref.invalidate(deliveriesProvider);
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

  Future<void> updateDeliveryStatus(String deliveryId, String status) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _deliveryService.updateDeliveryStatus(deliveryId, status);

      state = state.copyWith(isLoading: false);

      // Refresh the deliveries list
      _ref.invalidate(deliveriesProvider);
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
