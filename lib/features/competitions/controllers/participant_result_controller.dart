import 'package:flutter_riverpod/legacy.dart';
import 'package:travers_app/core/models/aggregated_result.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/models/result.dart';
import 'package:travers_app/features/competitions/providers/leaderboard_provider.dart';

class ParticipantDetailsState {
  final AggregatedResult result;
  final bool isEditMode;
  final bool hasChanges;

  ParticipantDetailsState({
    required this.result,
    this.isEditMode = false,
    this.hasChanges = false,
  });

  ParticipantDetailsState copyWith({
    AggregatedResult? result,
    bool? isEditMode,
    bool? hasChanges,
  }) {
    return ParticipantDetailsState(
      result: result ?? this.result,
      isEditMode: isEditMode ?? this.isEditMode,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }
}

class ParticipantDetailsController
    extends StateNotifier<ParticipantDetailsState> {
  final int _penaltyMultiplierMs;

  ParticipantDetailsController({
    required AggregatedResult initialResult,
    required DistanceView view,
  }) : _penaltyMultiplierMs = getPenaltyMultiplierMs(view),
       super(ParticipantDetailsState(result: initialResult));

  void toggleEditMode(bool value) {
    state = state.copyWith(isEditMode: value);
  }

  void updateBlockTime(String blockId, int newTimeMs) {
    final block = state.result.blockResults.firstWhere((b) => b.id == blockId);
    _recalculateAndUpdate(block.copyWith(timeTotalMs: newTimeMs));
  }

  void addPenalty(String blockId, String stageId, PenaltyRule rule) {
    final block = state.result.blockResults.firstWhere((b) => b.id == blockId);

    final newPenalty = AppliedPenalty(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      stageId: stageId,
      penaltyCode: rule.code,
      reason: rule.reason,
      points: rule.points,
      isDisqualification: rule.isDisqualification,
    );

    final currentPenalties = List<AppliedPenalty>.from(block.appliedPenalties)
      ..add(newPenalty);

    final int newSum = currentPenalties.fold<int>(
      0,
      (sum, p) => sum + p.points,
    );

    _recalculateAndUpdate(
      block.copyWith(appliedPenalties: currentPenalties, penaltiesSum: newSum),
    );
  }

  void removePenalty(String blockId, AppliedPenalty penaltyToRemove) {
    final block = state.result.blockResults.firstWhere((b) => b.id == blockId);

    final currentPenalties = List<AppliedPenalty>.from(block.appliedPenalties)
      ..removeWhere((p) => p == penaltyToRemove);

    final int newSum = currentPenalties.fold<int>(
      0,
      (sum, p) => sum + p.points,
    );

    _recalculateAndUpdate(
      block.copyWith(appliedPenalties: currentPenalties, penaltiesSum: newSum),
    );
  }

  void _recalculateAndUpdate(ResultModel updatedBlock) {
    final List<ResultModel> newBlocks = state.result.blockResults.map((b) {
      return b.id == updatedBlock.id ? updatedBlock : b;
    }).toList();

    int pureTimeSum = 0;
    int penaltySum = 0;

    for (final ResultModel b in newBlocks) {
      pureTimeSum += b.timeTotalMs;
      penaltySum += b.penaltiesSum.toInt();
    }

    final finalTimeMs = pureTimeSum + (penaltySum * _penaltyMultiplierMs);

    final updatedResult = state.result.copyWith(
      blockResults: newBlocks,
      pureTimeMs: pureTimeSum,
      totalPenalties: penaltySum,
      finalCalculatedTimeMs: finalTimeMs,
    );

    state = state.copyWith(result: updatedResult, hasChanges: true);
  }
}

final participantDetailsProvider = StateNotifierProvider.autoDispose
    .family<
      ParticipantDetailsController,
      ParticipantDetailsState,
      ({AggregatedResult result, DistanceView view})
    >((ref, args) {
      return ParticipantDetailsController(
        initialResult: args.result,
        view: args.view,
      );
    });
