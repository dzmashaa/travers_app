import 'package:flutter/material.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/utils/app_decorations.dart';
import 'package:travers_app/features/competitions/widgets/stage_autocomplete_field.dart';

class AddStageDialogContent extends StatefulWidget {
  final TextEditingController nameController;
  final GlobalKey<FormState> formKey;

  const AddStageDialogContent({
    super.key,
    required this.nameController,
    required this.formKey,
  });

  @override
  State<AddStageDialogContent> createState() => _AddStageDialogContentState();
}

class _AddStageDialogContentState extends State<AddStageDialogContent> {
  StagePassingMode selectedMode = StagePassingMode.standard;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Form(
        key: widget.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StageAutocompleteField(
              controller: widget.nameController,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Оберіть або введіть назву' : null,
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

                  decoration: AppDecorations.inputField(theme: theme, hint: ''),

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
    );
  }
}
