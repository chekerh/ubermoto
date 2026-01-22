import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/user_service.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/error_message.dart';
import '../../../core/errors/app_exception.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 8) return 'Medium';
    if (!password.contains(RegExp(r'[A-Z]')) || !password.contains(RegExp(r'[0-9]'))) {
      return 'Medium';
    }
    return 'Strong';
  }

  Color _getPasswordStrengthColor(String strength) {
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userService = UserService();
      await userService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
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
        _error = 'Failed to change password: ${e.toString()}';
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
    final passwordStrength = _getPasswordStrength(_newPasswordController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
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

              CustomTextField(
                label: 'Current Password',
                hint: 'Enter your current password',
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              CustomTextField(
                label: 'New Password',
                hint: 'Enter your new password',
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (value == _currentPasswordController.text) {
                    return 'New password must be different from current password';
                  }
                  return null;
                },
              ),

              if (_newPasswordController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _getPasswordStrengthColor(passwordStrength),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      passwordStrength,
                      style: TextStyle(
                        color: _getPasswordStrengthColor(passwordStrength),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              CustomTextField(
                label: 'Confirm New Password',
                hint: 'Confirm your new password',
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              CustomButton(
                text: 'Change Password',
                isLoading: _isLoading,
                onPressed: _changePassword,
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
