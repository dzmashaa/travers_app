import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/aggregated_result.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/providers/leaderboard_provider.dart';
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
  bool _isEditMode = false;
  bool _hasChanges = false;
  late AggregatedResult _localResult;
  late int _penaltyMultiplierMs;

  @override
  void initState() {
    super.initState();
    _localResult = widget.result;
    _penaltyMultiplierMs = getPenaltyMultiplierMs(widget.distance.view);
  }

  void _updateLocalBlockResult(ResultModel updatedBlock) {
    final newBlocks = _localResult.blockResults.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();

    int pureTimeSum = 0;
    int penaltySum = 0;
    for (final b in newBlocks) {
      pureTimeSum += b.timeTotalMs;
      penaltySum += b.penaltiesSum;
    }

    final finalTimeMs = pureTimeSum + (penaltySum * _penaltyMultiplierMs);

    setState(() {
      _localResult = _localResult.copyWith(
        blockResults: newBlocks,
        pureTimeMs: pureTimeSum,
        totalPenalties: penaltySum,
        finalCalculatedTimeMs: finalTimeMs,
      );
      _hasChanges = true;
    });
  }

  Future<void> _showEditTimeDialog(ResultModel blockResult) async {
    final int secondsTotal = (blockResult.timeTotalMs / 1000).truncate();
    final minController = TextEditingController(
      text: (secondsTotal / 60).truncate().toString(),
    );
    final secController = TextEditingController(
      text: (secondsTotal % 60).toString(),
    );

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редагувати час етапу'),
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

    if (isConfirmed == true) {
      final m = int.tryParse(minController.text) ?? 0;
      final s = int.tryParse(secController.text) ?? 0;
      final updatedResult = blockResult.copyWith(
        timeTotalMs: ((m * 60) + s) * 1000,
      );
      _updateLocalBlockResult(updatedResult);
    }
  }

  Future<void> _addPenalty(String stageId, ResultModel blockResult) async {
    final PenaltyRule? rule = await showModalBottomSheet<PenaltyRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PenaltySelectionSheet(),
    );

    if (rule != null) {
      final newPenalty = AppliedPenalty(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stageId: stageId,
        penaltyCode: rule.code,
        reason: rule.reason,
        points: rule.points,
        isDisqualification: rule.isDisqualification,
      );

      final currentPenalties = List<AppliedPenalty>.from(
        blockResult.appliedPenalties ?? [],
      );
      currentPenalties.add(newPenalty);

      final newPenaltiesSum = currentPenalties.fold(
        0,
        (sum, p) => sum + p.points,
      );

      final updatedResult = blockResult.copyWith(
        appliedPenalties: currentPenalties,
        penaltiesSum: newPenaltiesSum,
      );
      _updateLocalBlockResult(updatedResult);
    }
  }

  void _removePenalty(ResultModel blockResult, AppliedPenalty penaltyToRemove) {
    final currentPenalties = List<AppliedPenalty>.from(
      blockResult.appliedPenalties ?? [],
    );
    currentPenalties.removeWhere((p) => p == penaltyToRemove);
    final newPenaltiesSum = currentPenalties.fold(
      0,
      (sum, p) => sum + p.points,
    );

    final updatedResult = blockResult.copyWith(
      appliedPenalties: currentPenalties,
      penaltiesSum: newPenaltiesSum,
    );
    _updateLocalBlockResult(updatedResult);
  }

  Future<void> _saveAllChangesToDb() async {
    try {
      SnackbarUtils.showLoading(context, 'Збереження результатів...');
      final repo = ref.read(judgingRepositoryProvider);

      for (final block in _localResult.blockResults) {
        await repo.updateResult(widget.competitionId, block);
      }

      setState(() => _hasChanges = false);

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

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final blockIdsOrder =
        widget.distance.stageBlocks?.map((b) => b.id).toList() ?? [];

    final sortedBlocks = List<ResultModel>.from(_localResult.blockResults)
      ..sort(
        (a, b) => blockIdsOrder
            .indexOf(a.blockId)
            .compareTo(blockIdsOrder.indexOf(b.blockId)),
      );

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _localResult.target.title,
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 22,
                              ),
                            ),
                            Text(
                              _localResult.target.subtitle,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.isHeadJudge)
                        Row(
                          children: [
                            const Text(
                              'Ред.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Switch(
                              value: _isEditMode,
                              activeColor: theme.primaryColor,
                              onChanged: (val) =>
                                  setState(() => _isEditMode = val),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Відступи та плашка для загального часу виправлені!
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(
                      16,
                    ), // Трохи збільшили відступи всередині
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Більш заокруглені кути
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Загальний час',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _localResult.formattedFinalTime,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Штрафи',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_localResult.totalPenalties} б.',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Деталізація по етапах',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),

                Flexible(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 80,
                    ),
                    shrinkWrap: true,
                    itemCount: sortedBlocks.length,
                    itemBuilder: (context, index) {
                      final blockResult = sortedBlocks[index];
                      final stageBlock = widget.distance.stageBlocks
                          ?.firstWhere(
                            (b) => b.id == blockResult.blockId,
                            orElse: () => StageBlock(
                              id: blockResult.blockId,
                              blockName: 'Невідомий блок',
                              stages: [],
                            ),
                          );
                      if (stageBlock == null) return const SizedBox.shrink();

                      return _BlockResultCard(
                        stageBlock: stageBlock,
                        index: index + 1,
                        result: blockResult,
                        isEditMode: _isEditMode,
                        onEditTime: () => _showEditTimeDialog(blockResult),
                        onRemovePenalty: (penalty) =>
                            _removePenalty(blockResult, penalty),
                        onAddPenalty: (stageId) =>
                            _addPenalty(stageId, blockResult),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_hasChanges)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                onPressed: _saveAllChangesToDb,
                child: const Text(
                  'Зберегти результати',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget overlayBuild(BuildContext context) {
    if (!_hasChanges) return const SizedBox.shrink();
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: _saveAllChangesToDb,
        child: const Text(
          'Зберегти зміни',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _BlockResultCard extends StatelessWidget {
  final StageBlock stageBlock;
  final int index;
  final ResultModel result;
  final bool isEditMode;
  final VoidCallback onEditTime;
  final Function(String) onAddPenalty;
  final Function(AppliedPenalty) onRemovePenalty;

  const _BlockResultCard({
    required this.stageBlock,
    required this.index,
    required this.result,
    required this.isEditMode,
    required this.onEditTime,
    required this.onRemovePenalty,
    required this.onAddPenalty,
  });

  String _formatTime(int milliseconds) {
    final int seconds = (milliseconds / 1000).truncate();
    final int minutes = (seconds / 60).truncate();
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final allPenalties = result.appliedPenalties ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEditMode
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : Colors.grey.shade300,
          width: isEditMode ? 1.5 : 1,
        ),
      ),
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: isEditMode ? onEditTime : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: isEditMode
                          ? BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: Row(
                        children: [
                          Text(
                            _formatTime(result.timeTotalMs),
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (isEditMode) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.blue,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.penaltiesSum} б.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: result.penaltiesSum > 0
                          ? const Color(0xFFD32F2F)
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 6),

                    if (stagePenalties.isEmpty && !isEditMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          'Без штрафів',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      ...stagePenalties.map((p) => _buildPenaltyRow(p)),

                    if (isEditMode) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 32,
                        child: TextButton.icon(
                          onPressed: () => onAddPenalty(stage.id),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            'Додати штраф',
                            style: TextStyle(fontSize: 13),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            foregroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPenaltyRow(AppliedPenalty penalty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              penalty.reason,
              style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
            ),
          ),
          Text(
            penalty.isDisqualification ? 'ЗНЯТТЯ' : '${penalty.points} б.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD32F2F),
              fontSize: 13,
            ),
          ),

          if (isEditMode) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => onRemovePenalty(penalty),
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
