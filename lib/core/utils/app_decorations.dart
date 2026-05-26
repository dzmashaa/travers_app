import 'package:flutter/material.dart';

class AppDecorations {
  static InputDecoration inputField({
    required ThemeData theme,
    required String hint,
    IconData? icon,
    double borderRadius = 16.0,
    bool alignLabelWithHint = false,
  }) {
    final radius = BorderRadius.circular(borderRadius);

    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,

      prefixIcon: icon != null
          ? Icon(icon, color: Colors.grey.shade500, size: 22)
          : null,

      hintText: hint,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade800,
      ),
      alignLabelWithHint: alignLabelWithHint,

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: theme.primaryColor, width: 1.5),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    );
  }
}
