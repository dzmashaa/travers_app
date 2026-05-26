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

enum DistanceStage {
  tyroleanTraverseRavine,
  tyroleanTraverseRiver,
  inclinedTyroleanTraverseDown,
  inclinedTyroleanTraverseUp,
  ropeCrossingWithRailingsRavine,
  ropeCrossingWithRailingsRiver,
  ropeCrossingWithRailingsDown,
  ropeCrossingWithRailingsUp,
  logCrossingRavine,
  logCrossingRiver,
  wadingRiverCrossingWithRailings,
  pendulumCrossing,
  horizontalPendulumCrossing,
  slopeAscent,
  rockAscent,
  verticalRailingAscent,
  slopeTraverse,
  rockTraverse,
  slopeDescent,
  verticalRailingDescent,
  poleWalking,
  tussockWalking,
  wadingRiverCrossing,
  watercraftCrossing,
  victimTransportation,
  orienteering,
  knotTying,
  firstAid,
  topographyAndGeodesy,
  distanceOrHeightMeasurement,
  tentPitching,
  fireMaking,
  backpackPacking,
  equipmentMaking,
}

extension DistanceStageExt on DistanceStage {
  String get displayName {
    switch (this) {
      case DistanceStage.tyroleanTraverseRavine:
        return 'Навісна переправа через яр';
      case DistanceStage.tyroleanTraverseRiver:
        return 'Навісна переправа через річку';
      case DistanceStage.inclinedTyroleanTraverseDown:
        return 'Похила навісна переправа вниз';
      case DistanceStage.inclinedTyroleanTraverseUp:
        return 'Похила навісна переправа вгору';
      case DistanceStage.ropeCrossingWithRailingsRavine:
        return 'Переправа по вірьовці з перилами через яр';
      case DistanceStage.ropeCrossingWithRailingsRiver:
        return 'Переправа по вірьовці з перилами через річку';
      case DistanceStage.ropeCrossingWithRailingsDown:
        return 'Переправа по вірьовці з перилами вниз';
      case DistanceStage.ropeCrossingWithRailingsUp:
        return 'Переправа по вірьовці з перилами вгору';
      case DistanceStage.logCrossingRavine:
        return 'Переправа по колоді через яр';
      case DistanceStage.logCrossingRiver:
        return 'Переправа по колоді через річку';
      case DistanceStage.wadingRiverCrossingWithRailings:
        return 'Переправа через річку вбрід із використанням перил';
      case DistanceStage.pendulumCrossing:
        return 'Переправа за допомогою підвішеної мотузки (маятником)';
      case DistanceStage.horizontalPendulumCrossing:
        return 'Переправа за допомогою горизонтального маятника';
      case DistanceStage.slopeAscent:
        return 'Підйом схилом';
      case DistanceStage.rockAscent:
        return 'Підйом скельною ділянкою';
      case DistanceStage.verticalRailingAscent:
        return 'Підйом по вертикальних перилах';
      case DistanceStage.slopeTraverse:
        return 'Траверс схилу';
      case DistanceStage.rockTraverse:
        return 'Траверс скельної ділянки';
      case DistanceStage.slopeDescent:
        return 'Спуск схилом';
      case DistanceStage.verticalRailingDescent:
        return 'Спуск по вертикальних перилах';
      case DistanceStage.poleWalking:
        return 'Рух по жердинах';
      case DistanceStage.tussockWalking:
        return 'Рух по купинах';
      case DistanceStage.wadingRiverCrossing:
        return 'Переправа через річку вбрід';
      case DistanceStage.watercraftCrossing:
        return 'Переправа на плавзасобах';
      case DistanceStage.victimTransportation:
        return 'Транспортування потерпілого';
      case DistanceStage.orienteering:
        return 'Орієнтування';
      case DistanceStage.knotTying:
        return 'В’язання вузлів';
      case DistanceStage.firstAid:
        return 'Надання долікарської допомоги';
      case DistanceStage.topographyAndGeodesy:
        return 'Залік з топографії та геодезії';
      case DistanceStage.distanceOrHeightMeasurement:
        return 'Визначення відстані або висоти';
      case DistanceStage.tentPitching:
        return 'Установлення намету';
      case DistanceStage.fireMaking:
        return 'Розпалювання багаття';
      case DistanceStage.backpackPacking:
        return 'Пакування рюкзака';
      case DistanceStage.equipmentMaking:
        return 'Виготовлення спорядження';
    }
  }
}
