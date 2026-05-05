import 'package:flutter/material.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Видалити',
    this.cancelText = 'Скасувати',
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(
        title,
        style: theme.textTheme.displayMedium?.copyWith(fontSize: 20),
      ),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.black54),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? theme.colorScheme.error,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
