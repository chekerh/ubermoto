import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/bottom_sheets/draggable_bottom_sheet.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../core/animations/sheet_animations.dart';
import 'price_estimation_sheet.dart';

class DeliveryDetailsSheet extends ConsumerStatefulWidget {
  const DeliveryDetailsSheet({super.key});

  static Future<void> show({required BuildContext context}) {
    return DraggableBottomSheet.show(
      context: context,
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      child: const DeliveryDetailsSheet(),
    );
  }

  @override
  ConsumerState<DeliveryDetailsSheet> createState() =>
      _DeliveryDetailsSheetState();
}

class _DeliveryDetailsSheetState extends ConsumerState<DeliveryDetailsSheet> {
  final _packageTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _packageTypeController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _continueToPrice() async {
    if (_packageTypeController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      Navigator.of(context).pop();
      await PriceEstimationSheet.show(
        context: context,
        packageType: _packageTypeController.text,
        weight: double.tryParse(_weightController.text) ?? 0,
        notes: _notesController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Package type
          CustomTextField(
            label: 'Package Type',
            hint: 'e.g., Food, Document, Package',
            controller: _packageTypeController,
            prefixIcon: const Icon(Icons.inventory_2),
          ),
          
          const SizedBox(height: 16),
          
          // Weight
          CustomTextField(
            label: 'Weight (kg)',
            hint: 'Enter weight',
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.scale),
          ),
          
          const SizedBox(height: 16),
          
          // Notes
          CustomTextField(
            label: 'Notes (Optional)',
            hint: 'Special instructions',
            controller: _notesController,
            maxLines: 3,
            prefixIcon: const Icon(Icons.note),
          ),
          
          const Spacer(),
          
          // Continue button
          CustomButton(
            text: 'Continue',
            onPressed: _packageTypeController.text.isNotEmpty &&
                    _weightController.text.isNotEmpty
                ? _continueToPrice
                : null,
            isLoading: false,
          ),
        ],
      ),
    );
  }
}
