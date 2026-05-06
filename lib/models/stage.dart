enum StagePassingMode { standard, selfGuided, withVictim }

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
