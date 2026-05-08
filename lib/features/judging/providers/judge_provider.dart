import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/utils/app_constants.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/core/utils/comp_filters.dart';
import 'package:travers_app/features/competitions/providers/comp_filter_provider.dart';

final judgeCompetitionsProvider =
    StreamProvider.autoDispose<List<CompetitionModel>>((ref) {
      final currentUserUid = ref.watch(currentUserUidProvider);
      if (currentUserUid == null) return Stream.value([]);

      final db = FirebaseFirestore.instance;
      return db
          .collection(AppConstants.competitionsCollection)
          .where('judgeIds', arrayContains: currentUserUid)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => CompetitionModel.fromMap(doc.data(), doc.id))
                .toList();
          });
    });

final filteredJudgeCompetitionsProvider =
    Provider<AsyncValue<List<CompetitionModel>>>((ref) {
      final filter = ref.watch(competitionFilterProvider);
      final competitionsAsync = ref.watch(judgeCompetitionsProvider);

      return competitionsAsync.whenData(
        (competitions) => competitions.filterByStatus(filter),
      );
    });
