import 'stage.dart';

class StageBlock {
  final String blockName;
  final List<Stage> stages;

  StageBlock({required this.blockName, required this.stages});

  factory StageBlock.fromMap(Map<String, dynamic> map) {
    return StageBlock(
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
      'blockName': blockName,
      'stages': stages.map((s) => s.toMap()).toList(),
    };
  }
}
