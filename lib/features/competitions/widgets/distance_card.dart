import 'package:flutter/material.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';
import 'package:travers_app/core/widgets/distance_header_row.dart';

class DistanceCard extends StatelessWidget {
  final Distance distance;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DistanceCard({
    super.key,
    required this.distance,
    required this.canEdit,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseAppCard(
      onTap: onTap,
      child: DistanceHeaderRow(
        distance: distance,
        trailing: canEdit
            ? IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              )
            : null,
      ),
    );
  }
}
