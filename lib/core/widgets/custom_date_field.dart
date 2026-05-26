import 'package:flutter/material.dart';
import 'package:travers_app/core/utils/app_decorations.dart';

class CustomDateField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String valueText;
  final VoidCallback onTap;

  const CustomDateField({
    super.key,
    required this.label,
    required this.icon,
    required this.valueText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaceholder = valueText == 'дд.мм.рррр';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label, style: theme.textTheme.labelMedium),
        ),

        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: InputDecorator(
            decoration: AppDecorations.inputField(
              theme: theme,
              hint: '',
              icon: icon,
            ),
            child: Text(
              valueText,
              style: isPlaceholder
                  ? theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    )
                  : theme.textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }
}
