import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/models/competition.dart';
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
}
