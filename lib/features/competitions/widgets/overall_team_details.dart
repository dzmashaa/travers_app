import 'package:flutter/material.dart';
import 'package:travers_app/core/widgets/base_bottom_sheet.dart';
import 'package:travers_app/core/utils/time_extension.dart';
import 'package:travers_app/features/competitions/providers/leaderboard_provider.dart';
import 'package:travers_app/features/competitions/widgets/summary_highlight_card.dart';

class OverallTeamDetailsBottomSheet extends StatelessWidget {
  final TeamStanding standing;

  const OverallTeamDetailsBottomSheet({super.key, required this.standing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseBottomSheet(
      title: standing.teamName,
      subtitle: 'Загальний командний залік',
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryHighlightCard(
            backgroundColor: Colors.amber.shade50,
            borderColor: Colors.amber.shade200,
            child: MetricColumn(
              title: 'СУМАРНИЙ РЕЗУЛЬТАТ',
              value: standing.formattedPercentage,
              valueColor: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          Text('Результати по дистанціях', style: theme.textTheme.labelLarge),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: standing.distanceScores.length,
              itemBuilder: (context, index) => _DistanceScoreCard(
                ds: standing.distanceScores[index],
                theme: theme,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DistanceScoreCard extends StatelessWidget {
  final DistanceScore ds;
  final ThemeData theme;

  const _DistanceScoreCard({required this.ds, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ds.distanceName,
                style: theme.textTheme.labelLarge?.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                'Час: ${ds.timeMs.toFormattedTime(includeHundredths: false)}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          Text(
            ds.formattedPercentage,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
