import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:uuid/uuid.dart';
import '../models/distance.dart';
import '../utils/app_constants.dart';
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
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return CompetitionModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  CompetitionModel saveCompetition({
    CompetitionModel? existingCompetition,
    required String title,
    required String location,
    required DateTime startDate,
    required DateTime endDate,
  }) {
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
      participantIds: isEditing ? existingCompetition.participantIds : [],
      judgeIds: isEditing ? existingCompetition.judgeIds : [user.uid],
    );

    docRef.set(competitionData.toMap());

    return competitionData;
  }

  String _generateInviteCode() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZqwertyuiopasdfghjklzxcvbnm0123456789';
    final rnd = math.Random.secure();
    return Iterable.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<CompetitionModel?> getCompetitionByInviteCode(String code) async {
    final snapshot = await _db
        .collection(AppConstants.competitionsCollection)
        .where('inviteCode', isEqualTo: code)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return CompetitionModel.fromMap(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  Future<void> _deleteCollectionBatch(
    DocumentReference compRef,
    String collectionName,
  ) async {
    final snapshot = await compRef
        .collection(collectionName)
        .limit(490)
        .get(const GetOptions(source: Source.cache));

    if (snapshot.docs.isNotEmpty) {
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.commit();

      await _deleteCollectionBatch(compRef, collectionName);
    }
  }

  void deleteCompetition(String competitionId) {
    final compRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);
    final subcollections = ['results', 'participants'];

    for (final collectionName in subcollections) {
      _deleteCollectionBatch(compRef, collectionName);
    }
    compRef.delete();
  }

  void addCompetitionJudge(String competitionId, String judgeUid) {
    _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'judgeIds': FieldValue.arrayUnion([judgeUid]),
        });
  }

  // Дистанції та етапи
  Future<void> _modifyDistances(
    String competitionId,
    void Function(List<Distance> currentDistances) modifier,
  ) async {
    final docRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);

    final snapshot = await docRef.get(const GetOptions(source: Source.cache));

    if (!snapshot.exists || snapshot.data() == null) return;

    final competition = CompetitionModel.fromMap(snapshot.data()!, snapshot.id);
    final distances = List<Distance>.from(competition.distances);

    modifier(distances);

    docRef.update({'distances': distances.map((d) => d.toMap()).toList()});
  }

  void addDistance({
    required String competitionId,
    required String description,
    required DistanceType type,
    required DistanceView view,
    required int classLevel,
  }) {
    final newDistance = Distance(
      id: _uuid.v4(),
      description: description.trim(),
      type: type,
      classLevel: classLevel,
      view: view,
      stageBlocks: const [],
    );

    _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId)
        .update({
          'distances': FieldValue.arrayUnion([newDistance.toMap()]),
        });
  }

  void updateDistance({
    required String competitionId,
    required Distance updatedDistance,
  }) {
    _modifyDistances(competitionId, (distances) {
      final index = distances.indexWhere((d) => d.id == updatedDistance.id);
      if (index != -1) distances[index] = updatedDistance;
    });
  }

  void deleteDistanceWithResults({
    required String competitionId,
    required Distance distance,
  }) {
    final compRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);

    final blockIds = distance.stageBlocks.map((b) => b.id).toList();
    if (blockIds.isNotEmpty) {
      compRef
          .collection('results')
          .where('blockId', whereIn: blockIds)
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) {
            final batch = _db.batch();
            for (final doc in snapshot.docs) {
              batch.delete(doc.reference);
            }
            batch.commit();
          });
    }

    _modifyDistances(competitionId, (distances) {
      distances.removeWhere((d) => d.id == distance.id);
    });
  }

  void addBlock({
    required String blockName,
    required String competitionId,
    required String distanceId,
  }) {
    _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) return;

      final newBlock = StageBlock(
        id: _uuid.v4(),
        blockName: blockName,
        stages: const [],
        judgeIds: const [],
      );

      final updatedBlocks = List<StageBlock>.from(distances[dIndex].stageBlocks)
        ..add(newBlock);
      distances[dIndex] = distances[dIndex].copyWith(blocks: updatedBlocks);
    });
  }

  void addStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageName,
    required dynamic passingMode,
  }) {
    _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) return;

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) return;

      final newStage = Stage(
        id: _uuid.v4(),
        name: stageName,
        passingMode: passingMode,
      );

      final updatedStages = List<Stage>.from(blocks[bIndex].stages)
        ..add(newStage);
      blocks[bIndex] = blocks[bIndex].copyWith(stages: updatedStages);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);
    });
  }

  void deleteBlock({
    required String competitionId,
    required String distanceId,
    required String blockId,
  }) {
    _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) return;

      final updatedBlocks = (distances[dIndex].stageBlocks)
          .where((b) => b.id != blockId)
          .toList();
      distances[dIndex] = distances[dIndex].copyWith(blocks: updatedBlocks);
    });
  }

  void deleteStage({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required String stageId,
  }) {
    _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) return;

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) return;

      final updatedStages = blocks[bIndex].stages
          .where((s) => s.id != stageId)
          .toList();
      blocks[bIndex] = blocks[bIndex].copyWith(stages: updatedStages);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);
    });
  }

  void updateBlockJudges({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required List<String> newJudgeIds,
  }) {
    _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) return;

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) return;

      blocks[bIndex] = blocks[bIndex].copyWith(judgeIds: newJudgeIds);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);
    });
  }
}
