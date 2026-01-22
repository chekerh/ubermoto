import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/address_service.dart';
import '../../../models/address_model.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import '../../../core/errors/app_exception.dart';
import 'addresses_screen.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final AddressModel? address;

  const AddAddressScreen({super.key, this.address});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _labelController.text = widget.address!.label;
      _addressController.text = widget.address!.address;
      _cityController.text = widget.address!.city;
      _postalCodeController.text = widget.address!.postalCode ?? '';
      _selectedLabel = widget.address!.label;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final addressService = AddressService();

      if (widget.address != null) {
        // Update existing address
        await addressService.updateAddress(
          widget.address!.id,
          label: _selectedLabel,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalCodeController.text.trim().isEmpty
              ? null
              : _postalCodeController.text.trim(),
          isDefault: _isDefault,
        );
      } else {
        // Create new address
        await addressService.createAddress(
          label: _selectedLabel,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          postalCode: _postalCodeController.text.trim().isEmpty
              ? null
              : _postalCodeController.text.trim(),
          isDefault: _isDefault,
        );
      }

      ref.invalidate(addressesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.address != null
                  ? 'Address updated successfully'
                  : 'Address added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save address: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address != null ? 'Edit Address' : 'Add Address'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ErrorMessage(message: _error),

              const SizedBox(height: 16),

              // Label Selection
              const Text(
                'Label',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Home', label: Text('Home'), icon: Icon(Icons.home)),
                  ButtonSegment(value: 'Work', label: Text('Work'), icon: Icon(Icons.work)),
                  ButtonSegment(value: 'Other', label: Text('Other'), icon: Icon(Icons.location_on)),
                ],
                selected: {_selectedLabel},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _selectedLabel = newSelection.first;
                    if (_selectedLabel != 'Other') {
                      _labelController.text = _selectedLabel;
                    } else {
                      _labelController.clear();
                    }
                  });
                },
              ),

              if (_selectedLabel == 'Other') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Custom Label',
                  hint: 'Enter label name',
                  controller: _labelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),

              CustomTextField(
                label: 'Address',
                hint: 'Enter street address',
                controller: _addressController,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'City',
                hint: 'Enter city',
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a city';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Postal Code',
                hint: 'Enter postal code (optional)',
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              // Set as Default Checkbox
              CheckboxListTile(
                title: const Text('Set as default address'),
                subtitle: const Text('Use this address for quick checkout'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: widget.address != null ? 'Update Address' : 'Save Address',
                isLoading: _isLoading,
                onPressed: _saveAddress,
              ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
