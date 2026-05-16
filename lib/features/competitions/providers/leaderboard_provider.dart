import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travers_app/core/models/aggregated_result.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/judging_target.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/features/judging/providers/participants_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum GenderFilter { all, male, female, mixed }

typedef LeaderboardParams = ({
  String competitionId,
  Distance distance,
  GenderFilter genderFilter,
  bool isTeamView,
});

final allCompetitionResultsProvider =
    StreamProvider.family<List<ResultModel>, String>((ref, competitionId) {
      return FirebaseFirestore.instance
          .collection('competitions')
          .doc(competitionId)
          .collection('results')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return ResultModel.fromMap(doc.data(), doc.id);
            }).toList();
          });
    });

int getPenaltyMultiplierMs(DistanceView view) {
  switch (view) {
    case DistanceView.individual:
      return 10 * 1000;
    case DistanceView.pair:
      return 20 * 1000;
    case DistanceView.team:
      return 30 * 1000;
  }
}

JudgingTarget _buildJudgingTarget(
  String targetId,
  DistanceView view,
  List<ParticipantModel> participants,
) {
  if (view == DistanceView.individual) {
    final p = participants.where((p) => p.id == targetId).firstOrNull;
    return p != null
        ? JudgingTarget.fromParticipant(p)
        : JudgingTarget(id: targetId, title: 'Невідомий', subtitle: 'Особиста');
  } else if (view == DistanceView.team) {
    String displayTitle = targetId.replaceAll('team_', '').trim();
    final teamMember = participants
        .where((p) => p.teamName == targetId)
        .firstOrNull;

    String subtitle = 'Команда';
    if (teamMember?.coachName.isNotEmpty == true) {
      subtitle = 'Команда • ${teamMember?.coachName}';
    }
    return JudgingTarget(
      id: targetId,
      title: displayTitle,
      subtitle: subtitle,
      region: teamMember?.region ?? '',
    );
  } else {
    final ids = targetId.split(',');
    final p1 = ids.isNotEmpty
        ? participants.where((p) => p.id == ids.first.trim()).firstOrNull
        : null;
    final p2 = ids.length > 1
        ? participants.where((p) => p.id == ids.last.trim()).firstOrNull
        : null;

    String getShortName(String? fullName) {
      if (fullName == null || fullName.isEmpty) return 'Невідомий';
      return fullName.trim().split(' ').first;
    }

    String combinedRegion = '';
    if (p1 != null && p2 != null) {
      if (p1.region == p2.region) {
        combinedRegion = p1.region;
      } else {
        combinedRegion = '${p1.region} / ${p2.region}';
      }
    }

    return JudgingTarget(
      id: targetId,
      title: '${getShortName(p1?.name)} / ${getShortName(p2?.name)}',
      subtitle: 'Зв\'язка',
      region: combinedRegion,
    );
  }
}

String _getTeamName(
  AggregatedResult res,
  DistanceView view,
  List<ParticipantModel> participants,
) {
  if (view == DistanceView.team) return res.target.title;
  final ids = res.target.id.split(',');
  final p = participants.where((p) => p.id == ids.first.trim()).firstOrNull;
  return p?.teamName ?? '';
}

List<AggregatedResult> _calculateBaseResults({
  required Distance distance,
  required List<ParticipantModel> participants,
  required List<ResultModel> allResults,
  required int penaltyMultiplierMs,
}) {
  final distanceBlockIds = distance.stageBlocks.map((b) => b.id).toSet();
  final distanceResults = allResults.where(
    (r) => distanceBlockIds.contains(r.blockId),
  );

  final groupedResults = <String, List<ResultModel>>{};
  for (final result in distanceResults) {
    groupedResults.putIfAbsent(result.targetId, () => []).add(result);
  }

  final leaderboard = <AggregatedResult>[];

  for (final entry in groupedResults.entries) {
    final targetId = entry.key;
    final blocks = entry.value;

    int pureTimeSum = 0;
    int penaltySum = 0;

    for (final blockResult in blocks) {
      pureTimeSum += blockResult.timeTotalMs;
      penaltySum += blockResult.penaltiesSum;
    }

    leaderboard.add(
      AggregatedResult(
        target: _buildJudgingTarget(targetId, distance.view, participants),
        pureTimeMs: pureTimeSum,
        totalPenalties: penaltySum,
        finalCalculatedTimeMs: pureTimeSum + (penaltySum * penaltyMultiplierMs),
        blockResults: blocks,
      ),
    );
  }
  return leaderboard;
}

List<AggregatedResult> _filterByGender(
  List<AggregatedResult> results,
  DistanceView view,
  GenderFilter filter,
  List<ParticipantModel> participants,
) {
  if (filter == GenderFilter.all) return results;

  return results.where((result) {
    if (view == DistanceView.individual) {
      final p = participants.where((p) => p.id == result.target.id).firstOrNull;
      if (p == null) return false;
      if (filter == GenderFilter.male) return p.gender == Gender.male;
      if (filter == GenderFilter.female) return p.gender == Gender.female;
      return true;
    } else if (view == DistanceView.pair) {
      final ids = result.target.id.split(',');
      if (ids.length != 2) return false;
      final p1 = participants
          .where((p) => p.id == ids.first.trim())
          .firstOrNull;
      final p2 = participants.where((p) => p.id == ids.last.trim()).firstOrNull;
      if (p1 == null || p2 == null) return false;

      final isP1Male = p1.gender == Gender.male;
      final isP2Male = p2.gender == Gender.male;

      if (filter == GenderFilter.male) return isP1Male && isP2Male;
      if (filter == GenderFilter.female) return !isP1Male && !isP2Male;
      if (filter == GenderFilter.mixed) return isP1Male != isP2Male;
      return true;
    }
    return true;
  }).toList();
}

List<AggregatedResult> _calculateDistanceTeamResults(
  List<AggregatedResult> baseResults,
  DistanceView view,
  int topCountRequired,
  List<ParticipantModel> participants,
) {
  final teamGroups = <String, List<AggregatedResult>>{};

  for (final res in baseResults) {
    final teamName = _getTeamName(res, view, participants);
    if (teamName.isNotEmpty && teamName.toLowerCase() != 'особиста') {
      teamGroups.putIfAbsent(teamName, () => []).add(res);
    }
  }

  final teamLeaderboard = <AggregatedResult>[];

  for (final entry in teamGroups.entries) {
    final teamName = entry.key;
    final teamResults = entry.value;

    teamResults.sort(
      (a, b) => a.finalCalculatedTimeMs.compareTo(b.finalCalculatedTimeMs),
    );

    if (teamResults.length < topCountRequired) continue;

    final topResults = teamResults.take(topCountRequired).toList();
    final scoringTargetIds = topResults.map((r) => r.target.id).toSet();
    int teamTotalTimeMs = 0;
    int teamTotalPenalties = 0;
    final regions = <String>{};

    for (final res in topResults) {
      teamTotalTimeMs += res.finalCalculatedTimeMs;
      teamTotalPenalties += res.totalPenalties;
      if (res.target.region.isNotEmpty) regions.add(res.target.region);
    }

    teamLeaderboard.add(
      AggregatedResult(
        target: JudgingTarget(
          id: 'team_$teamName',
          title: teamName,
          subtitle: 'Командний результат',
          region: regions.join(' / '),
        ),
        pureTimeMs: teamTotalTimeMs,
        totalPenalties: teamTotalPenalties,
        finalCalculatedTimeMs: teamTotalTimeMs,
        blockResults: [],
        teamMemberResults: teamResults,
        scoringTargetIds: scoringTargetIds,
      ),
    );
  }

  return teamLeaderboard;
}

final leaderboardProvider =
    Provider.family<AsyncValue<List<AggregatedResult>>, LeaderboardParams>((
      ref,
      params,
    ) {
      final participantsAsync = ref.watch(
        competitionParticipantsProvider(params.competitionId),
      );
      final allResultsAsync = ref.watch(
        allCompetitionResultsProvider(params.competitionId),
      );

      if (participantsAsync.isLoading || allResultsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (participantsAsync.hasError) {
        return AsyncValue.error(
          participantsAsync.error!,
          participantsAsync.stackTrace!,
        );
      }
      if (allResultsAsync.hasError) {
        return AsyncValue.error(
          allResultsAsync.error!,
          allResultsAsync.stackTrace!,
        );
      }

      final participants = participantsAsync.value ?? [];
      final allResults = allResultsAsync.value ?? [];
      final penaltyMultiplierMs = getPenaltyMultiplierMs(params.distance.view);

      List<AggregatedResult> leaderboard = _calculateBaseResults(
        distance: params.distance,
        participants: participants,
        allResults: allResults,
        penaltyMultiplierMs: penaltyMultiplierMs,
      );

      if (params.isTeamView && params.distance.view != DistanceView.team) {
        int topCount = params.distance.view == DistanceView.individual ? 4 : 2;
        leaderboard = _calculateDistanceTeamResults(
          leaderboard,
          params.distance.view,
          topCount,
          participants,
        );
      } else if (!params.isTeamView &&
          params.genderFilter != GenderFilter.all) {
        leaderboard = _filterByGender(
          leaderboard,
          params.distance.view,
          params.genderFilter,
          participants,
        );
      }

      leaderboard.sort(
        (a, b) => a.finalCalculatedTimeMs.compareTo(b.finalCalculatedTimeMs),
      );
      if (leaderboard.isNotEmpty) {
        final bestTime = leaderboard.first.finalCalculatedTimeMs;

        if (bestTime > 0) {
          leaderboard = leaderboard.map((res) {
            final percentage = (res.finalCalculatedTimeMs / bestTime) * 100;

            return res.copyWith(relativePercentage: percentage);
          }).toList();
        }
      }

      return AsyncValue.data(leaderboard);
    });

class DistanceScore {
  final String distanceName;
  final double percentage;
  final int timeMs;

  DistanceScore(this.distanceName, this.percentage, this.timeMs);

  String get formattedPercentage => '${percentage.toStringAsFixed(1)} %';
}

class TeamStanding {
  final String teamName;
  final double totalPercentage;
  final List<DistanceScore> distanceScores;

  TeamStanding(this.teamName, this.totalPercentage, this.distanceScores);

  String get formattedPercentage => '${totalPercentage.toStringAsFixed(1)} %';
}

final overallStandingsProvider =
    Provider.family<AsyncValue<List<TeamStanding>>, String>((ref, compId) {
      final compAsync = ref.watch(competitionStreamProvider(compId));
      final participantsAsync = ref.watch(
        competitionParticipantsProvider(compId),
      );
      final resultsAsync = ref.watch(allCompetitionResultsProvider(compId));

      if (compAsync.isLoading ||
          participantsAsync.isLoading ||
          resultsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      final comp = compAsync.value;
      final participants = participantsAsync.value ?? [];
      final allResults = resultsAsync.value ?? [];

      if (comp == null || comp.distances.isEmpty) {
        return const AsyncValue.data([]);
      }

      final teamScores = <String, double>{};
      final teamBreakdowns = <String, List<DistanceScore>>{};

      for (final distance in comp.distances) {
        final baseResults = _calculateBaseResults(
          distance: distance,
          participants: participants,
          allResults: allResults,
          penaltyMultiplierMs: getPenaltyMultiplierMs(distance.view),
        );

        if (baseResults.isEmpty) continue;

        List<AggregatedResult> teamResultsForDistance;
        if (distance.view == DistanceView.team) {
          teamResultsForDistance = _calculateDistanceTeamResults(
            baseResults,
            distance.view,
            1,
            participants,
          );
        } else {
          int topCount = distance.view == DistanceView.individual ? 4 : 2;
          teamResultsForDistance = _calculateDistanceTeamResults(
            baseResults,
            distance.view,
            topCount,
            participants,
          );
        }

        if (teamResultsForDistance.isEmpty) continue;

        teamResultsForDistance.sort(
          (a, b) => a.finalCalculatedTimeMs.compareTo(b.finalCalculatedTimeMs),
        );
        final bestTime = teamResultsForDistance.first.finalCalculatedTimeMs;

        if (bestTime == 0) continue;

        for (final res in teamResultsForDistance) {
          final percentage = (res.finalCalculatedTimeMs / bestTime) * 100;
          final teamName = res.target.title;

          teamScores[teamName] = (teamScores[teamName] ?? 0.0) + percentage;
          teamBreakdowns
              .putIfAbsent(teamName, () => [])
              .add(
                DistanceScore(
                  distance.type.displayName,
                  percentage,
                  res.finalCalculatedTimeMs,
                ),
              );
        }
      }

      final resultList =
          teamScores.entries
              .map(
                (e) =>
                    TeamStanding(e.key, e.value, teamBreakdowns[e.key] ?? []),
              )
              .toList()
            ..sort((a, b) => a.totalPercentage.compareTo(b.totalPercentage));

      return AsyncValue.data(resultList);
    });
