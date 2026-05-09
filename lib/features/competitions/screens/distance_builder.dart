import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/features/competitions/controllers/distance_builder_controller.dart';
import 'package:travers_app/core/providers/role_provider.dart';
import 'package:travers_app/features/competitions/widgets/add_distance_bottom_sheet.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/error_mapper.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/assign_judges.dart';
import 'package:travers_app/features/competitions/widgets/distance_info_card.dart';
import 'package:travers_app/features/competitions/widgets/stage_block_card.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';

class DistanceBuilderScreen extends ConsumerStatefulWidget {
  final String competitionId;
  final String distanceId;

  const DistanceBuilderScreen({
    super.key,
    required this.competitionId,
    required this.distanceId,
  });
  @override
  ConsumerState<DistanceBuilderScreen> createState() =>
      _DistanceBuilderScreenState();
}

class _DistanceBuilderScreenState extends ConsumerState<DistanceBuilderScreen> {
  void _editDistanceInfo(BuildContext context, dynamic distance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDistanceBottomSheet(
        competitionId: widget.competitionId,
        initialDistance: distance,
      ),
    );
  }

  Future<void> _addBlock() async {
    final blockName = await DialogHelpers.showTextInputDialog(
      context,
      title: 'Назва блоку',
      hintText: 'Блок 1',
      confirmText: 'Додати',
    );

    if (blockName == null || !mounted) return;
    final success = await ref
        .read(distanceBuilderControllerProvider.notifier)
        .addBlock(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockName: blockName,
        );

    if (success && mounted) {
      SnackbarUtils.show(context, 'Блок успішно додано', isError: false);
    }
  }

  Future<void> _addStage(StageBlock block) async {
    final result = await DialogHelpers.showAddStageDialog(context);
    if (result == null || !mounted) return;

    final success = await ref
        .read(distanceBuilderControllerProvider.notifier)
        .addStage(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockId: block.id,
          stageName: result['name'],
          passingMode: result['mode'],
        );

    if (success && mounted) {
      SnackbarUtils.show(context, 'Етап додано', isError: false);
    }
  }

  Future<void> _deleteBlock(StageBlock block) async {
    final confirm = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалити блок?',
      content: 'Це видалить блок "${block.blockName}".',
    );

    if (!confirm || !mounted) return;

    final success = await ref
        .read(distanceBuilderControllerProvider.notifier)
        .deleteBlock(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockId: block.id,
        );

    if (success && mounted) {
      SnackbarUtils.show(context, 'Блок видалено', isError: false);
    }
  }

  Future<void> _deleteStage(String blockId, String stageId) async {
    await ref
        .read(distanceBuilderControllerProvider.notifier)
        .deleteStage(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockId: blockId,
          stageId: stageId,
        );
  }

  Future<void> _assignJudges(
    StageBlock block,
    Map<String, String> judgesMap,
  ) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignJudgesBottomSheet(
        allCompetitionJudges: judgesMap,
        initialSelectedIds: block.judgeIds ?? [],
      ),
    );
    if (result == null || !mounted) return;
    await ref
        .read(distanceBuilderControllerProvider.notifier)
        .updateBlockJudges(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockId: block.id,
          judgeIds: result,
        );
  }

  Future<void> _deleteJudge(StageBlock block, String judgeId) async {
    final currentJudges = List<String>.from(block.judgeIds ?? []);

    currentJudges.remove(judgeId);
    await ref
        .read(distanceBuilderControllerProvider.notifier)
        .updateBlockJudges(
          competitionId: widget.competitionId,
          distanceId: widget.distanceId,
          blockId: block.id,
          judgeIds: currentJudges,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final competitionAsync = ref.watch(
      competitionStreamProvider(widget.competitionId),
    );

    final role = ref.watch(roleProvider).value;
    final currentUserUid = ref.watch(currentUserUidProvider);

    final competition = ref
        .watch(competitionStreamProvider(widget.competitionId))
        .value;
    final judgesMapAsync = ref.watch(
      competitionJudgesMapProvider(competition?.judgeIds ?? []),
    );
    final judgesMap = judgesMapAsync.value ?? {};
    ref.listen(distanceBuilderControllerProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        SnackbarUtils.show(
          context,
          ErrorMapper.getHumanReadableMessage(next.error!),
          isError: true,
        );
      }
    });
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Конструктор',
              style: theme.textTheme.displayMedium?.copyWith(fontSize: 22),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: competitionAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (err, stack) => Center(child: Text('Помилка: $err')),
        data: (competition) {
          if (competition == null) {
            return const Center(child: Text('Змагання не знайдено'));
          }

          final distance = competition.distances.firstWhere(
            (d) => d.id == widget.distanceId,
            orElse: () => throw Exception('Дистанцію не знайдено'),
          );

          final isCreator = currentUserUid == competition.headJudgeId;
          final canEdit =
              role == UserRole.headJudge &&
              isCreator &&
              competition.status != CompetitionStatus.completed;

          final blocks = distance.stageBlocks ?? [];

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: DistanceInfoCard(
                    distance: distance,
                    canEdit: canEdit,
                    onEdit: () => _editDistanceInfo(context, distance),
                  ),
                ),
              ),
              if (blocks.isNotEmpty || canEdit)
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    bottom: 12,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Блоки етапів',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final block = blocks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StageBlockCard(
                        block: block,
                        canEdit: canEdit,
                        judgesMap: judgesMap,
                        onAddStage: () => _addStage(block),
                        onAssignJudge: () => _assignJudges(block, judgesMap),
                        onDeleteBlock: () => _deleteBlock(block),
                        onDeleteStage: (stageId) =>
                            _deleteStage(block.id, stageId),
                        onDeleteJudge: (judgeId) =>
                            _deleteJudge(block, judgeId),
                      ),
                    );
                  }, childCount: blocks.length),
                ),
              ),

              if (canEdit)
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverToBoxAdapter(
                    child: OutlinedButton.icon(
                      onPressed: _addBlock,
                      icon: const Icon(Icons.add),
                      label: const Text('Додати блок етапів'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(
                          color: theme.primaryColor.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }
}
