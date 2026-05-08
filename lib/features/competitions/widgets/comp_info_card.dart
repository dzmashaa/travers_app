import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/utils/date_formatters.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/comp_status.dart';

class CompInfoCard extends StatelessWidget {
  final CompetitionModel competition;
  final bool canEdit;
  final VoidCallback onDelete;

  const CompInfoCard({
    super.key,
    required this.competition,
    required this.canEdit,
    required this.onDelete,
  });

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: competition.inviteCode));
    SnackbarUtils.show(context, 'Код скопійовано!', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CompStatusBadge(status: competition.status, fontSize: 14.0),
                  GestureDetector(
                    onTap: () => _copyCode(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.copy, size: 14, color: theme.primaryColor),
                          const SizedBox(width: 6),
                          Text(
                            competition.inviteCode,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.primaryColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    competition.location,
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 20,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatDateRange(competition.startDate, competition.endDate),
                    style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),

          if (canEdit)
            Positioned(
              right: 8,
              bottom: 8,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error.withValues(alpha: 0.8),
                ),
                tooltip: 'Видалити змагання',
              ),
            ),
        ],
      ),
    );
  }
}
