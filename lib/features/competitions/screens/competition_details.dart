import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/providers/role_provider.dart';
import 'package:travers_app/features/competitions/screens/leaderboard.dart';
import 'package:travers_app/features/competitions/widgets/add_competition.dart';
import 'package:travers_app/features/competitions/widgets/add_distance_bottom_sheet.dart';
import 'package:travers_app/features/competitions/screens/distance_builder.dart';
import 'package:travers_app/core/utils/dialog_helpers.dart';
import 'package:travers_app/core/utils/error_mapper.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/comp_info_card.dart';
import 'package:travers_app/features/competitions/widgets/distance_card.dart';
import 'package:travers_app/core/widgets/stat_card.dart';

class CompetitionDetailsScreen extends ConsumerWidget {
  final String competitionId;
  final CompetitionModel initialCompetition;

  const CompetitionDetailsScreen({
    super.key,
    required this.competitionId,
    required this.initialCompetition,
  });

  void _showAddDistanceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddDistanceBottomSheet(competitionId: competitionId),
    );
  }

  Future<void> _handleDeleteDistance(
    BuildContext context,
    WidgetRef ref,
    Distance distance,
  ) async {
    final shouldDelete = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалення дистанції',
      content:
          'УВАГА: Це видалить усі блоки та збережені результати учасників для цієї дистанції. Цю дію неможливо скасувати.',
      confirmText: 'Видалити',
    );

    if (!shouldDelete) return;
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = Theme.of(context).primaryColor;

    if (context.mounted) {
      SnackbarUtils.showLoading(
        context,
        'Видалення дистанції та результатів...',
      );
    }
    try {
      await ref
          .read(competitionRepositoryProvider)
          .deleteDistanceWithResults(
            competitionId: competitionId,
            distance: distance,
          );
      SnackbarUtils.hideSafe(messenger);
      SnackbarUtils.showSafe(
        messenger: messenger,
        primaryColor: primaryColor,
        message: 'Дистанцію успішно видалено',
        isError: false,
      );
    } catch (e) {
      SnackbarUtils.hideSafe(messenger);
      SnackbarUtils.showSafe(
        messenger: messenger,
        primaryColor: primaryColor,
        message: 'Помилка: $e',
        isError: true,
      );
    }
  }

  Future<void> _handleDeleteCompetition(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалення змагання',
      content:
          'Ви впевнені, що хочете видалити це змагання назавжди? Усі пов\'язані дані (дистанції, учасники, результати) будуть втрачені без можливості відновлення.',
    );

    if (!shouldDelete || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final primaryColor = Theme.of(context).primaryColor;

    SnackbarUtils.showLoading(context, 'Видалення всіх даних змагання...');

    try {
      await ref
          .read(competitionRepositoryProvider)
          .deleteCompetition(competitionId);

      ref.invalidate(allCompetitionsStreamProvider);

      if (context.mounted) {
        Navigator.pop(context);
      }
      SnackbarUtils.hideSafe(messenger);
      SnackbarUtils.showSafe(
        messenger: messenger,
        message: 'Змагання та всі пов\'язані дані видалено',
        primaryColor: primaryColor,
        isError: false,
      );
    } catch (e) {
      SnackbarUtils.hideSafe(messenger);
      SnackbarUtils.showSafe(
        messenger: messenger,
        message: ErrorMapper.getHumanReadableMessage(e),
        primaryColor: primaryColor,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final competitionAsyncValue = ref.watch(
      competitionStreamProvider(competitionId),
    );
    final currentCompetition =
        competitionAsyncValue.asData?.value ?? initialCompetition;
    final role = ref.watch(roleProvider).value;
    final currentUserUid = ref.watch(currentUserUidProvider);
    final isCreator =
        currentUserUid != null &&
        currentUserUid == currentCompetition.headJudgeId;
    final isHeadJudge = role == UserRole.headJudge;
    final canEdit = isHeadJudge && isCreator;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: Text(
          competitionAsyncValue.asData?.value?.title ??
              initialCompetition.title,
          style: theme.textTheme.displayMedium?.copyWith(fontSize: 24),
        ),
        centerTitle: false,
        actions: [
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.black87),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddCompetitionBottomSheet(
                    competition:
                        competitionAsyncValue.asData?.value ??
                        initialCompetition,
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.group_add_outlined),
            tooltip: 'Згенерувати учасників',
            onPressed: () async {
              try {
                await ref
                    .read(competitionRepositoryProvider)
                    .generateMockParticipants(competitionId);

                if (context.mounted) {
                  SnackbarUtils.show(
                    context,
                    '10 тестових учасників успішно додано!',
                    isError: false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  SnackbarUtils.show(
                    context,
                    ErrorMapper.getHumanReadableMessage(e),
                    isError: true,
                  );
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: competitionAsyncValue.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (err, stack) =>
            Center(child: Text(ErrorMapper.getHumanReadableMessage(err))),
        data: (competition) {
          if (competition == null) {
            return const Center(child: Text('Змагання не знайдено'));
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CompInfoCard(
                        competition: competition,
                        canEdit: canEdit,
                        onDelete: () => _handleDeleteCompetition(context, ref),
                      ),
                      const SizedBox(height: 16),
                      _StatsRow(competition: competition),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Дистанції',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: 22,
                            ),
                          ),
                          if (canEdit)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddDistanceBottomSheet(context),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                                color: Colors.black87,
                              ),
                              label: const Text(
                                'Додати',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                elevation: 0,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              if (competition.distances.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyDistancesState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final distance = competition.distances[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DistanceCard(
                          distance: distance,
                          canEdit: canEdit,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DistanceBuilderScreen(
                                  competitionId: competitionId,
                                  distanceId: distance.id,
                                ),
                              ),
                            );
                          },
                          onDelete: () =>
                              _handleDeleteDistance(context, ref, distance),
                        ),
                      );
                    }, childCount: competition.distances.length),
                  ),
                ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        color: theme.scaffoldBackgroundColor,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LeaderboardScreen(
                  competitionId: competitionId,
                  competitionName: currentCompetition.title,
                ),
              ),
            );
          },
          icon: const Icon(Icons.emoji_events, color: Colors.white),
          label: Text(
            'Перейти до турнірних таблиць',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
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

class _StatsRow extends StatelessWidget {
  final CompetitionModel competition;

  const _StatsRow({required this.competition});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participantsCount = competition.participantIds.length;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            number: competition.distances.length.toString(),
            label: 'Дистанцій',
            numberColor: theme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            number: participantsCount.toString(),
            label: 'Учасників',
            numberColor: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}

class _EmptyDistancesState extends StatelessWidget {
  const _EmptyDistancesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.route_outlined, size: 48, color: theme.disabledColor),
          const SizedBox(height: 12),
          Text(
            'Дистанцій поки немає',
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
