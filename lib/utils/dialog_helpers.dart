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

  static Future<bool> showCodeEntryDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String cancelText,
    required String confirmText,
    required Future<bool> Function(String code) onValidate,
    String hintText = 'Введіть код...',
    String defaultErrorMessage = 'Невірний код! Спробуйте ще раз.',
  }) async {
    final codeController = TextEditingController();
    bool isCodeValid = false;
    bool isLoading = false;
    String? errorText;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (stContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(fontSize: 20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    enabled: !isLoading,
                    decoration: InputDecoration(
                      hintText: hintText,
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                        },
                  child: Text(
                    cancelText,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          if (code.isEmpty) {
                            setState(
                              () => errorText = 'Код не може бути порожнім',
                            );
                            return;
                          }

                          setState(() {
                            isLoading = true;
                            errorText = null;
                          });

                          final isValid = await onValidate(code);

                          if (isValid) {
                            isCodeValid = true;
                            if (ctx.mounted) Navigator.of(ctx).pop();
                          } else {
                            setState(() {
                              isLoading = false;
                              errorText = defaultErrorMessage;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          confirmText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    codeController.dispose();
    return isCodeValid;
  }
}
