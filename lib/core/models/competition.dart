import 'package:travers_app/core/models/distance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum CompetitionStatus { upcoming, active, completed }

extension CompetitionStatusExtension on CompetitionStatus {
  String get displayName {
    switch (this) {
      case CompetitionStatus.active:
        return 'Триває';
      case CompetitionStatus.upcoming:
        return 'Майбутнє';
      case CompetitionStatus.completed:
        return 'Завершено';
    }
  }
}

class CompetitionModel {
  final String id;
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String inviteCode;
  final String headJudgeId;
  final List<Distance> distances;
  final List<String> judgeIds;
  final List<String> participantIds;

  CompetitionModel({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.inviteCode,
    required this.headJudgeId,
    required this.distances,
    this.judgeIds = const [],
    this.participantIds = const [],
  });

  CompetitionStatus get status {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (today.isBefore(start)) return CompetitionStatus.upcoming;
    if (today.isAfter(end)) return CompetitionStatus.completed;
    return CompetitionStatus.active;
  }

  factory CompetitionModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return CompetitionModel(
      id: documentId,
      title: map['title'] ?? '',
      location: map['location'] ?? '',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      headJudgeId: map['headJudgeId'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      distances:
          (map['distances'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map((e) => Distance.fromMap(e))
              .toList() ??
          [],
      judgeIds: List<String>.from(map['judgeIds'] ?? []),
      participantIds: List<String>.from(map['participantIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'location': location,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'inviteCode': inviteCode,
      'headJudgeId': headJudgeId,
      'distances': distances.map((d) => d.toMap()).toList(),
      'judgeIds': judgeIds,
      'participantIds': participantIds,
    };
  }
}
