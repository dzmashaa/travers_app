import 'package:flutter/material.dart';

class JudgeChip extends StatelessWidget {
  final String judgeName;
  final bool canEdit;
  final VoidCallback onDelete;

  const JudgeChip({
    super.key,
    required this.judgeName,
    required this.canEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            judgeName,
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          if (canEdit) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 16, color: theme.primaryColor),
            ),
          ],
        ],
      ),
    );
  }
}
