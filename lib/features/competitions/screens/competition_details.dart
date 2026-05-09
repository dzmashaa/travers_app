import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/user_role.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/providers/role_provider.dart';
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
    final distanceName = distance.type.displayName;

    final shouldDelete = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалення дистанції',
      content:
          'Ви впевнені, що хочете видалити дистанцію "$distanceName"? Цю дію неможливо скасувати.',
    );

    if (!shouldDelete || !context.mounted) return;
    try {
      await ref
          .read(competitionRepositoryProvider)
          .deleteDistance(competitionId: competitionId, distance: distance);

      if (context.mounted) {
        SnackbarUtils.show(
          context,
          'Дистанцію успішно видалено',
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
  }

  Future<void> _handleDeleteCompetition(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final shouldDelete = await DialogHelpers.showConfirmDialog(
      context,
      title: 'Видалення змагання',
      content:
          'Ви впевнені, що хочете видалити це змагання назавжди? Усі пов\'язані дані будуть втрачені.',
    );

    if (!shouldDelete || !context.mounted) return;

    try {
      await ref
          .read(competitionRepositoryProvider)
          .deleteCompetition(competitionId);

      if (context.mounted) {
        SnackbarUtils.show(
          context,
          'Змагання успішно видалено',
          isError: false,
        );

        Navigator.pop(context);
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
