class AppliedPenalty {
  final String id;
  final String stageId;
  final String penaltyCode;
  final String reason;
  final int points;
  final bool isDisqualification;

  AppliedPenalty({
    required this.id,
    required this.stageId,
    required this.penaltyCode,
    required this.reason,
    required this.points,
    this.isDisqualification = false,
  });

  factory AppliedPenalty.fromMap(Map<String, dynamic> map) {
    return AppliedPenalty(
      id: map['id'] ?? '',
      stageId: map['stageId'] ?? '',
      penaltyCode: map['penaltyCode'] ?? '',
      reason: map['reason'] ?? '',
      points: map['points'] ?? 0,
      isDisqualification: map['isDisqualification'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'stageId': stageId,
      'penaltyCode': penaltyCode,
      'reason': reason,
      'points': points,
      'isDisqualification': isDisqualification,
    };
  }
}

class ResultModel {
  final String id;
  final String targetId;
  final String blockId;
  final String judgeId;
  final int timeTotalMs;
  final int penaltiesSum;
  final List<AppliedPenalty> appliedPenalties;

  ResultModel({
    required this.id,
    required this.targetId,
    required this.blockId,
    required this.judgeId,
    required this.timeTotalMs,
    required this.penaltiesSum,
    required this.appliedPenalties,
  });

  factory ResultModel.fromMap(Map<String, dynamic> map, String documentId) {
    final penaltiesData = map['appliedPenalties'] as List? ?? [];
    return ResultModel(
      id: documentId,
      targetId: map['targetId'] ?? '',
      blockId: map['blockId'] ?? '',
      judgeId: map['judgeId'] ?? '',
      timeTotalMs: map['timeTotalMs'] ?? 0,
      penaltiesSum: map['penaltiesSum'] ?? 0,
      appliedPenalties: penaltiesData
          .map((p) => AppliedPenalty.fromMap(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetId': targetId,
      'blockId': blockId,
      'judgeId': judgeId,
      'timeTotalMs': timeTotalMs,
      'penaltiesSum': penaltiesSum,
      'appliedPenalties': appliedPenalties.map((p) => p.toMap()).toList(),
    };
  }

  ResultModel copyWith({
    String? id,
    String? targetId,
    String? blockId,
    String? judgeId,
    int? timeTotalMs,
    int? penaltiesSum,
    List<AppliedPenalty>? appliedPenalties,
  }) {
    return ResultModel(
      id: id ?? this.id,
      targetId: targetId ?? this.targetId,
      blockId: blockId ?? this.blockId,
      judgeId: judgeId ?? this.judgeId,
      timeTotalMs: timeTotalMs ?? this.timeTotalMs,
      penaltiesSum: penaltiesSum ?? this.penaltiesSum,
      appliedPenalties: appliedPenalties ?? this.appliedPenalties,
    );
  }
}
