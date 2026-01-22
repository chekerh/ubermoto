import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config/app_config.dart';
import '../core/utils/storage_service.dart';

class WebSocketService {
  static io.Socket? _socket;
  static final Map<String, Function(dynamic)> _eventListeners = {};

  static Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      return;
    }

    final token = await StorageService.getToken();
    if (token == null) {
      return;
    }

    _socket = io.io('${AppConfig.baseUrl.replaceFirst('http', 'ws')}/delivery', {
      'transports': ['websocket'],
      'auth': {'token': token},
    });

    _socket!.onConnect((_) {
      print('WebSocket connected');
    });

    _socket!.onDisconnect((_) {
      print('WebSocket disconnected');
    });

    _socket!.onConnectError((error) {
      print('WebSocket connection error: $error');
    });

    // Listen for delivery status updates
    _socket!.on('delivery_status_update', (data) {
      _notifyListeners('delivery_status_update', data);
    });

    // Listen for new deliveries (for drivers)
    _socket!.on('new_delivery', (data) {
      _notifyListeners('new_delivery', data);
    });

    // Listen for driver assignments
    _socket!.on('driver_assigned', (data) {
      _notifyListeners('driver_assigned', data);
    });

    // Listen for driver availability updates
    _socket!.on('driver_status_update', (data) {
      _notifyListeners('driver_status_update', data);
    });

    // Listen for location updates
    _socket!.on('location_update', (data) {
      _notifyListeners('location_update', data);
    });

    _socket!.connect();
  }

  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _eventListeners.clear();
  }

  static void subscribeToDelivery(String deliveryId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('subscribe_to_delivery', {'deliveryId': deliveryId});
    }
  }

  static void unsubscribeFromDelivery(String deliveryId) {
    if (_socket?.connected ?? false) {
      _socket!.emit('unsubscribe_from_delivery', {'deliveryId': deliveryId});
    }
  }

  static void updateLocation(String deliveryId, double latitude, double longitude) {
    if (_socket?.connected ?? false) {
      _socket!.emit('update_location', {
        'deliveryId': deliveryId,
        'latitude': latitude,
        'longitude': longitude,
      });
    }
  }

  static void addEventListener(String event, Function(dynamic) callback) {
    _eventListeners[event] = callback;
  }

  static void removeEventListener(String event) {
    _eventListeners.remove(event);
  }

  static void _notifyListeners(String event, dynamic data) {
    final listener = _eventListeners[event];
    if (listener != null) {
      listener(data);
    }
  }

  static bool get isConnected => _socket?.connected ?? false;
}