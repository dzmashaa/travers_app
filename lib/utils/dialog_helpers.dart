import 'package:flutter/material.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import '../widgets/confirm_action_dialog.dart';

class DialogHelpers {
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Видалити',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmActionDialog(
        title: title,
        content: content,
        confirmText: confirmText,
      ),
    );

    return result ?? false;
  }

  static Future<bool> showAccessCodeDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String correctCode,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Введіть код...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Продовжити як Суддя',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim() == correctCode) {
                Navigator.pop(ctx, true);
              } else {
                SnackbarUtils.show(
                  ctx,
                  'Невірний код! Спробуйте ще раз.',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Підтвердити'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
