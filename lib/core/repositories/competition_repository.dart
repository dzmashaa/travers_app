import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/models/stage.dart';
import 'package:travers_app/core/models/stage_block.dart';
import 'package:travers_app/core/utils/exeptions.dart';
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

  Future<void> deleteCompetition(String competitionId) async {
    final compRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);
    final subcollections = ['results', 'participants'];

    for (final collectionName in subcollections) {
      bool hasMoreDocuments = true;

      while (hasMoreDocuments) {
        final snapshot = await compRef
            .collection(collectionName)
            .limit(490)
            .get(const GetOptions(source: Source.serverAndCache));

        if (snapshot.docs.isEmpty) {
          hasMoreDocuments = false;
          break;
        }

        final batch = _db.batch();
        for (final doc in snapshot.docs) {
          batch.delete(doc.reference);
        }

        await batch.commit().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
              'Сервер не відповідає під час видалення $collectionName',
            );
          },
        );
      }
    }
    await compRef.delete().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw Exception('Сервер не відповідає під час видалення змагання');
      },
    );
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

  Future<void> deleteDistanceWithResults({
    required String competitionId,
    required Distance distance,
  }) async {
    final compRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);
    bool hasOperations = false;
    final batch = _db.batch();

    final blockIds = distance.stageBlocks.map((b) => b.id).toList() ?? [];
    if (blockIds.isNotEmpty) {
      try {
        for (var i = 0; i < blockIds.length; i += 10) {
          final chunk = blockIds.sublist(
            i,
            i + 10 > blockIds.length ? blockIds.length : i + 10,
          );

          final resultsSnapshot = await compRef
              .collection('results')
              .where('blockId', whereIn: chunk)
              .get(const GetOptions(source: Source.serverAndCache))
              .timeout(const Duration(seconds: 5));

          for (final doc in resultsSnapshot.docs) {
            batch.delete(doc.reference);
            hasOperations = true;
          }
        }
      } catch (e) {
        throw Exception('Не вдалося отримати результати для видалення');
      }
    }

    try {
      final snapshot = await compRef
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 5));

      if (snapshot.exists && snapshot.data() != null) {
        final distancesArray =
            snapshot.data()!['distances'] as List<dynamic>? ?? [];
        final newDistancesArray = distancesArray
            .where((d) => d['id'] != distance.id)
            .toList();

        if (newDistancesArray.length < distancesArray.length) {
          batch.update(compRef, {'distances': newDistancesArray});
          hasOperations = true;
        }
      }
    } catch (e) {
      throw Exception('Не вдалося завантажити дані змагання');
    }

    if (hasOperations) {
      try {
        await batch.commit().timeout(const Duration(seconds: 5));
      } catch (e) {
        throw Exception('Сервер не відповідає при збереженні');
      }
    } else {
      throw Exception('Дистанцію не знайдено в базі даних');
    }
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

      if (!snapshot.exists || snapshot.data() == null) {
        throw Exception('Змагання не знайдено');
      }

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
      if (index == -1) throw AppException('Дистанцію не знайдено');
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
      if (dIndex == -1) throw AppException('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw AppException('Блок не знайдено');

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
      if (dIndex == -1) throw AppException('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw AppException('Блок не знайдено');

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
      if (dIndex == -1) throw AppException('Дистанцію не знайдено');

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
      if (dIndex == -1) throw AppException('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw AppException('Блок не знайдено');
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

  Future<void> updateBlockJudges({
    required String competitionId,
    required String distanceId,
    required String blockId,
    required List<String> newJudgeIds,
  }) async {
    await _modifyDistances(competitionId, (distances) {
      final dIndex = distances.indexWhere((d) => d.id == distanceId);
      if (dIndex == -1) throw AppException('Дистанцію не знайдено');

      final blocks = List<StageBlock>.from(distances[dIndex].stageBlocks);
      final bIndex = blocks.indexWhere((b) => b.id == blockId);
      if (bIndex == -1) throw AppException('Блок не знайдено');

      blocks[bIndex] = blocks[bIndex].copyWith(judgeIds: newJudgeIds);
      distances[dIndex] = distances[dIndex].copyWith(blocks: blocks);

      return distances[dIndex];
    });
  }

  Future<void> generateMockParticipants(String competitionId) async {
    final batch = _db.batch();
    final competitionRef = _db
        .collection(AppConstants.competitionsCollection)
        .doc(competitionId);
    final participantsRef = competitionRef.collection('participants');

    // 20 реалістичних учасників
    final mockData = [
      (name: 'Іваненко Іван', gender: Gender.male),
      (name: 'Петренко Петро', gender: Gender.male),
      (name: 'Шевченко Тарас', gender: Gender.male),
      (name: 'Косач Лариса', gender: Gender.female),
      (name: 'Франко Іван', gender: Gender.male),
      (name: 'Лисенко Микола', gender: Gender.male),
      (name: 'Бойко Василь', gender: Gender.male),
      (name: 'Коцюбинський Михайло', gender: Gender.male),
      (name: 'Стус Василь', gender: Gender.male),
      (name: 'Гончар Олесь', gender: Gender.male),
      (name: 'Українка Леся', gender: Gender.female),
      (name: 'Котляревський Іван', gender: Gender.male),
      (name: 'Кобилянська Ольга', gender: Gender.female),
      (name: 'Симоненко Василь', gender: Gender.male),
      (name: 'Теліга Олена', gender: Gender.female),
      (name: 'Довженко Олександр', gender: Gender.male),
      (name: 'Забужко Оксана', gender: Gender.female),
      (name: 'Андрухович Юрій', gender: Gender.male),
      (name: 'Костенко Ліна', gender: Gender.female),
      (name: 'Винничук Юрій', gender: Gender.male),
    ];

    final regions = [
      'Київська обл.',
      'Львівська обл.',
      'Харківська обл.',
      'Одеська обл.',
      'Дніпропетровська обл.',
    ];
    final List<String> generatedIds = [];

    for (int i = 0; i < mockData.length; i++) {
      final docRef = participantsRef.doc();
      generatedIds.add(docRef.id);

      final participant = ParticipantModel(
        id: docRef.id,
        name: mockData[i].name,
        startNumber: i + 1,
        teamName: 'Команда ${i % 5 + 1}',
        coachName: 'Тренер ${i % 3 + 1}',
        gender: mockData[i].gender,
        region: regions[i % 5],
      );

      batch.set(docRef, participant.toMap());
    }

    batch.update(competitionRef, {
      'participantIds': FieldValue.arrayUnion(generatedIds),
    });

    await batch.commit();
  }
}
