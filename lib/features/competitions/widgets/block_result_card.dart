import 'package:flutter/material.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/utils/time_extension.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';

class BlockResultCard extends StatelessWidget {
  final StageBlock stageBlock;
  final int index;
  final ResultModel result;
  final bool isEditMode;
  final VoidCallback onEditTime;
  final Function(String stageId) onAddPenalty;
  final Function(AppliedPenalty penalty) onRemovePenalty;

  const BlockResultCard({
    super.key,
    required this.stageBlock,
    required this.index,
    required this.result,
    required this.isEditMode,
    required this.onEditTime,
    required this.onRemovePenalty,
    required this.onAddPenalty,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allPenalties = result.appliedPenalties;
    final hasError = result.penaltiesSum > 0;

    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 12),
      border: isEditMode
          ? Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              width: 1.5,
            )
          : Border.all(color: Colors.grey.shade300, width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '$index. ${stageBlock.blockName}',
                  style: theme.textTheme.labelLarge,
                ),
              ),
              _buildTimeAndPenaltyHeader(theme, hasError),
            ],
          ),

          if (stageBlock.stages.isNotEmpty || allPenalties.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            ...stageBlock.stages.asMap().entries.map((entry) {
              final stageIndex = entry.key + 1;
              final stage = entry.value;
              final stagePenalties = allPenalties
                  .where((p) => p.stageId == stage.id)
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$index.$stageIndex ${stage.name}',
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 6),

                    if (stagePenalties.isEmpty && !isEditMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Без штрафів',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...stagePenalties.map(
                        (p) => _AppliedPenaltyRow(
                          penalty: p,
                          isEditMode: isEditMode,
                          onRemove: () => onRemovePenalty(p),
                        ),
                      ),

                    if (isEditMode)
                      TextButton.icon(
                        onPressed: () => onAddPenalty(stage.id),
                        icon: const Icon(Icons.add_circle_outline, size: 16),
                        label: const Text('Додати штраф'),
                        style: TextButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeAndPenaltyHeader(ThemeData theme, bool hasError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: isEditMode ? onEditTime : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: isEditMode
                ? BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                Text(
                  result.timeTotalMs.toFormattedTime(
                    includeHundredths: false,
                  ), // ВИКОРИСТОВУЄМО РОЗШИРЕННЯ!
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                if (isEditMode) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit,
                    size: 14,
                    color: theme.colorScheme.secondary,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${result.penaltiesSum} б.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasError ? Colors.red.shade700 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _AppliedPenaltyRow extends StatelessWidget {
  final AppliedPenalty penalty;
  final bool isEditMode;
  final VoidCallback onRemove;

  const _AppliedPenaltyRow({
    required this.penalty,
    required this.isEditMode,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              penalty.reason,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            penalty.isDisqualification ? 'ЗНЯТТЯ' : '${penalty.points} б.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 13,
            ),
          ),
          if (isEditMode) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
