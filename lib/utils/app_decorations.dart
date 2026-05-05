import 'package:flutter/material.dart';

class AppDecorations {
  static InputDecoration inputField({
    required ThemeData theme,
    required String label,
    IconData? icon,
    double borderRadius = 30.0,
    bool alignLabelWithHint = false,
  }) {
    final radius = BorderRadius.circular(borderRadius);

    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
      labelText: label,
      alignLabelWithHint: alignLabelWithHint,
      labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Colors.black45),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: theme.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
