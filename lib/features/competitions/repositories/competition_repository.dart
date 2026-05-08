import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/distance.dart';
import '../../../core/utils/app_constants.dart';
import 'dart:math' as math;

final competitionRepositoryProvider = Provider(
  (ref) => CompetitionRepository(),
);

final competitionStreamProvider =
    StreamProvider.family<CompetitionModel?, String>((ref, competitionId) {
      final repository = ref.watch(competitionRepositoryProvider);
      return repository.watchCompetition(competitionId);
    });

final allCompetitionsStreamProvider =
    StreamProvider.autoDispose<List<CompetitionModel>>((ref) {
      final repository = ref.watch(competitionRepositoryProvider);
      return repository.watchAllCompetitions();
    });

class CompetitionRepository {
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Stream<CompetitionModel?> watchCompetition(String id) {
    return _db
        .collection(AppConstants.competitionsCollection)
        .doc(id)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? CompetitionModel.fromMap(doc.data()!, doc.id) : null,
        );
  }

  Stream<List<CompetitionModel>> watchAllCompetitions() {
    return _db
        .collection(AppConstants.competitionsCollection)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CompetitionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<CompetitionModel> saveCompetition({
    CompetitionModel? existingCompetition,
    required String title,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('unauthorized');

    final isEditing = existingCompetition != null;

    final docRef = isEditing
        ? _db
              .collection(AppConstants.competitionsCollection)
              .doc(existingCompetition.id)
        : _db.collection(AppConstants.competitionsCollection).doc();

    final competitionData = CompetitionModel(
      id: docRef.id,
      title: title.trim(),
      location: location.trim(),
      startDate: startDate,
      endDate: endDate,
      inviteCode: isEditing
          ? existingCompetition.inviteCode
          : _generateInviteCode(),
      headJudgeId: isEditing ? existingCompetition.headJudgeId : user.uid,
      distances: isEditing ? existingCompetition.distances : [],
    );

    await docRef.set(competitionData.toMap());

    return competitionData;
  }

  String _generateInviteCode() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZqwertyuiopasdfghjklzxcvbnm0123456789';
    final rnd = math.Random.secure();
    return Iterable.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> deleteCompetition(String competitionId) async {
    await _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .delete();
  }

  Future<void> addDistance({
    required String competitionId,
    required String description,
    required DistanceType type,
    required DistanceView view,
    required int classLevel,
  }) async {
    final newDistance = Distance(
      id: _uuid.v4(),
      description: description.trim(),
      type: type,
      classLevel: classLevel,
      view: view,
      stageBlocks: [],
    );

    await _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'distances': FieldValue.arrayUnion([newDistance.toMap()]),
        });
  }

  Future<void> deleteDistance({
    required String competitionId,
    required Distance distance,
  }) async {
    await _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'distances': FieldValue.arrayRemove([distance.toMap()]),
        });
  }

  Future<void> _modifyDistances(
    String competitionId,
    Distance Function(List<Distance> currentDistances) modifier,
  ) async {
    return _db.runTransaction((transaction) async {
      final docRef = _db
          .collection(AppConstants.competitionsCollection)
          .doc(competitionId);
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists || snapshot.data() == null)
        throw Exception('Змагання не знайдено');

      final competition = CompetitionModel.fromMap(
        snapshot.data()!,
        snapshot.id,
      );

      modifier(competition.distances);
      transaction.update(docRef, {
        'distances': competition.distances.map((d) => d.toMap()).toList(),
      });
    });
  }

  Future<void> updateDistance({
    required String competitionId,
    required Distance updatedDistance,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final index = distances.indexWhere((d) => d.id == updatedDistance.id);
      if (index == -1) throw Exception('Дистанцію не знайдено');
      distances[index] = updatedDistance;
      return updatedDistance;
    });
  }

  Future<void> addBlock({
    required String blockName,
    required String competitionId,
    required String distanceId,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw Exception('Дистанцію не знайдено');

      final newBlock = StageBlock(
        id: _uuid.v4(),
        blockName: blockName,
        stages: const [],
      );

      final updatedBlocks = List<StageBlock>.from(distances[dIndex].stageBlocks)
        ..add(newBlock);
      distances[dIndex] = distances[dIndex].copyWith(blocks: updatedBlocks);

      return distances[dIndex];
    });
  }

  Future<void> addStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageName,
    required dynamic passingMode,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw Exception('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw Exception('Блок не знайдено');

      final newStage = Stage(
        id: _uuid.v4(),
        name: stageName,
        passingMode: passingMode,
      );

      final updatedStages = List<Stage>.from(blocks[bIndex].stages)
        ..add(newStage);
      blocks[bIndex] = blocks[bIndex].copyWith(stages: updatedStages);

      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);
      return distances[dIndex];
    });
  }

  Future<void> assignJudgeToBlock({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String judgeUid,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw Exception('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw Exception('Блок не знайдено');

      final currentJudges = List<String>.from(blocks[bIndex].judgeIds);
      if (!currentJudges.contains(judgeUid)) {
        currentJudges.add(judgeUid);
      }

      blocks[bIndex] = blocks[bIndex].copyWith(judgeIds: currentJudges);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);

      return distances[dIndex];
    });
  }

  Future<void> deleteBlock({
    required String competitionId,
    required String distanceId,
    required String blockId,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw Exception('Дистанцію не знайдено');

      final updatedBlocks = distances[dIndex].stageBlocks
          .where((b) => b.id != blockId)
          .toList();

      distances[dIndex] = distances[dIndex].copyWith(blocks: updatedBlocks);
      return distances[dIndex];
    });
  }

  Future<void> deleteStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageId,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw Exception('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw Exception('Блок не знайдено');
      final updatedStages = blocks[bIndex].stages
          .where((s) => s.id != stageId)
          .toList();

      blocks[bIndex] = blocks[bIndex].copyWith(stages: updatedStages);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);

      return distances[dIndex];
    });
  }

  Future<void> addCompetitionJudge(
    String competitionId,
    String judgeUid,
  ) async {
    await _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'judgeIds': FieldValue.arrayUnion([judgeUid]),
        });
  }

  Future<void> addCompetitionParticipant(
    String competitionId,
    String participantUid,
  ) async {
    await _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'participantIds': FieldValue.arrayUnion([participantUid]),
        });
  }
}
