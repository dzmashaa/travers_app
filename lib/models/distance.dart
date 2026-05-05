import 'package:travers_app/models/stage_block.dart';

enum DistanceType { obstacleCourse, crossHike, rescueWork }

enum DistanceView { individual, team, pair }

extension DistanceTypeExtension on DistanceType {
  String get displayName {
    switch (this) {
      case DistanceType.obstacleCourse:
        return 'Смуга перешкод';
      case DistanceType.crossHike:
        return 'Крос-похід';
      case DistanceType.rescueWork:
        return 'Рятувальні роботи';
    }
  }
}

extension DistanceViewExtension on DistanceView {
  String get displayName {
    switch (this) {
      case DistanceView.individual:
        return 'Особиста';
      case DistanceView.team:
        return 'Командна';
      case DistanceView.pair:
        return 'Зв\'язки';
    }
  }
}

class Distance {
  final String? description;
  final DistanceType type;
  final int classLevel;
  final DistanceView view;
  final List<StageBlock> stageBlocks;

  Distance({
    this.description,
    required this.type,
    required this.classLevel,
    required this.view,
    required this.stageBlocks,
  });

  factory Distance.fromMap(Map<String, dynamic> map) {
    return Distance(
      description: map['name'] ?? '',
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
      'description': description,
      'type': type.toString().split('.').last,
      'classLevel': classLevel,
      'view': view.toString().split('.').last,
      'stageBlocks': stageBlocks.map((b) => b.toMap()).toList(),
    };
  }
}
