import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/aggregated_result.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/core/utils/time_extension.dart';
import 'package:travers_app/core/widgets/base_bottom_sheet.dart';
import 'package:travers_app/features/competitions/controllers/participant_result_controller.dart';
import 'package:travers_app/features/competitions/widgets/block_result_card.dart';
import 'package:travers_app/features/competitions/widgets/summary_highlight_card.dart';
import 'package:travers_app/features/judging/repository/judging_repository.dart';
import 'package:travers_app/features/judging/widgets/penalty_selection.dart';

class ParticipantDetailsBottomSheet extends ConsumerStatefulWidget {
  final String competitionId;
  final AggregatedResult result;
  final Distance distance;
  final bool isHeadJudge;

  const ParticipantDetailsBottomSheet({
    super.key,
    required this.competitionId,
    required this.result,
    required this.distance,
    required this.isHeadJudge,
  });

  @override
  ConsumerState<ParticipantDetailsBottomSheet> createState() =>
      _ParticipantDetailsBottomSheetState();
}

class _ParticipantDetailsBottomSheetState
    extends ConsumerState<ParticipantDetailsBottomSheet> {
  Future<bool> _onWillPop(bool hasChanges) async {
    if (!hasChanges) return true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Незбережені зміни'),
        content: const Text(
          'Ви внесли зміни, але не зберегли їх. Закрити і втратити зміни?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Залишитись'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Закрити', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  Future<void> _showEditTimeDialog(
    String blockId,
    int currentTimeMs,
    ParticipantDetailsController controller,
  ) async {
    final timeParts = currentTimeMs.toTimeParts();

    final minController = TextEditingController(text: timeParts.min);
    final secController = TextEditingController(text: timeParts.sec);

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редагувати час'),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Хв'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: secController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Сек'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Застосувати'),
          ),
        ],
      ),
    );

    if (isConfirmed == true && mounted) {
      final m = int.tryParse(minController.text) ?? 0;
      final s = int.tryParse(secController.text) ?? 0;
      controller.updateBlockTime(blockId, ((m * 60) + s) * 1000);
    }
  }

  Future<void> _addPenalty(
    String blockId,
    String stageId,
    ParticipantDetailsController controller,
  ) async {
    final PenaltyRule? rule = await showModalBottomSheet<PenaltyRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PenaltySelectionSheet(),
    );

    if (rule != null && mounted) {
      controller.addPenalty(blockId, stageId, rule);
    }
  }

  Future<void> _saveAllChangesToDb(AggregatedResult currentResult) async {
    try {
      SnackbarUtils.showLoading(context, 'Збереження результатів...');
      final repo = ref.read(judgingRepositoryProvider);

      for (final block in currentResult.blockResults) {
        await repo.updateResult(widget.competitionId, block);
      }

      if (mounted) {
        SnackbarUtils.hideSafe(ScaffoldMessenger.of(context));
        SnackbarUtils.show(
          context,
          'Всі результати успішно оновлено!',
          isError: false,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.hideSafe(ScaffoldMessenger.of(context));
        SnackbarUtils.show(context, 'Помилка збереження: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final args = (result: widget.result, view: widget.distance.view);

    final state = ref.watch(participantDetailsProvider(args));
    final controller = ref.read(participantDetailsProvider(args).notifier);

    final blockIdsOrder = widget.distance.stageBlocks.map((b) => b.id).toList();
    final sortedBlocks = List<ResultModel>.from(state.result.blockResults)
      ..sort(
        (a, b) => blockIdsOrder
            .indexOf(a.blockId)
            .compareTo(blockIdsOrder.indexOf(b.blockId)),
      );

    return PopScope(
      canPop: !state.hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !state.hasChanges) return;
        final shouldPop = await _onWillPop(state.hasChanges);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: BaseBottomSheet(
        title: state.result.target.title,
        subtitle: state.result.target.subtitle,
        backgroundColor: Colors.white,
        bottomButton: state.hasChanges
            ? PrimarySubmitButton(
                text: 'Зберегти результати',
                onPressed: () => _saveAllChangesToDb(state.result),
              )
            : null,

        headerAction: widget.isHeadJudge
            ? Row(
                children: [
                  Text(
                    'Ред.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: state.isEditMode,
                    activeColor: theme.colorScheme.secondary,
                    onChanged: controller.toggleEditMode,
                  ),
                ],
              )
            : null,

        child: Column(
          children: [
            SummaryHighlightCard(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              borderColor: theme.primaryColor.withValues(alpha: 0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MetricColumn(
                    title: 'Загальний час',
                    value: state.result.formattedFinalTime,
                    valueColor: theme.primaryColor,
                  ),
                  MetricColumn(
                    title: 'Штрафи',
                    value: state.result.totalPenalties.toString(),
                    valueColor: Colors.red.shade700,
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedBlocks.length,
                itemBuilder: (context, index) {
                  final blockResult = sortedBlocks[index];
                  final stageBlock = widget.distance.stageBlocks.firstWhere(
                    (b) => b.id == blockResult.blockId,
                    orElse: () => StageBlock(
                      id: blockResult.blockId,
                      blockName: 'Невідомий блок',
                      stages: [],
                    ),
                  );
                  return BlockResultCard(
                    stageBlock: stageBlock,
                    index: index + 1,
                    result: blockResult,
                    isEditMode: state.isEditMode,
                    onEditTime: () => _showEditTimeDialog(
                      blockResult.id,
                      blockResult.timeTotalMs,
                      controller,
                    ),
                    onAddPenalty: (stageId) =>
                        _addPenalty(blockResult.id, stageId, controller),
                    onRemovePenalty: (penalty) =>
                        controller.removePenalty(blockResult.id, penalty),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
