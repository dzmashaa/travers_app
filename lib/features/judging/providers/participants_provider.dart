import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/utils/app_constants.dart';

final competitionParticipantsProvider =
    StreamProvider.family<List<ParticipantModel>, String>((ref, competitionId) {
      final db = FirebaseFirestore.instance;

      return db
          .collection(AppConstants.competitionsCollection)
          .doc(competitionId)
          .collection('participants')
          .orderBy('startNumber')
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ParticipantModel.fromMap(doc.data(), doc.id))
                .toList();
          });
    });

final blockResultsStreamProvider =
    StreamProvider.family<List<String>, ({String compId, String blockId})>((
      ref,
      params,
    ) {
      return FirebaseFirestore.instance
          .collection('competitions')
          .doc(params.compId)
          .collection('results')
          .where('blockId', isEqualTo: params.blockId)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => doc.data()['targetId'] as String)
                .toList();
          });
    });

final availableParticipantsProvider =
    Provider.family<
      AsyncValue<List<ParticipantModel>>,
      ({String compId, String blockId})
    >((ref, params) {
      final allParticipantsAsync = ref.watch(
        competitionParticipantsProvider(params.compId),
      );
      final finishedTargetsAsync = ref.watch(
        blockResultsStreamProvider(params),
      );
      if (allParticipantsAsync.isLoading || finishedTargetsAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (allParticipantsAsync.hasError) {
        return AsyncValue.error(
          allParticipantsAsync.error!,
          allParticipantsAsync.stackTrace!,
        );
      }

      final allParticipants = allParticipantsAsync.value ?? [];
      final finishedTargetIds = finishedTargetsAsync.value ?? [];
      final available = allParticipants.where((p) {
        final isParticipantFinished = finishedTargetIds.contains(p.id);

        final isTeamFinished = finishedTargetIds.contains(p.teamName);

        final isPartInBunch = finishedTargetIds.any(
          (savedId) => savedId.contains(p.id),
        );

        return !isParticipantFinished && !isTeamFinished && !isPartInBunch;
      }).toList();

      return AsyncValue.data(available);
    });
