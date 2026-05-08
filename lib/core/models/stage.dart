import 'package:flutter/material.dart';

enum StagePassingMode { standard, selfGuided, withVictim }

extension StagePassingModeExt on StagePassingMode {
  String get displayName {
    switch (this) {
      case StagePassingMode.standard:
        return 'Стандартно';
      case StagePassingMode.selfGuided:
        return 'Самонаведення';
      case StagePassingMode.withVictim:
        return 'З потерпілим';
    }
  }

  IconData? get icon {
    switch (this) {
      case StagePassingMode.standard:
        return null;
      case StagePassingMode.selfGuided:
        return Icons.star;
      case StagePassingMode.withVictim:
        return Icons.medication_outlined;
    }
  }
}

class Stage {
  final String id;
  final String name;
  final StagePassingMode passingMode;

  Stage({required this.id, required this.name, required this.passingMode});

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      passingMode: StagePassingMode.values.firstWhere(
        (e) => e.toString().split('.').last == map['passingMode'],
        orElse: () => StagePassingMode.standard,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'passingMode': passingMode.toString().split('.').last,
    };
  }
}
