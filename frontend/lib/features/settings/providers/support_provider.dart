import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/support_service.dart';

final supportServiceProvider = Provider<SupportService>((ref) => SupportService());

class SupportState {
  final List<Map<String, dynamic>> tickets;
  final List<Map<String, dynamic>> faqs;
  final bool isLoading;

  const SupportState({
    this.tickets = const [],
    this.faqs = const [],
    this.isLoading = false,
  });

  SupportState copyWith({
    List<Map<String, dynamic>>? tickets,
    List<Map<String, dynamic>>? faqs,
    bool? isLoading,
  }) {
    return SupportState(
      tickets: tickets ?? this.tickets,
      faqs: faqs ?? this.faqs,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  final SupportService _service;

  SupportNotifier(this._service) : super(const SupportState());

  Future<void> loadMyTickets() async {
    state = state.copyWith(isLoading: true);
    try {
      final raw = await _service.getMyTickets();
      final tickets = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  Future<void> createTicket({
    required String subject,
    required String description,
    String priority = 'medium',
  }) async {
    final created = await _service.createTicket(
      subject: subject,
      description: description,
      priority: priority,
    );
    state = state.copyWith(tickets: [created, ...state.tickets]);
  }

  Future<void> loadFaqs({String? category}) async {
    final raw = await _service.getFaqs(category: category);
    final faqs = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    state = state.copyWith(faqs: faqs);
  }

  Future<void> submitFeedback({
    required String message,
    String type = 'app',
    int? rating,
  }) async {
    await _service.submitFeedback(message: message, type: type, rating: rating);
  }

  Future<Map<String, dynamic>> getSystemVersion() {
    return _service.getSystemVersion();
  }
}

final supportStateProvider =
    StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  return SupportNotifier(ref.read(supportServiceProvider));
});
