import 'package:flutter/material.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/utils/date_formatters.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';
import 'package:travers_app/features/competitions/widgets/comp_status.dart';
import 'package:travers_app/features/competitions/widgets/icon_text_row.dart';

class CompetitionCard extends StatelessWidget {
  final CompetitionModel competition;
  final VoidCallback onTap;

  const CompetitionCard({
    super.key,
    required this.competition,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  competition.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CompStatusBadge(status: competition.status),
            ],
          ),
          const SizedBox(height: 12),
          IconTextRow(
            icon: Icons.location_on_outlined,
            text: competition.location,
          ),
          const SizedBox(height: 6),
          IconTextRow(
            icon: Icons.calendar_today_outlined,
            iconSize: 16,
            text: formatDateRange(competition.startDate, competition.endDate),
          ),
        ],
      ),
    );
  }
}
