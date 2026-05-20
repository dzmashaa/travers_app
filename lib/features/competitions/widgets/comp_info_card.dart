import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/utils/date_formatters.dart';
import 'package:travers_app/core/utils/snackbar_utils.dart';
import 'package:travers_app/features/competitions/widgets/base_info_container.dart';
import 'package:travers_app/features/competitions/widgets/comp_status.dart';
import 'package:travers_app/features/competitions/widgets/icon_text_row.dart';

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
    final textStyle = theme.textTheme.bodyLarge?.copyWith(fontSize: 16);

    return BaseInfoContainer(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CompStatusBadge(status: competition.status, fontSize: 14.0),
                  if (canEdit) _buildCopyCodeButton(theme, context),
                ],
              ),
              const SizedBox(height: 20),

              IconTextRow(
                icon: Icons.location_on,
                text: competition.location,
                textStyle: textStyle,
              ),
              const SizedBox(height: 12),
              IconTextRow(
                icon: Icons.calendar_month,
                text: formatDateRange(
                  competition.startDate,
                  competition.endDate,
                ),
                textStyle: textStyle,
              ),
            ],
          ),

          if (canEdit)
            Positioned(
              right: 0,
              bottom: 0,
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

  Widget _buildCopyCodeButton(ThemeData theme, BuildContext context) {
    return GestureDetector(
      onTap: () => _copyCode(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
    );
  }
}
