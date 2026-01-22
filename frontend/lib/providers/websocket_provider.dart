import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/websocket_service.dart';

final websocketProvider = StateNotifierProvider<WebSocketNotifier, WebSocketState>(
  (ref) => WebSocketNotifier(),
);

class WebSocketState {
  final bool isConnected;
  final String? error;
  final Map<String, dynamic> lastMessage;

  const WebSocketState({
    this.isConnected = false,
    this.error,
    this.lastMessage = const {},
  });

  WebSocketState copyWith({
    bool? isConnected,
    String? error,
    Map<String, dynamic>? lastMessage,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  WebSocketNotifier() : super(const WebSocketState()) {
    _setupEventListeners();
  }

  void _setupEventListeners() {
    WebSocketService.addEventListener('delivery_status_update', (data) {
      state = state.copyWith(lastMessage: {'type': 'delivery_status_update', 'data': data});
    });

    WebSocketService.addEventListener('new_delivery', (data) {
      state = state.copyWith(lastMessage: {'type': 'new_delivery', 'data': data});
    });

    WebSocketService.addEventListener('driver_assigned', (data) {
      state = state.copyWith(lastMessage: {'type': 'driver_assigned', 'data': data});
    });

    WebSocketService.addEventListener('location_update', (data) {
      state = state.copyWith(lastMessage: {'type': 'location_update', 'data': data});
    });
  }

  Future<void> connect() async {
    try {
      await WebSocketService.connect();
      state = state.copyWith(isConnected: WebSocketService.isConnected, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void disconnect() {
    WebSocketService.disconnect();
    state = state.copyWith(isConnected: false);
  }

  void subscribeToDelivery(String deliveryId) {
    WebSocketService.subscribeToDelivery(deliveryId);
  }

  void updateLocation(String deliveryId, double latitude, double longitude) {
    WebSocketService.updateLocation(deliveryId, latitude, longitude);
  }

  @override
  void dispose() {
    WebSocketService.disconnect();
    super.dispose();
  }
}