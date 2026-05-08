import 'package:flutter/material.dart';
import 'package:travers_app/core/models/competition.dart';

class CompStatusBadge extends StatelessWidget {
  final CompetitionStatus status;
  final double fontSize;

  const CompStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12.0,
  });

  Color _getBadgeColor() {
    switch (status) {
      case CompetitionStatus.active:
        return const Color(0xFFC8F0D6);
      case CompetitionStatus.upcoming:
        return const Color(0xFFD6E4FF);
      case CompetitionStatus.completed:
        return Colors.grey.shade200;
    }
  }

  Color _getBadgeTextColor() {
    switch (status) {
      case CompetitionStatus.active:
        return const Color(0xFF1B5E20);
      case CompetitionStatus.upcoming:
        return const Color(0xFF1565C0);
      case CompetitionStatus.completed:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBadgeColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: _getBadgeTextColor(),
          fontWeight: FontWeight.w600,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
