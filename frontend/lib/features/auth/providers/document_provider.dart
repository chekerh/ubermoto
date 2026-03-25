import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/documents_service.dart';
import 'document_path_io.dart' if (dart.library.html) 'document_path_stub.dart'
    as doc_path;

final documentStateProvider = StateNotifierProvider<DocumentNotifier, DocumentState>(
  (ref) => DocumentNotifier(DocumentsService()),
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
    bool clearError = false,
    DocumentStats? stats,
    dynamic user,
  }) {
    return DocumentState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
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
  DocumentNotifier(this._documentsService) : super(const DocumentState());

  final DocumentsService _documentsService;

  Future<void> loadDocumentStats() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final raw = await _documentsService.getDocumentStats();
      final stats = DocumentStats(
        total: (raw['total'] as num?)?.toInt() ?? 0,
        approved: (raw['approved'] as num?)?.toInt() ?? 0,
        pending: (raw['pending'] as num?)?.toInt() ?? 0,
        rejected: (raw['rejected'] as num?)?.toInt() ?? 0,
        isComplete: raw['isComplete'] as bool? ?? false,
      );

      state = state.copyWith(
        isLoading: false,
        clearError: true,
        stats: stats,
        user: null,
      );
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load document stats: $e',
      );
    }
  }

  Future<void> uploadDocument(String documentType, String filePath) async {
    if (kIsWeb) {
      state = state.copyWith(
        error: 'Document upload from a file path is not supported on web — use iOS/Android.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final read = await doc_path.readLocalDocumentPath(filePath);

      await _documentsService.uploadDocument(
        documentType: documentType,
        fileBytes: read.bytes,
        fileName: read.fileName,
      );

      await loadDocumentStats();
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload document: $e',
      );
    }
  }
}
