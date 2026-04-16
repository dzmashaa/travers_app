import 'package:flutter/material.dart';
import 'package:travers_app/models/user_role.dart';

class CompetitionsScreen extends StatefulWidget {
  final UserRole userRole;
  const CompetitionsScreen({super.key, required this.userRole});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  @override
  Widget build(BuildContext context) {
    final isHeadJudge = widget.userRole == UserRole.headJudge;
    final isJudge = widget.userRole == UserRole.judge;
    final isParticipant = widget.userRole == UserRole.participant;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Змагання'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            if (isParticipant) Text('Привіт, учасник!'),
            if (isJudge) Text('Привіт, суддя!'),
            if (isHeadJudge) Text('Привіт, головний суддя!'),
            Text(
              'Тут будуть всі змагання',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
