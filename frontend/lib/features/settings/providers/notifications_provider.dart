import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/notifications_inbox_service.dart';

final notificationsInboxServiceProvider = Provider<NotificationsInboxService>(
  (ref) => NotificationsInboxService(),
);

class NotificationsState {
  final List<Map<String, dynamic>> items;
  final int unreadCount;
  final bool isLoading;

  const NotificationsState({
    this.items = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationsState copyWith({
    List<Map<String, dynamic>>? items,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationsState(
      items: items ?? this.items,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsInboxService _service;

  NotificationsNotifier(this._service) : super(const NotificationsState());

  Future<void> loadNotifications({int page = 1, int limit = 20}) async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _service.getNotifications(page: page, limit: limit);
      final rawList = (result['notifications'] as List?) ?? const [];
      final unread = (result['meta']?['unreadCount'] as num?)?.toInt() ?? 0;
      final parsed = rawList.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();

      state = state.copyWith(
        items: parsed,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    final updated = state.items.map((item) {
      if (item['_id'] == id || item['id'] == id) {
        return {
          ...item,
          'isRead': true,
        };
      }
      return item;
    }).toList();

    final unread = updated.where((e) => e['isRead'] != true).length;
    state = state.copyWith(items: updated, unreadCount: unread);
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    final updated = state.items.map((item) => {...item, 'isRead': true}).toList();
    state = state.copyWith(items: updated, unreadCount: 0);
  }

  Future<void> deleteNotification(String id) async {
    await _service.deleteNotification(id);
    final updated = state.items
        .where((item) => (item['_id'] != id && item['id'] != id))
        .toList();
    final unread = updated.where((e) => e['isRead'] != true).length;
    state = state.copyWith(items: updated, unreadCount: unread);
  }
}

final notificationsStateProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.read(notificationsInboxServiceProvider));
});
