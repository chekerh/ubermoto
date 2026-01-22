import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/providers/auth_provider.dart';
import '../screens/driver_profile_screen.dart';

class DriverEditProfileScreen extends ConsumerStatefulWidget {
  const DriverEditProfileScreen({super.key});

  @override
  ConsumerState<DriverEditProfileScreen> createState() => _DriverEditProfileScreenState();
}

class _DriverEditProfileScreenState extends ConsumerState<DriverEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();
  
  bool _isLoading = false;
  String? _error;
  String? _avatarUrl;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userService = UserService();
      final user = await userService.getProfile();
      
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
        _avatarUrl = user.avatarUrl;
        _isVerified = user.isVerified;
      });

      // TODO: Load license number from driver profile
    } catch (e) {
      setState(() {
        _error = 'Failed to load profile: ${e.toString()}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = UserService();
      await userService.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        avatarUrl: _avatarUrl,
      );

      // Refresh user profile
      ref.invalidate(driverProfileProvider);
      ref.read(authStateProvider.notifier).refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
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
        _error = 'Failed to update profile: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickAvatar() async {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Avatar upload coming soon')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: GestureDetector(
                          onTap: _pickAvatar,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ErrorMessage(message: _error),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Phone Number',
                hint: 'Enter your phone number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Phone number is required for drivers';
                  }
                  if (value.length < 8) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'License Number',
                hint: 'Enter your driver license number',
                controller: _licenseController,
                enabled: !_isVerified, // Read-only if verified
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'License number is required';
                  }
                  return null;
                },
              ),

              if (_isVerified)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'License number cannot be changed after verification',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _saveProfile,
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
