import 'stage.dart';

class StageBlock {
  final String id;
  final String blockName;
  final List<Stage> stages;
  final List<String> judgeIds;

  StageBlock({
    required this.id,
    required this.blockName,
    required this.stages,
    this.judgeIds = const [],
  });

  factory StageBlock.fromMap(Map<String, dynamic> map) {
    return StageBlock(
      id: map['id'] ?? '',
      blockName: map['blockName'] ?? '',
      stages:
          (map['stages'] as List<dynamic>?)
              ?.map((e) => Stage.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'blockName': blockName,
      'stages': stages.map((s) => s.toMap()).toList(),
    };
  }
}
