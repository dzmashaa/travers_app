import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/features/competitions/repositories/competition_repository.dart';

final distanceBuilderControllerProvider =
    AsyncNotifierProvider<DistanceBuilderController, void>(() {
      return DistanceBuilderController();
    });

class DistanceBuilderController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> addBlock({
    required String competitionId,
    required String distanceId,
    required String blockName,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(competitionRepositoryProvider)
          .addBlock(
            competitionId: competitionId,
            distanceId: distanceId,
            blockName: blockName,
          );
    });
    return !state.hasError;
  }

  Future<bool> addStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageName,
    required dynamic passingMode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(competitionRepositoryProvider)
          .addStage(
            competitionId: competitionId,
            distanceId: distanceId,
            blockId: blockId,
            stageName: stageName,
            passingMode: passingMode,
          );
    });
    return !state.hasError;
  }

  Future<bool> deleteBlock({
    required String competitionId,
    required String distanceId,
    required String blockId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(competitionRepositoryProvider)
          .deleteBlock(
            competitionId: competitionId,
            distanceId: distanceId,
            blockId: blockId,
          );
    });
    return !state.hasError;
  }

  Future<bool> deleteStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(competitionRepositoryProvider)
          .deleteStage(
            competitionId: competitionId,
            distanceId: distanceId,
            blockId: blockId,
            stageId: stageId,
          );
    });
    return !state.hasError;
  }
}
