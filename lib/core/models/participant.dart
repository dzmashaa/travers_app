class ParticipantModel {
  final String id;
  final String name;
  final String teamName;
  final int startNumber;
  final String coachName;

  ParticipantModel({
    required this.id,
    required this.startNumber,
    required this.name,
    required this.teamName,
    required this.coachName,
  });

  factory ParticipantModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    return ParticipantModel(
      id: documentId,
      startNumber: map['startNumber'] ?? 0,
      name: map['name'] ?? '',
      teamName: map['teamName'] ?? '',
      coachName: map['coachName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startNumber': startNumber,
      'name': name,
      'teamName': teamName,
      'coachName': coachName,
    };
  }
}
