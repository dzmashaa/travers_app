import 'package:flutter/material.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/widgets/title_value_column.dart';
import 'package:travers_app/features/competitions/widgets/base_info_container.dart';

class DistanceInfoCard extends StatelessWidget {
  final Distance distance;
  final bool canEdit;
  final VoidCallback onEdit;

  const DistanceInfoCard({
    super.key,
    required this.distance,
    required this.canEdit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDescription =
        distance.description != null && distance.description!.isNotEmpty;

    return BaseInfoContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Шапка
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Основна інформація',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 18),
              ),
              if (canEdit)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.black54,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),

          TitleValueColumn(title: 'Тип', value: distance.type.displayName),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TitleValueColumn(
                  title: 'Клас',
                  value: '${distance.classLevel} клас',
                ),
              ),
              Expanded(
                child: TitleValueColumn(
                  title: 'Вид',
                  value: distance.view.displayName,
                ),
              ),
            ],
          ),

          if (hasDescription) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Опис',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.black45),
            ),
            const SizedBox(height: 4),
            Text(distance.description!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
