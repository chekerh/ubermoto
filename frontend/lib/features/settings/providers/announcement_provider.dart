import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/content_service.dart';

class AnnouncementState {
  final bool isLoading;
  final String? message;
  final bool enabled;
  final String? error;

  const AnnouncementState({
    this.isLoading = false,
    this.message,
    this.enabled = false,
    this.error,
  });

  AnnouncementState copyWith({
    bool? isLoading,
    String? message,
    bool? enabled,
    String? error,
  }) {
    return AnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      enabled: enabled ?? this.enabled,
      error: error,
    );
  }
}

final contentServiceProvider = Provider((ref) => ContentService());

class AnnouncementNotifier extends StateNotifier<AnnouncementState> {
  AnnouncementNotifier(this._content) : super(const AnnouncementState());

  final ContentService _content;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = await _content.getContent('home_announcement_banner');
      final data = (payload['data'] as Map?)?.cast<String, dynamic>() ?? const {};
      state = state.copyWith(
        isLoading: false,
        message: data['message']?.toString(),
        enabled: data['enabled'] == true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final announcementProvider =
    StateNotifierProvider<AnnouncementNotifier, AnnouncementState>((ref) {
  return AnnouncementNotifier(ref.read(contentServiceProvider));
});

