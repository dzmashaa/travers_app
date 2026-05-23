import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef BlockIdentifier = ({String competitionId, String blockId});

final unsyncedResultsProvider = StreamProvider.family<bool, BlockIdentifier>((
  ref,
  args,
) {
  return FirebaseFirestore.instance
      .collection('competitions')
      .doc(args.competitionId)
      .collection('results')
      .where('blockId', isEqualTo: args.blockId)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) {
        return snapshot.docs.any((doc) => doc.metadata.hasPendingWrites);
      });
});
