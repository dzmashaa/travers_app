import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/features/competitions/repositories/competition_repository.dart';
import 'package:travers_app/features/competitions/controllers/distance_builder_controller.dart';
import 'package:travers_app/core/providers/role_provider.dart';
import 'package:travers_app/features/competitions/widgets/add_distance_bottom_sheet.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/error_mapper.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final competitionAsync = ref.watch(
      competitionStreamProvider(widget.competitionId),
    );

    final role = ref.watch(roleProvider).value;
    final currentUserUid = ref.watch(currentUserUidProvider);
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
                  child: _DistanceInfoCard(
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
                      child: _StageBlockCard(
                        block: block,
                        canEdit: canEdit,
                        onAddStage: () => _addStage(block),
                        onAssignJudge: () {
                          // TODO: Відкрити вікно вибору судді
                        },
                        onDeleteBlock: () => _deleteBlock(block),
                        onDeleteStage: (stageId) =>
                            _deleteStage(block.id, stageId),
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

class _DistanceInfoCard extends StatelessWidget {
  final Distance distance;
  final bool canEdit;
  final VoidCallback onEdit;

  const _DistanceInfoCard({
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

class _StageBlockCard extends StatelessWidget {
  final StageBlock block;
  final bool canEdit;
  final VoidCallback onAddStage;
  final VoidCallback onAssignJudge;
  final VoidCallback onDeleteBlock;
  final Function(String stageId) onDeleteStage;

  const _StageBlockCard({
    required this.block,
    required this.canEdit,
    required this.onAddStage,
    required this.onAssignJudge,
    required this.onDeleteBlock,
    required this.onDeleteStage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stages = block.stages ?? [];

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Судді:',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  // Тут виводимо імена суддів або "Не призначено"
                  Text(
                    block.judgeIds?.isEmpty ?? true
                        ? 'Не призначено'
                        : '2 судді',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (canEdit)
                TextButton.icon(
                  onPressed: onAssignJudge,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Призначити'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
