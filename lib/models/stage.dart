enum StagePassingMode { standard, selfGuided, withVictim }

class Stage {
  final String name;
  final StagePassingMode passingMode;

  Stage({required this.name, required this.passingMode});

  factory Stage.fromMap(Map<String, dynamic> map) {
    return Stage(
      name: map['name'] ?? '',
      passingMode: StagePassingMode.values.firstWhere(
        (e) => e.toString().split('.').last == map['passingMode'],
        orElse: () => StagePassingMode.standard,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'passingMode': passingMode.toString().split('.').last,
    };
  }
}
