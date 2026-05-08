import 'package:flutter/material.dart';

class CustomDateField extends StatelessWidget {
  const CustomDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.valueText,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String valueText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(30);
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: Colors.black54),
          label: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black45),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: const BorderSide(color: Colors.black12),
          ),
        ),
        child: Text(
          valueText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueText == 'дд.мм.рррр' ? Colors.black45 : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
