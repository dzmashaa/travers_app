import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/competition.dart';
import 'package:travers_app/models/distance.dart';
import 'package:travers_app/providers/competition_provider.dart';
import 'package:travers_app/screens/add_competition.dart';
import 'package:travers_app/screens/add_distance_bottom_sheet.dart';
import 'package:travers_app/utils/date_formatters.dart';
import 'package:travers_app/utils/dialog_helpers.dart';
import 'package:travers_app/utils/error_mapper.dart';
import 'package:travers_app/utils/snackbar_utils.dart';
import 'package:travers_app/widgets/comp_status.dart';
import 'package:travers_app/widgets/distance_card.dart';
import 'package:travers_app/widgets/stat_card.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final competitionAsyncValue = ref.watch(
      competitionStreamProvider(competitionId),
    );

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
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCompetitionScreen(
                    competition:
                        competitionAsyncValue.asData?.value ??
                        initialCompetition,
                  ),
                ),
              );
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
                      _MainInfoCard(competition: competition),
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
                          onTap: () {
                            // TODO: Перехід на екрапн етапів
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

class _MainInfoCard extends StatelessWidget {
  final CompetitionModel competition;

  const _MainInfoCard({required this.competition});

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: competition.inviteCode));
    SnackbarUtils.show(context, 'Код скопійовано!', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
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
              CompStatusBadge(status: competition.status, fontSize: 14.0),
              GestureDetector(
                onTap: () => _copyCode(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 14, color: theme.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        competition.inviteCode,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 20,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Text(
                competition.location,
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                size: 20,
                color: theme.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 8),
              Text(
                formatDateRange(competition.startDate, competition.endDate),
                style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
              ),
            ],
          ),
        ],
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
            number: '0',
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
