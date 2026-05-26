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
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      title: Text(
        title,
        style: theme.textTheme.displayMedium?.copyWith(fontSize: 22),
      ),

      content: Text(content, style: theme.textTheme.bodyMedium),

      actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
          child: Text(
            cancelText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? theme.colorScheme.error,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
