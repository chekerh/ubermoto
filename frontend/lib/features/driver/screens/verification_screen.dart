import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/documents_service.dart';
import '../../../models/document_model.dart';
import '../../auth/screens/driver_documents_screen.dart';

// Temporary enum mapping until we fix the model
enum DocumentType {
  DRIVER_LICENSE,
  ID_CARD,
  INSURANCE,
  VEHICLE_REGISTRATION,
}

enum DocumentStatus {
  PENDING,
  APPROVED,
  REJECTED,
}

final driverDocumentsProvider = FutureProvider<List<DocumentModel>>((ref) async {
  final documentsService = DocumentsService();
  return documentsService.getMyDocuments();
});

class VerificationScreen extends ConsumerWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(driverDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
        elevation: 0,
      ),
      body: documentsAsync.when(
        data: (documents) {
          final documentTypes = [
            DocumentType.DRIVER_LICENSE,
            DocumentType.ID_CARD,
            DocumentType.INSURANCE,
            DocumentType.VEHICLE_REGISTRATION,
          ];

          // Create a map for easier lookup
          final documentMap = <String, DocumentModel>{};
          for (var doc in documents) {
            documentMap[doc.documentType.toString()] = doc;
          }

          final allApproved = documentTypes.every((type) {
            final doc = documentMap[type.toString()];
            return doc != null && doc.status.toString() == 'DocumentStatus.approved';
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Overall Status
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: allApproved ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: allApproved ? Colors.green : Colors.orange,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        allApproved ? Icons.verified : Icons.pending,
                        size: 64,
                        color: allApproved ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        allApproved ? 'Fully Verified' : 'Verification Pending',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: allApproved ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        allApproved
                            ? 'All documents have been approved'
                            : 'Please upload and wait for approval of all required documents',
                        style: TextStyle(
                          color: allApproved ? Colors.green.shade700 : Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Document Checklist
                const Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...documentTypes.map((type) {
                  final document = documentMap[type.toString()];
                  return _DocumentChecklistItem(
                    documentType: type,
                    document: document,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DriverDocumentsScreen(),
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DriverDocumentsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Documents'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(driverDocumentsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentChecklistItem extends StatelessWidget {
  final DocumentType documentType;
  final DocumentModel? document;
  final VoidCallback onTap;

  const _DocumentChecklistItem({
    required this.documentType,
    this.document,
    required this.onTap,
  });

  String _getDocumentName() {
    switch (documentType) {
      case DocumentType.DRIVER_LICENSE:
        return 'Driver License';
      case DocumentType.ID_CARD:
        return 'ID Card';
      case DocumentType.INSURANCE:
        return 'Insurance';
      case DocumentType.VEHICLE_REGISTRATION:
        return 'Vehicle Registration';
    }
  }

  IconData _getDocumentIcon() {
    switch (documentType) {
      case DocumentType.DRIVER_LICENSE:
        return Icons.credit_card;
      case DocumentType.ID_CARD:
        return Icons.badge;
      case DocumentType.INSURANCE:
        return Icons.security;
      case DocumentType.VEHICLE_REGISTRATION:
        return Icons.description;
    }
  }

  Color _getStatusColor() {
    if (document == null) return Colors.grey;
    final statusStr = document!.status.toString();
    if (statusStr.contains('approved')) return Colors.green;
    if (statusStr.contains('rejected')) return Colors.red;
    return Colors.orange;
  }

  String _getStatusText() {
    if (document == null) return 'Not Uploaded';
    final statusStr = document!.status.toString();
    if (statusStr.contains('approved')) return 'Approved';
    if (statusStr.contains('rejected')) return 'Rejected';
    return 'Pending Review';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(
            _getDocumentIcon(),
            color: statusColor,
          ),
        ),
        title: Text(
          _getDocumentName(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: document?.rejectionReason != null
            ? Text(
                'Rejected: ${document!.rejectionReason}',
                style: const TextStyle(color: Colors.red),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
