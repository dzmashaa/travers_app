import 'package:travers_app/models/stage_block.dart';

enum DistanceType { obstacleCourse, crossHike, rescueWork }

enum DistanceView { individual, team, pair }

class Distance {
  final String name;
  final DistanceType type;
  final int classLevel; // від 1 до 6
  final DistanceView view;
  final List<StageBlock> stageBlocks;

  Distance({
    required this.name,
    required this.type,
    required this.classLevel,
    required this.view,
    required this.stageBlocks,
  });

  factory Distance.fromMap(Map<String, dynamic> map) {
    return Distance(
      name: map['name'] ?? '',
      type: DistanceType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => DistanceType.obstacleCourse,
      ),
      classLevel: map['classLevel'] ?? 1,
      view: DistanceView.values.firstWhere(
        (e) => e.toString().split('.').last == map['view'],
        orElse: () => DistanceView.individual,
      ),
      stageBlocks:
          (map['stageBlocks'] as List<dynamic>?)
              ?.map((e) => StageBlock.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.toString().split('.').last,
      'classLevel': classLevel,
      'view': view.toString().split('.').last,
      'stageBlocks': stageBlocks.map((b) => b.toMap()).toList(),
    };
  }
}
