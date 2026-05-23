import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userStatsProvider = StreamProvider.autoDispose<Map<String, int>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value({'created': 0, 'judgedComps': 0, 'judgedBlocks': 0});
  }

  final db = FirebaseFirestore.instance;

  return db
      .collection('competitions')
      .where('judgeIds', arrayContains: user.uid)
      .snapshots()
      .map((snapshot) {
        int created = 0;
        int judgedComps = 0;
        int judgedBlocks = 0;

        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['headJudgeId'] == user.uid) {
            created++;
          }

          bool hasAssignedBlocksInThisComp = false;

          final distances = data['distances'] as List<dynamic>? ?? [];
          for (final d in distances) {
            final blocks = d['stageBlocks'] as List<dynamic>? ?? [];
            for (final b in blocks) {
              final blockJudgeIds = b['judgeIds'] as List<dynamic>? ?? [];

              if (blockJudgeIds.contains(user.uid)) {
                judgedBlocks++;
                hasAssignedBlocksInThisComp = true;
              }
            }
          }
          if (hasAssignedBlocksInThisComp) {
            judgedComps++;
          }
        }

        return {
          'created': created,
          'judgedComps': judgedComps,
          'judgedBlocks': judgedBlocks,
        };
      });
});
