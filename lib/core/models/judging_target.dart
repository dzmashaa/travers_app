import 'package:travers_app/core/models/participant.dart';

class JudgingTarget {
  final String id;
  final String title;
  final String subtitle;
  final Gender? gender;
  final String region;

  JudgingTarget({
    required this.id,
    required this.title,
    required this.subtitle,
    this.gender,
    this.region = '',
  });

  factory JudgingTarget.fromParticipant(ParticipantModel p) {
    return JudgingTarget(
      id: p.id,
      title: p.name,
      subtitle: '№${p.startNumber} • ${p.teamName}',
      gender: p.gender,
      region: p.region,
    );
  }

  factory JudgingTarget.fromPair(List<ParticipantModel> pair) {
    final combinedId = '${pair[0].id},${pair[1].id}';
    final combinedTitle = '${pair[0].name} / ${pair[1].name}';
    return JudgingTarget(
      id: combinedId,
      title: combinedTitle,
      subtitle: 'Зв\'язка',
    );
  }

  factory JudgingTarget.fromTeam(String teamName) {
    return JudgingTarget(id: teamName, title: teamName, subtitle: 'Команда');
  }
}
