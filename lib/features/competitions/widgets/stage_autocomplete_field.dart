import 'package:flutter/material.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/utils/app_decorations.dart';

class StageAutocompleteField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const StageAutocompleteField({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Autocomplete<DistanceStage>(
      displayStringForOption: (DistanceStage option) => option.displayName,

      optionsBuilder: (TextEditingValue textEditingValue) {
        final query = textEditingValue.text.toLowerCase().trim();
        if (query.isEmpty) return DistanceStage.values;
        return DistanceStage.values.where(
          (stage) => stage.displayName.toLowerCase().contains(query),
        );
      },

      onSelected: (DistanceStage selection) {
        controller.text = selection.displayName;
      },

      fieldViewBuilder:
          (context, internalController, focusNode, onFieldSubmitted) {
            if (internalController.text != controller.text) {
              internalController.text = controller.text;
            }
            internalController.addListener(() {
              controller.text = internalController.text;
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    'Назва етапу',
                    style: theme.textTheme.labelMedium,
                  ),
                ),
                TextFormField(
                  controller: internalController,
                  focusNode: focusNode,
                  validator: validator,
                  style: theme.textTheme.titleMedium,
                  decoration: AppDecorations.inputField(
                    theme: theme,
                    hint: 'Почніть вводити...',
                    icon: Icons.flag_outlined,
                  ),
                  onFieldSubmitted: (String value) => onFieldSubmitted(),
                ),
              ],
            );
          },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            color: Colors.white,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 250,
                maxWidth: MediaQuery.of(context).size.width - 70,
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Text(
                        option.displayName,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
