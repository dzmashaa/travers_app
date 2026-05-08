import 'package:flutter/material.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import '../../widgets/confirm_action_dialog.dart';

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

  static Future<String?> showTextInputDialog(
    BuildContext context, {
    required String title,
    required String hintText,
    String confirmText = 'Зберегти',
    String cancelText = 'Скасувати',
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.displayMedium?.copyWith(fontSize: 20),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hintText,
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontSize: 14),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Будь ласка, введіть назву';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: Text(
              cancelText,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result;
  }

  static Future<Map<String, dynamic>?> showAddStageDialog(
    BuildContext context,
  ) async {
    final nameController = TextEditingController();
    StagePassingMode selectedMode = StagePassingMode.standard;
    final formKey = GlobalKey<FormState>();

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новий етап'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Назва етапу',
                      hintText: 'Наприклад: Навісна переправа',
                      border: OutlineInputBorder(),
                    ),
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(fontSize: 14),
                    validator: (v) =>
                        v!.trim().isEmpty ? 'Введіть назву' : null,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Особливості проходження:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<StagePassingMode>(
                        value: selectedMode,
                        isExpanded: true,
                        items: StagePassingMode.values.map((mode) {
                          return DropdownMenuItem(
                            value: mode,
                            child: Text(mode.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => selectedMode = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Скасувати'),
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
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Додати'),
            ),
          ],
        ),
      ),
    );
  }
}
