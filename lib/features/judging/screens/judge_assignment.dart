import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/features/auth/auth_provider.dart';
import 'package:travers_app/features/competitions/widgets/comp_status.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';
import 'package:travers_app/features/judging/screens/participant_search.dart';
import 'package:travers_app/features/judging/widgets/judge_assignment_card.dart';

class JudgeAssignmentsScreen extends ConsumerWidget {
  final CompetitionModel competition;

  const JudgeAssignmentsScreen({super.key, required this.competition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentUserId = ref.watch(currentUserUidProvider);
    final List<JudgeAssignment> assignments = [];

    if (currentUserId != null) {
      for (final distance in competition.distances) {
        for (final block in distance.stageBlocks) {
          if (block.judgeIds.contains(currentUserId) == true) {
            assignments.add(JudgeAssignment(distance: distance, block: block));
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              competition.title,
              style: theme.textTheme.displayMedium?.copyWith(
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            CompStatusBadge(status: competition.status),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'МОЇ ПРИЗНАЧЕННЯ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: assignments.isEmpty
                ? Center(
                    child: Text(
                      'Вас ще не призначено на жоден блок',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: assignments.length,
                    itemBuilder: (context, index) {
                      final assignment = assignments[index];

                      return JudgeAssignmentCard(
                        assignment: assignment,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParticipantSearchScreen(
                                competitionId: competition.id,
                                assignment: assignment,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
