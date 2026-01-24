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
  final Widget? prefixIcon;
  final VoidCallback? onTap;

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
    this.prefixIcon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: TextFormField(
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
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16, // Increased for better touch target
          ),
        ),
      ),
    );
  }
}
