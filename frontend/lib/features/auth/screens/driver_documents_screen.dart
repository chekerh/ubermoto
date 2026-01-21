import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import '../../delivery/screens/delivery_list_screen.dart';
import '../providers/document_provider.dart';

class DriverDocumentsScreen extends ConsumerStatefulWidget {
  const DriverDocumentsScreen({super.key});

  @override
  ConsumerState<DriverDocumentsScreen> createState() => _DriverDocumentsScreenState();
}

class _DriverDocumentsScreenState extends ConsumerState<DriverDocumentsScreen> {
  final List<DocumentRequirement> _requiredDocuments = [
    DocumentRequirement(
      type: 'DRIVER_LICENSE',
      title: 'Driver License',
      description: 'Upload a clear photo of your motorcycle driver license',
      icon: Icons.badge,
    ),
    DocumentRequirement(
      type: 'ID_CARD',
      title: 'National ID Card',
      description: 'Upload a photo of your national ID card (front and back)',
      icon: Icons.credit_card,
    ),
    DocumentRequirement(
      type: 'INSURANCE',
      title: 'Motorcycle Insurance',
      description: 'Upload your motorcycle insurance certificate',
      icon: Icons.security,
    ),
    DocumentRequirement(
      type: 'VEHICLE_REGISTRATION',
      title: 'Vehicle Registration',
      description: 'Upload your motorcycle registration document',
      icon: Icons.directions_car,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(documentStateProvider);

    // Navigate to delivery list if all documents are uploaded and account is verified
    ref.listen<DocumentState>(documentStateProvider, (previous, next) {
      if (next.stats.isComplete && next.user?.isVerified == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const DeliveryListScreen(),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Complete Your Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload the required documents to start accepting deliveries',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (documentState.stats.isComplete)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Documents Under Review',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            Text(
                              'Your documents are being reviewed by our team. You will be notified once approved.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Please upload all required documents to complete your driver verification.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              ErrorMessage(message: documentState.error),
              ..._requiredDocuments.map((doc) => _DocumentUploadCard(
                requirement: doc,
                onUpload: () => _uploadDocument(doc.type),
              )),
              const SizedBox(height: 32),
              Text(
                'Progress: ${documentState.stats.approved}/${_requiredDocuments.length} documents approved',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (documentState.stats.isComplete && documentState.user?.isVerified != true)
                CustomButton(
                  text: 'Refresh Status',
                  onPressed: () => ref.read(documentStateProvider.notifier).loadDocumentStats(),
                  isLoading: documentState.isLoading,
                )
              else if (!documentState.stats.isComplete)
                CustomButton(
                  text: 'Continue Later',
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const DeliveryListScreen(),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _uploadDocument(String documentType) {
    // TODO: Implement document upload functionality
    // This would typically open a file picker and upload to the backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Document upload for $documentType - Coming soon!')),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final DocumentRequirement requirement;
  final VoidCallback onUpload;

  const _DocumentUploadCard({
    required this.requirement,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                requirement.icon,
                color: Colors.blue.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    requirement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    requirement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}

class DocumentRequirement {
  final String type;
  final String title;
  final String description;
  final IconData icon;

  DocumentRequirement({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
  });
}