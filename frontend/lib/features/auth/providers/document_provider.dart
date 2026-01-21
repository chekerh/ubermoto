import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentStateProvider = StateNotifierProvider<DocumentNotifier, DocumentState>(
  (ref) => DocumentNotifier(),
);

class DocumentState {
  final bool isLoading;
  final String? error;
  final DocumentStats stats;
  final dynamic user;

  const DocumentState({
    this.isLoading = false,
    this.error,
    this.stats = const DocumentStats(),
    this.user,
  });

  DocumentState copyWith({
    bool? isLoading,
    String? error,
    DocumentStats? stats,
    dynamic user,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      stats: stats ?? this.stats,
      user: user ?? this.user,
    );
  }
}

class DocumentStats {
  final int total;
  final int approved;
  final int pending;
  final int rejected;
  final bool isComplete;

  const DocumentStats({
    this.total = 0,
    this.approved = 0,
    this.pending = 0,
    this.rejected = 0,
    this.isComplete = false,
  });

  DocumentStats copyWith({
    int? total,
    int? approved,
    int? pending,
    int? rejected,
    bool? isComplete,
  }) {
    return DocumentStats(
      total: total ?? this.total,
      approved: approved ?? this.approved,
      pending: pending ?? this.pending,
      rejected: rejected ?? this.rejected,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class DocumentNotifier extends StateNotifier<DocumentState> {
  DocumentNotifier() : super(const DocumentState());

  Future<void> loadDocumentStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement API call to get document stats
      // For now, simulate with mock data
      await Future.delayed(const Duration(seconds: 1));

      const mockStats = DocumentStats(
        total: 4,
        approved: 3,
        pending: 1,
        rejected: 0,
        isComplete: false,
      );

      state = state.copyWith(
        isLoading: false,
        stats: mockStats,
        user: {'isVerified': false},
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load document stats',
      );
    }
  }

  Future<void> uploadDocument(String documentType, String filePath) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement document upload API call
      await Future.delayed(const Duration(seconds: 2));

      // Simulate successful upload
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload document',
      );
    }
  }
}