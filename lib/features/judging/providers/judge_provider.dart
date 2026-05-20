import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/models/distance.dart';
import 'package:travers_app/core/models/stage_block.dart';
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
            final list = snapshot.docs
                .map((doc) => CompetitionModel.fromMap(doc.data(), doc.id))
                .toList();
            list.sort((a, b) {
              return b.startDate.compareTo(a.startDate);
            });
            return list;
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

final competitionJudgesMapProvider =
    FutureProvider.family<Map<String, String>, List<String>>((
      ref,
      judgeIds,
    ) async {
      if (judgeIds.isEmpty) return {};

      final db = FirebaseFirestore.instance;
      final Map<String, String> judgesMap = {};
      await Future.wait(
        judgeIds.map((id) async {
          try {
            final doc = await db.collection('users').doc(id).get();

            if (doc.exists && doc.data() != null) {
              judgesMap[id] = doc.data()!['name'] ?? 'Без імені';
            } else {
              judgesMap[id] = 'Невідомий користувач';
            }
          } catch (e) {
            judgesMap[id] = 'Помилка';
          }
        }),
      );

      return judgesMap;
    });

class JudgeAssignment {
  final Distance distance;
  final StageBlock block;

  JudgeAssignment({required this.distance, required this.block});
}
