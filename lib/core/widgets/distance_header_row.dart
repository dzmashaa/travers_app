import 'package:flutter/material.dart';
import 'package:travers_app/core/models/distance.dart';

class DistanceHeaderRow extends StatelessWidget {
  final Distance distance;
  final Widget? trailing;

  const DistanceHeaderRow({super.key, required this.distance, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        distance.description != null &&
        distance.description.toString().trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                distance.type.displayName,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                distance.view.displayName,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasDescription) ...[
                const SizedBox(height: 4),
                Text(
                  distance.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${distance.classLevel} клас',
            style: TextStyle(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),

        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
