import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/widgets/app_filter_chip.dart';
import 'package:travers_app/core/widgets/app_search_field.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/features/competitions/providers/leaderboard_provider.dart';
import 'package:travers_app/features/competitions/widgets/comp_status.dart';
import 'package:travers_app/features/competitions/widgets/overall_team_details.dart';
import 'package:travers_app/features/competitions/widgets/participant_details_bottomsheet.dart';
import 'package:travers_app/features/competitions/widgets/team_distance_details.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  final String competitionId;
  final String competitionName;

  const LeaderboardScreen({
    super.key,
    required this.competitionId,
    required this.competitionName,
  });

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  bool _isOverallStandings = true;
  Distance? _selectedDistance;
  String _searchQuery = '';
  GenderFilter _selectedGenderFilter = GenderFilter.all;
  bool _isTeamView = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final competitionAsync = ref.watch(
      competitionStreamProvider(widget.competitionId),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.competitionName,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            competitionAsync.when(
              data: (competition) => competition != null
                  ? CompStatusBadge(status: competition.status)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      body: competitionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Помилка: $error')),
        data: (competition) {
          if (competition == null) {
            return const Center(child: Text('Змагання не знайдено'));
          }

          final distances = competition.distances;

          if (distances.isEmpty) {
            return const Center(
              child: Text('У цьому змаганні ще немає дистанцій'),
            );
          }

          return Column(
            children: [
              Container(
                height: 40,
                margin: const EdgeInsets.only(top: 16, bottom: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: distances.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return AppFilterChip(
                        label: 'Загальний залік',
                        isSelected: _isOverallStandings,
                        onTap: () => setState(() {
                          _isOverallStandings = true;
                          _isTeamView = false;
                          _selectedGenderFilter = GenderFilter.all;
                        }),
                      );
                    }
                    final distance = distances[index - 1];
                    final isSelected =
                        !_isOverallStandings &&
                        (_selectedDistance?.id == distance.id);

                    return AppFilterChip(
                      label: distance.type.displayName,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _isOverallStandings = false;
                          _selectedDistance = distance;
                          _isTeamView = false;
                          _selectedGenderFilter = GenderFilter.all;
                        });
                      },
                    );
                  },
                ),
              ),

              if (!_isOverallStandings && _selectedDistance != null)
                _buildSubFilters(_selectedDistance!),

              AppSearchField(
                hintText: 'Пошук учасника...',
                onChanged: (value) => setState(() => _searchQuery = value),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const Text(
                      '#',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _isOverallStandings
                            ? 'КОМАНДА / РЕГІОН'
                            : 'ПІБ / КОМАНДА',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      _isOverallStandings ? 'СУМА ВІДСОТКІВ' : 'ЧАС / ШТРАФИ',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Expanded(
                child: _isOverallStandings
                    ? _buildOverallStandingsList()
                    : _buildLeaderboardList(
                        _selectedDistance ?? distances.first,
                        competition,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSubFilters(Distance distance) {
    if (distance.view == DistanceView.team) return const SizedBox.shrink();

    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          AppFilterChip(
            label: 'Командний результат',
            isSelected: _isTeamView,
            onTap: () => setState(() {
              _isTeamView = true;
            }),
          ),
          const SizedBox(width: 16),

          AppFilterChip(
            label: 'Всі',
            isSelected:
                !_isTeamView && _selectedGenderFilter == GenderFilter.all,
            onTap: () => setState(() {
              _isTeamView = false;
              _selectedGenderFilter = GenderFilter.all;
            }),
          ),
          const SizedBox(width: 8),

          if (distance.view == DistanceView.individual) ...[
            AppFilterChip(
              label: 'Чоловіки',
              isSelected:
                  !_isTeamView && _selectedGenderFilter == GenderFilter.male,
              onTap: () => setState(() {
                _isTeamView = false;
                _selectedGenderFilter = GenderFilter.male;
              }),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: 'Жінки',
              isSelected:
                  !_isTeamView && _selectedGenderFilter == GenderFilter.female,
              onTap: () => setState(() {
                _isTeamView = false;
                _selectedGenderFilter = GenderFilter.female;
              }),
            ),
          ],

          if (distance.view == DistanceView.pair) ...[
            AppFilterChip(
              label: 'Чоловічі',
              isSelected:
                  !_isTeamView && _selectedGenderFilter == GenderFilter.male,
              onTap: () => setState(() {
                _isTeamView = false;
                _selectedGenderFilter = GenderFilter.male;
              }),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: 'Жіночі',
              isSelected:
                  !_isTeamView && _selectedGenderFilter == GenderFilter.female,
              onTap: () => setState(() {
                _isTeamView = false;
                _selectedGenderFilter = GenderFilter.female;
              }),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: 'Змішані',
              isSelected:
                  !_isTeamView && _selectedGenderFilter == GenderFilter.mixed,
              onTap: () => setState(() {
                _isTeamView = false;
                _selectedGenderFilter = GenderFilter.mixed;
              }),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardList(
    Distance distance,
    CompetitionModel competition,
  ) {
    final params = (
      competitionId: widget.competitionId,
      distance: distance,
      genderFilter: _selectedGenderFilter,
      isTeamView: _isTeamView,
    );

    final leaderboardAsync = ref.watch(leaderboardProvider(params));

    return leaderboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Помилка завантаження: $error')),
      data: (leaderboard) {
        if (leaderboard.isEmpty) {
          return const Center(
            child: Text(
              'Ще немає результатів для цих фільтрів',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final filteredList = leaderboard.where((result) {
          final query = _searchQuery.toLowerCase();
          return result.target.title.toLowerCase().contains(query) ||
              result.target.subtitle.toLowerCase().contains(query) ||
              result.target.region.toLowerCase().contains(query);
        }).toList();

        if (filteredList.isEmpty) {
          return const Center(
            child: Text(
              'За вашим запитом нічого не знайдено',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final result = filteredList[index];
            final place = leaderboard.indexOf(result) + 1;

            final startNumber = result.target.subtitle
                .split('•')
                .first
                .replaceAll(RegExp(r'[^0-9]'), '')
                .trim();

            String subtitle = result.target.subtitle;
            if (result.target.region.isNotEmpty) {
              subtitle = '$subtitle • ${result.target.region}';
            }

            return _TournamentCard(
              place: place,
              startNumber: startNumber.isNotEmpty ? startNumber : '-',
              name: result.target.title,
              subtitle: subtitle,
              pureTime: result.formattedPureTime,
              finalTime: result.formattedFinalTime,
              penalties: '${result.totalPenalties} б.',
              onTap: () {
                if (_isTeamView) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) =>
                        TeamDistanceDetailsBottomSheet(teamResult: result),
                  );
                } else {
                  final currentUserId = ref.read(currentUserUidProvider);
                  final isHeadJudge =
                      currentUserId != null &&
                      currentUserId == competition.headJudgeId;

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    enableDrag: false,
                    builder: (context) => DraggableScrollableSheet(
                      initialChildSize: 0.6,
                      minChildSize: 0.4,
                      maxChildSize: 0.9,
                      builder: (_, scrollController) {
                        return ParticipantDetailsBottomSheet(
                          competitionId: widget.competitionId,
                          result: result,
                          distance: distance,
                          isHeadJudge: isHeadJudge,
                        );
                      },
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOverallStandingsList() {
    final standingsAsync = ref.watch(
      overallStandingsProvider(widget.competitionId),
    );

    return standingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Помилка: $error')),
      data: (standings) {
        if (standings.isEmpty) {
          return const Center(
            child: Text(
              'Ще немає результатів для загального заліку',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final filteredList = standings
            .where(
              (team) => team.teamName.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
            )
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final team = filteredList[index];
            final place = standings.indexOf(team) + 1;

            return _TournamentCard(
              place: place,
              name: team.teamName,
              subtitle: 'Командний результат',
              pureTime: '',
              finalTime: team.formattedPercentage,
              penalties: '',
              startNumber: '',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) =>
                      OverallTeamDetailsBottomSheet(standing: team),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final int place;
  final String startNumber;
  final String name;
  final String subtitle;
  final String pureTime;
  final String finalTime;
  final String penalties;
  final VoidCallback onTap;

  const _TournamentCard({
    required this.place,
    required this.startNumber,
    required this.name,
    required this.subtitle,
    required this.pureTime,
    required this.finalTime,
    required this.penalties,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.transparent;
    Color rankColor = Colors.grey.shade500;

    if (place == 1) {
      borderColor = const Color(0xFFFFD700); // Золото
      rankColor = const Color(0xFFFFD700);
    } else if (place == 2) {
      borderColor = const Color.fromARGB(255, 159, 142, 142); // Срібло
      rankColor = const Color.fromARGB(255, 126, 116, 116);
    } else if (place == 3) {
      borderColor = const Color(0xFFCD7F32); // Бронза
      rankColor = const Color(0xFFCD7F32);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: place <= 3 ? borderColor : Colors.transparent,
            width: place <= 3 ? 1.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                place.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 45,
              child: Text(
                penalties,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  finalTime,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  pureTime.isNotEmpty ? 'Ч: $pureTime' : '',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
