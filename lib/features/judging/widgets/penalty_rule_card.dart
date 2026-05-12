import 'package:flutter/material.dart';
import 'package:travers_app/core/models/penalty_rule.dart';

class PenaltyRuleCard extends StatelessWidget {
  final PenaltyRule rule;
  final VoidCallback onTap;

  const PenaltyRuleCard({super.key, required this.rule, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rule.reason, style: theme.textTheme.labelLarge),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(rule.code, style: theme.textTheme.bodySmall),

                          if (rule.mustFix) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: theme.colorScheme.secondary,
                            ),
                            Text(
                              ' Виправити',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                _buildBadge(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme) {
    if (rule.isDisqualification) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.textTheme.displayMedium?.color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'ЗНЯТТЯ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${rule.points} б.',
          style: TextStyle(
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }
  }
}
