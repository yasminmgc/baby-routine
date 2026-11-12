import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final int? maxLines;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.controller,
    this.maxLines = 1,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.lightGray,
      ),
    );
  }
}
