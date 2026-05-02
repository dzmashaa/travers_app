import 'package:flutter/material.dart';
import 'package:travers_app/models/competition.dart';

class CompetitionCard extends StatelessWidget {
  final CompetitionModel competition;
  final VoidCallback onTap;
  const CompetitionCard({
    super.key,
    required this.competition,
    required this.onTap,
  });
  Color _getBadgeColor() {
    switch (competition.status) {
      case CompetitionStatus.active:
        return const Color(0xFFC8F0D6);
      case CompetitionStatus.upcoming:
        return const Color(0xFFD6E4FF);
      case CompetitionStatus.completed:
        return Colors.grey.shade200;
    }
  }

  Color _getBadgeTextColor() {
    switch (competition.status) {
      case CompetitionStatus.active:
        return const Color(0xFF1B5E20);
      case CompetitionStatus.upcoming:
        return const Color(0xFF1565C0);
      case CompetitionStatus.completed:
        return Colors.black54;
    }
  }

  String _getBadgeText() {
    switch (competition.status) {
      case CompetitionStatus.active:
        return 'Триває';
      case CompetitionStatus.upcoming:
        return 'Майбутнє';
      case CompetitionStatus.completed:
        return 'Завершено';
    }
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final sDay = start.day.toString().padLeft(2, '0');
    final sMonth = start.month.toString().padLeft(2, '0');
    final eDay = end.day.toString().padLeft(2, '0');
    final eMonth = end.month.toString().padLeft(2, '0');
    final year = start.year;

    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return '$sDay.$sMonth.$year';
    }
    if (start.month == end.month && start.year == end.year) {
      return '$sDay-$eDay.$sMonth.$year';
    }
    return '$sDay.$sMonth - $eDay.$eMonth.$year';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getBadgeText(),
                        style: TextStyle(
                          color: _getBadgeTextColor(),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      competition.location,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDateRange(
                        competition.startDate,
                        competition.endDate,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
