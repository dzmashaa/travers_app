enum Gender { male, female }

class ParticipantModel {
  final String id;
  final String name;
  final String teamName;
  final int startNumber;
  final String coachName;
  final Gender gender;
  final String region;
  final int birthYear;

  ParticipantModel({
    required this.id,
    required this.startNumber,
    required this.name,
    required this.teamName,
    required this.coachName,
    required this.gender,
    required this.region,
    required this.birthYear,
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
      birthYear: map['birthYear'] ?? DateTime.now().year,
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
      'birthYear': birthYear,
    };
  }

  ParticipantModel copyWith({
    String? id,
    int? startNumber,
    String? name,
    String? teamName,
    String? coachName,
    Gender? gender,
    String? region,
    int? birthYear,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      startNumber: startNumber ?? this.startNumber,
      name: name ?? this.name,
      teamName: teamName ?? this.teamName,
      coachName: coachName ?? this.coachName,
      gender: gender ?? this.gender,
      region: region ?? this.region,
      birthYear: birthYear ?? this.birthYear,
    );
  }
}
