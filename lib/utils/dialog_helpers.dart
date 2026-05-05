import 'package:flutter/material.dart';
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
}
