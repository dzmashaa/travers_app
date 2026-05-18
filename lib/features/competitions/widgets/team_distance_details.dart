import 'package:flutter/material.dart';
import 'package:travers_app/core/models/aggregated_result.dart';
import 'package:travers_app/core/widgets/base_bottom_sheet.dart';
import 'package:travers_app/core/utils/time_extension.dart';
import 'package:travers_app/features/competitions/widgets/summary_highlight_card.dart';

class TeamDistanceDetailsBottomSheet extends StatelessWidget {
  final AggregatedResult teamResult;

  const TeamDistanceDetailsBottomSheet({super.key, required this.teamResult});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final members = teamResult.teamMemberResults ?? [];
    final scoringIds = teamResult.scoringTargetIds ?? {};

    return BaseBottomSheet(
      title: teamResult.target.title,
      subtitle: 'Деталізація командного результату',
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryHighlightCard(
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            borderColor: theme.primaryColor.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MetricColumn(
                  title: 'СУМАРНИЙ ЧАС',
                  value: teamResult.finalCalculatedTimeMs.toFormattedTime(
                    includeHundredths: false,
                  ),
                  valueColor: theme.primaryColor,
                ),
                if (teamResult.relativePercentage != null)
                  MetricColumn(
                    title: 'ВІДСОТОК',
                    value:
                        '${teamResult.relativePercentage!.toStringAsFixed(1)} %',
                    valueColor: theme.primaryColor,
                    alignment: CrossAxisAlignment.end,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Результати учасників', style: theme.textTheme.labelLarge),
              Text(
                '${scoringIds.length} в заліку',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return _TeamMemberResultCard(
                  member: member,
                  isScoring: scoringIds.contains(member.target.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamMemberResultCard extends StatelessWidget {
  final AggregatedResult member;
  final bool isScoring;

  const _TeamMemberResultCard({required this.member, required this.isScoring});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isScoring ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isScoring ? Colors.green.shade400 : Colors.grey.shade300,
          width: isScoring ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.target.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isScoring ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                if (isScoring)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'В ЗАЛІК',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                member.finalCalculatedTimeMs.toFormattedTime(
                  includeHundredths: false,
                ),
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isScoring ? Colors.black87 : Colors.grey.shade600,
                ),
              ),
              Text(
                '${member.totalPenalties} штрафів',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
