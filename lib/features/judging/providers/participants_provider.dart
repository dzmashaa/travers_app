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
