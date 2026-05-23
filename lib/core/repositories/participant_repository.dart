import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/participant.dart';

final participantsRepositoryProvider = Provider(
  (ref) => ParticipantsRepository(),
);

final participantsStreamProvider = StreamProvider.family
    .autoDispose<List<ParticipantModel>, String>((ref, competitionId) {
      return FirebaseFirestore.instance
          .collection('competitions')
          .doc(competitionId)
          .collection('participants')
          .orderBy('startNumber')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ParticipantModel.fromMap(doc.data(), doc.id))
                .toList(),
          );
    });
final participantsCountProvider = StreamProvider.family
    .autoDispose<int, String>((ref, competitionId) {
      return FirebaseFirestore.instance
          .collection('competitions')
          .doc(competitionId)
          .collection('participants')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    });
final unsyncedParticipantProvider =
    StreamProvider.family<bool, ({String compId, String pId})>((ref, args) {
      return FirebaseFirestore.instance
          .collection('competitions')
          .doc(args.compId)
          .collection('participants')
          .doc(args.pId)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) => snapshot.metadata.hasPendingWrites);
    });

class ParticipantsRepository {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _getCollection(String compId) {
    return _db
        .collection('competitions')
        .doc(compId)
        .collection('participants');
  }

  Future<void> saveParticipant(
    String compId,
    ParticipantModel participant,
  ) async {
    final col = _getCollection(compId);
    final snapshot = await col.get(const GetOptions(source: Source.cache));

    for (final doc in snapshot.docs) {
      if (doc.id == participant.id) continue;

      final data = doc.data();
      if (data['startNumber'] == participant.startNumber) {
        throw Exception(
          'Учасник зі стартовим номером ${participant.startNumber} вже існує!',
        );
      }
      if (data['name'].toString().toLowerCase().trim() ==
          participant.name.toLowerCase().trim()) {
        throw Exception('Учасник з ПІБ "${participant.name}" вже існує!');
      }
    }

    if (participant.id.isEmpty) {
      col.doc().set(participant.toMap());
    } else {
      col.doc(participant.id).set(participant.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> deleteParticipant(String compId, String participantId) async {
    await _getCollection(compId).doc(participantId).delete();
  }

  Future<int> importFromCsv(String compId) async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return 0;

      final file = File(result.files.single.path!);
      final input = file.openRead();

      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter(fieldDelimiter: ','))
          .toList();

      if (fields.isEmpty) return 0;

      int importedCount = 100;
      final batch = _db.batch();

      for (int i = 1; i < fields.length; i++) {
        final row = fields[i];

        if (row.isEmpty || row.length < 7 || row[1].toString().isEmpty)
          continue;

        final docRef = _getCollection(compId).doc();

        final genderStr = row[4].toString().trim().toLowerCase();
        final gender = (genderStr == 'жінка' || genderStr.contains('ж'))
            ? Gender.female
            : Gender.male;

        final startNumber = importedCount + 1;

        final participant = {
          'startNumber': startNumber,
          'name': row[1].toString().trim(),
          'teamName': row[2].toString().trim(),
          'coachName': row[3].toString().trim(),
          'gender': gender.name,
          'region': row[5].toString().trim(),
          'birthYear': int.tryParse(row[6].toString().trim()) ?? 2005,
        };

        batch.set(docRef, participant);
        importedCount++;
      }

      if (importedCount > 0) {
        await batch.commit();
      }

      return importedCount;
    } catch (e) {
      throw Exception('Помилка парсингу файлу: $e');
    }
  }

  Future<void> generateMockParticipants(String compId) async {
    final batch = _db.batch();
    for (int i = 1; i <= 5; i++) {
      final docRef = _getCollection(compId).doc();
      batch.set(docRef, {
        'startNumber': i,
        'name': 'Учасник $i',
        'teamName': 'Команда ${i % 2 == 0 ? "А" : "Б"}',
        'coachName': 'Тренер Петренко',
        'gender': i % 2 == 0 ? 'female' : 'male',
        'region': 'Київська',
        'birthYear': 2008 + i,
      });
    }
    await batch.commit();
  }
}
