import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool? enabled;
  final int? maxLines;
  final Widget? suffixIcon;

  const CustomTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled,
    this.maxLines,
    this.suffixIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      enabled: enabled,
      maxLines: maxLines ?? (obscureText ? 1 : null),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
