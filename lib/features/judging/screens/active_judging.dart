import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/judging_target.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/features/judging/controllers/judging_timer_controller.dart';
import 'package:travers_app/features/judging/repository/judging_repository.dart';
import 'package:travers_app/features/judging/widgets/penalty_selection.dart';
import 'package:travers_app/features/judging/widgets/time_edit_dialog.dart';

class ActiveJudgingScreen extends ConsumerStatefulWidget {
  final JudgingTarget target;
  final StageBlock block;
  final String competitionId;

  const ActiveJudgingScreen({
    super.key,
    required this.target,
    required this.block,
    required this.competitionId,
  });

  @override
  ConsumerState<ActiveJudgingScreen> createState() =>
      _ActiveJudgingScreenState();
}

class _ActiveJudgingScreenState extends ConsumerState<ActiveJudgingScreen> {
  final JudgingTimerController _timerController = JudgingTimerController();
  final Map<String, List<AppliedPenalty>> _stagePenalties = {};

  @override
  void initState() {
    super.initState();
    for (var stage in widget.block.stages) {
      _stagePenalties[stage.id] = [];
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  int get _totalPoints {
    return _stagePenalties.values
        .expand((penalties) => penalties)
        .fold(0, (sum, p) => sum + p.points);
  }

  bool get _isDisqualified {
    return _stagePenalties.values
        .expand((penalties) => penalties)
        .any((p) => p.isDisqualification);
  }

  Future<void> _addPenalty(String stageId) async {
    final PenaltyRule? rule = await showModalBottomSheet<PenaltyRule>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PenaltySelectionSheet(),
    );

    if (rule != null) {
      setState(() {
        _stagePenalties[stageId]!.add(
          AppliedPenalty(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            stageId: stageId,
            penaltyCode: rule.code,
            reason: rule.reason,
            points: rule.points,
            isDisqualification: rule.isDisqualification,
          ),
        );
      });
      if (rule.mustFix) {
        if (!mounted) return;
        SnackbarUtils.show(
          context,
          'Учасник зобов\'язаний виправити помилку "${rule.code}" на етапі!',
          isError: true,
        );
      }
    }
  }

  Future<void> _saveResult() async {
    _timerController.pause();

    final confirm = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Зберегти результат?',
      content:
          'Переконайтеся, що всі штрафи вказано правильно. '
          'Після збереження результат буде відправлено на сервер, '
          'а учасник зникне зі списку очікування.',
      confirmText: 'Зберегти',
    );
    if (confirm != true) return;

    final List<AppliedPenalty> allPenalties = _stagePenalties.values
        .expand((list) => list)
        .toList();
    final currentJudgeId = ref.read(currentUserUidProvider) ?? '';
    final result = ResultModel(
      id: '',
      targetId: widget.target.id,
      blockId: widget.block.id,
      judgeId: currentJudgeId,
      timeTotalMs: _timerController.elapsedMilliseconds,
      penaltiesSum: _totalPoints,
      appliedPenalties: allPenalties,
    );
    ref
        .read(judgingRepositoryProvider)
        .saveResult(competitionId: widget.competitionId, result: result);
    if (mounted) {
      Navigator.pop(context);

      SnackbarUtils.showSafe(
        messenger: ScaffoldMessenger.of(context),
        primaryColor: Theme.of(context).primaryColor,
        message: 'Результат збережено (синхронізується автоматично)',
        isError: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(theme),
      bottomNavigationBar: _buildBottomBar(theme),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: _TimerPanel(controller: _timerController, theme: theme),
          ),
          SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: widget.block.stages.length,
              itemBuilder: (context, index) {
                final stage = widget.block.stages[index];
                return _StageJudgingCard(
                  stage: stage,
                  index: index + 1,
                  penalties: _stagePenalties[stage.id] ?? [],
                  onAddPenalty: () => _addPenalty(stage.id),
                  onRemovePenalty: (penalty) {
                    setState(() => _stagePenalties[stage.id]!.remove(penalty));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.target.title,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 20,
              color: Colors.black87,
            ),
          ),
          Text(
            widget.target.subtitle,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_isDisqualified)
                const Text(
                  'ЗНЯТТЯ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                )
              else ...[
                Text(
                  '$_totalPoints',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD32F2F),
                    height: 1,
                  ),
                ),
                const Text(
                  'балів',
                  style: TextStyle(fontSize: 12, color: Colors.grey, height: 1),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: _saveResult,
          icon: const Icon(Icons.check, color: Colors.white),
          label: const Text(
            'Зберегти результат',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimerPanel extends StatelessWidget {
  final JudgingTimerController controller;
  final ThemeData theme;

  const _TimerPanel({required this.controller, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Column(
            children: [
              Text(
                controller.formattedTime,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Courier',
                  color: Color(0xFF1B4332),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSideButton(
                    icon: Icons.refresh,
                    onTap: controller.reset,
                  ),
                  const SizedBox(width: 24),
                  InkWell(
                    onTap: controller.toggle,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        controller.isRunning ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),

                  _buildSideButton(
                    icon: Icons.edit_outlined,
                    onTap: () async {
                      controller.pause();

                      final newMilliseconds = await showDialog<int>(
                        context: context,
                        builder: (ctx) => ManualTimeEditDialog(
                          initialMilliseconds: controller.elapsedMilliseconds,
                        ),
                      );

                      if (newMilliseconds != null) {
                        controller.setTime(newMilliseconds);
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSideButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey.shade600),
      ),
    );
  }
}

class _StageJudgingCard extends StatelessWidget {
  final Stage stage;
  final int index;
  final List<AppliedPenalty> penalties;
  final VoidCallback onAddPenalty;
  final Function(AppliedPenalty) onRemovePenalty;

  const _StageJudgingCard({
    required this.stage,
    required this.index,
    required this.penalties,
    required this.onAddPenalty,
    required this.onRemovePenalty,
  });

  @override
  Widget build(BuildContext context) {
    final stageTotal = penalties.fold(0, (sum, p) => sum + p.points);
    final stageIcon = stage.passingMode.icon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '$index. ${stage.name}'),

                      if (stageIcon != null)
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              stageIcon,
                              size: 18,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  '$stageTotal б.',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: stageTotal > 0
                        ? const Color(0xFFD32F2F)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...penalties.map((penalty) => _buildPenaltyRow(penalty)),
          if (penalties.isNotEmpty) const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAddPenalty,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Додати штраф'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyRow(AppliedPenalty penalty) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              penalty.reason,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
          Text(
            penalty.isDisqualification ? 'ЗНЯТТЯ' : '${penalty.points} б.',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onRemovePenalty(penalty),
            child: Icon(Icons.close, size: 18, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
