import 'package:flutter/material.dart';
import 'package:travers_app/core/models/distance.dart';

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
        distance.description != null &&
        distance.description.toString().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _InfoRow(title: 'Тип', value: distance.type.displayName),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InfoRow(
                  title: 'Клас',
                  value: '${distance.classLevel} клас',
                ),
              ),
              Expanded(
                child: _InfoRow(title: 'Вид', value: distance.view.displayName),
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

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.black45),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }
}
