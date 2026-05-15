enum Gender { male, female }

class ParticipantModel {
  final String id;
  final String name;
  final String teamName;
  final int startNumber;
  final String coachName;
  final Gender gender;
  final String region;

  ParticipantModel({
    required this.id,
    required this.startNumber,
    required this.name,
    required this.teamName,
    required this.coachName,
    required this.gender,
    required this.region,
  });

  factory ParticipantModel.fromMap(
    Map<String, dynamic> map,
    String documentId,
  ) {
    Gender parsedGender = Gender.male;
    if (map['gender'] == 'female') {
      parsedGender = Gender.female;
    }
    return ParticipantModel(
      id: documentId,
      startNumber: map['startNumber'] ?? 0,
      name: map['name'] ?? '',
      teamName: map['teamName'] ?? '',
      coachName: map['coachName'] ?? '',
      gender: parsedGender,
      region: map['region'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startNumber': startNumber,
      'name': name,
      'teamName': teamName,
      'coachName': coachName,
      'gender': gender.name,
      'region': region.trim(),
    };
  }
}
