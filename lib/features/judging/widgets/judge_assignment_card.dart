import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';
import 'package:travers_app/core/widgets/distance_header_row.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';
import 'package:travers_app/features/judging/providers/unsynced_results_provider.dart';

class JudgeAssignmentCard extends ConsumerWidget {
  final String competitionId;
  final JudgeAssignment assignment;
  final VoidCallback onTap;

  const JudgeAssignmentCard({
    super.key,
    required this.assignment,
    required this.competitionId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final block = assignment.block;
    final hasUnsyncedDataAsync = ref.watch(
      unsyncedResultsProvider((
        competitionId: competitionId,
        blockId: block.id,
      )),
    );
    final hasUnsyncedData = hasUnsyncedDataAsync.value ?? false;

    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DistanceHeaderRow(distance: assignment.distance),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваш блок:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      block.blockName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasUnsyncedData) ...[
                Tooltip(
                  message:
                      'Є невідправлені результати. Знайдіть підключення до Інтернету.',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Очікування',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
