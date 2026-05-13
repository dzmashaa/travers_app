import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/result.dart';

final judgingRepositoryProvider = Provider<JudgingRepository>((ref) {
  return JudgingRepository();
});

class JudgingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveResult({
    required String competitionId,
    required ResultModel result,
  }) async {
    try {
      final resultsCollection = _firestore
          .collection('competitions')
          .doc(competitionId)
          .collection('results');

      final docRef = result.id.isEmpty
          ? resultsCollection.doc()
          : resultsCollection.doc(result.id);
      final finalResult = result.copyWith(id: docRef.id);
      await docRef.set(finalResult.toMap());
    } catch (e) {
      throw 'Помилка збереження результату: $e';
    }
  }
}
