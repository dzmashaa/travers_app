import 'package:travers_app/core/models/judging_target.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/core/utils/time_extension.dart';

class AggregatedResult {
  final JudgingTarget target;
  final int pureTimeMs;
  final int totalPenalties;
  final int finalCalculatedTimeMs;
  final List<ResultModel> blockResults;
  final List<AggregatedResult>? teamMemberResults;
  final Set<String>? scoringTargetIds;
  final double? relativePercentage;

  AggregatedResult({
    required this.target,
    required this.pureTimeMs,
    required this.totalPenalties,
    required this.finalCalculatedTimeMs,
    required this.blockResults,
    this.teamMemberResults,
    this.scoringTargetIds,
    this.relativePercentage,
  });

  AggregatedResult copyWith({
    int? pureTimeMs,
    int? totalPenalties,
    int? finalCalculatedTimeMs,
    List<ResultModel>? blockResults,
    double? relativePercentage,
  }) {
    return AggregatedResult(
      target: target,
      pureTimeMs: pureTimeMs ?? this.pureTimeMs,
      totalPenalties: totalPenalties ?? this.totalPenalties,
      finalCalculatedTimeMs:
          finalCalculatedTimeMs ?? this.finalCalculatedTimeMs,
      blockResults: blockResults ?? this.blockResults,
      teamMemberResults: teamMemberResults,
      scoringTargetIds: scoringTargetIds,
      relativePercentage: relativePercentage ?? this.relativePercentage,
    );
  }

  String get formattedFinalTime => finalCalculatedTimeMs.toFormattedTime();
  String get formattedPureTime => pureTimeMs.toFormattedTime();
}
