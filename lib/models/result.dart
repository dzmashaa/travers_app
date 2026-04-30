class Penalty {
  final String stageName;
  final String code;
  final int points;
  final String reason;

  Penalty({
    required this.stageName,
    required this.code,
    required this.points,
    required this.reason,
  });

  factory Penalty.fromMap(Map<String, dynamic> map) {
    return Penalty(
      stageName: map['stageName'] ?? '',
      code: map['code'] ?? '',
      points: map['points'] ?? 0,
      reason: map['reason'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stageName': stageName,
      'code': code,
      'points': points,
      'reason': reason,
    };
  }
}

class ResultModel {
  final String id;
  final String participantId;
  final String blockId;
  final String judgeId;
  final int timeTotalMs;
  final int penaltiesSum;
  final List<Penalty> penaltiesList;

  ResultModel({
    required this.id,
    required this.participantId,
    required this.blockId,
    required this.judgeId,
    required this.timeTotalMs,
    required this.penaltiesSum,
    required this.penaltiesList,
  });

  factory ResultModel.fromMap(Map<String, dynamic> map, String documentId) {
    var penalties = map['penaltiesList'] as List? ?? [];
    return ResultModel(
      id: documentId,
      participantId: map['participantId'] ?? '',
      blockId: map['blockId'] ?? '',
      judgeId: map['judgeId'] ?? '',
      timeTotalMs: map['timeTotalMs'] ?? 0,
      penaltiesSum: map['penaltiesSum'] ?? 0,
      penaltiesList: penalties
          .map((p) => Penalty.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantId': participantId,
      'blockId': blockId,
      'judgeId': judgeId,
      'timeTotalMs': timeTotalMs,
      'penaltiesSum': penaltiesSum,
      'penaltiesList': penaltiesList.map((p) => p.toMap()).toList(),
    };
  }
}
