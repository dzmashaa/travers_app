import 'package:travers_app/core/models/participant.dart';

class JudgingTarget {
  final String id;
  final String title;
  final String subtitle;

  JudgingTarget({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  factory JudgingTarget.fromParticipant(ParticipantModel p) {
    return JudgingTarget(
      id: p.id,
      title: p.name,
      subtitle: '№${p.startNumber} • ${p.teamName}',
    );
  }

  factory JudgingTarget.fromPair(List<ParticipantModel> pair) {
    pair.sort((a, b) => a.id.compareTo(b.id));

    return JudgingTarget(
      id: 'pair_${pair[0].id}_${pair[1].id}',
      title: '${pair[0].name} та ${pair[1].name}',
      subtitle: 'Зв\'язка • ${pair[0].teamName}',
    );
  }

  factory JudgingTarget.fromTeam(String teamName) {
    return JudgingTarget(
      id: 'team_$teamName',
      title: 'Команда: $teamName',
      subtitle: 'Командна дистанція',
    );
  }
}
