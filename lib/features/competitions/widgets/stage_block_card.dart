import 'package:flutter/material.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/features/competitions/widgets/judge_chip.dart';

class StageBlockCard extends StatelessWidget {
  final StageBlock block;
  final bool canEdit;
  final Map<String, String> judgesMap;
  final VoidCallback onAddStage;
  final VoidCallback onAssignJudge;
  final VoidCallback onDeleteBlock;
  final Function(String stageId) onDeleteStage;
  final Function(String judgeId) onDeleteJudge;

  const StageBlockCard({
    super.key,
    required this.block,
    required this.canEdit,
    required this.judgesMap,
    required this.onAddStage,
    required this.onAssignJudge,
    required this.onDeleteBlock,
    required this.onDeleteStage,
    required this.onDeleteJudge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stages = block.stages;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  block.blockName,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              if (canEdit)
                IconButton(
                  onPressed: onDeleteBlock,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (stages.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Етапи ще не додано',
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stages.length,
              itemBuilder: (context, i) {
                final stage = stages[i];
                final stageIcon = stage.passingMode.icon;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          stage.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (stageIcon != null) ...[
                        Icon(stageIcon, size: 18, color: theme.primaryColor),
                        const SizedBox(width: 8),
                      ],
                      if (canEdit)
                        GestureDetector(
                          onTap: () => onDeleteStage(stage.id),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

          if (canEdit)
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onAddStage,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Додати етап'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),

          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Судді:',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (canEdit)
                OutlinedButton.icon(
                  onPressed: onAssignJudge,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Призначити'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                    side: BorderSide(color: theme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          if (block.judgeIds.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: block.judgeIds.map((judgeId) {
                final judgeName = judgesMap[judgeId] ?? 'Завантаження...';

                return JudgeChip(
                  judgeName: judgeName,
                  canEdit: canEdit,
                  onDelete: () => onDeleteJudge(judgeId),
                );
              }).toList(),
            )
          else
            const Text(
              'Не призначено',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}
