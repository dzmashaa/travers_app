import 'package:flutter/material.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/utils/app_decorations.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/stage_autocomplete_field.dart';
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

  static Future<String?> showAccessCodeDialog(
    BuildContext context, {
    required String title,
    required String message,
    String cancelText = 'Скасувати',
    String confirmText = 'Підтвердити',
    bool barrierDismissible = true,
  }) async {
    final controller = TextEditingController();
    final theme = Theme.of(context);
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        title: Text(
          title,
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 22),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),

            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: theme.textTheme.titleMedium,
              decoration: AppDecorations.inputField(
                theme: theme,
                hint: 'Введіть код...',
                icon: Icons.key_outlined,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: Text(
              cancelText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(ctx, code);
              } else {
                SnackbarUtils.show(
                  ctx,
                  'Код не може бути порожнім',
                  isError: true,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  static Future<String?> showTextInputDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    String confirmText = 'Зберегти',
    String cancelText = 'Скасувати',
  }) async {
    final theme = Theme.of(context);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

        title: Text(
          title,
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 22),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),

              TextFormField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.titleMedium,
                decoration: AppDecorations.inputField(
                  theme: theme,
                  hint: hintText,
                  icon: Icons.edit_note_outlined,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Будь ласка, введіть назву';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
            child: Text(
              cancelText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              confirmText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return result;
  }

  static Future<Map<String, dynamic>?> showAddStageDialog(
    BuildContext context,
  ) async {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    StagePassingMode selectedMode = StagePassingMode.standard;
    final formKey = GlobalKey<FormState>();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,

          title: Text(
            'Новий етап',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 22),
          ),

          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StageAutocompleteField(
                    controller: nameController,
                    validator: (v) => v == null || v.isEmpty
                        ? 'Оберіть або введіть назву'
                        : null,
                  ),

                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 6),
                        child: Text(
                          'Режим проходження',
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      DropdownButtonFormField<StagePassingMode>(
                        value: selectedMode,
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                        style: theme.textTheme.titleMedium,

                        decoration: AppDecorations.inputField(
                          theme: theme,
                          hint: '',
                        ),

                        items: StagePassingMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Row(
                              children: [
                                if (mode.icon != null) ...[
                                  Icon(
                                    mode.icon,
                                    size: 18,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(mode.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedMode = val);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.only(
            bottom: 16,
            right: 16,
            left: 16,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text(
                'Скасувати',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, {
                    'name': nameController.text.trim(),
                    'mode': selectedMode,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Додати',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
