import 'package:flutter/material.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';
import 'package:travers_app/core/widgets/distance_header_row.dart';
import 'package:travers_app/features/judging/providers/judge_provider.dart';

class JudgeAssignmentCard extends StatelessWidget {
  final JudgeAssignment assignment;
  final VoidCallback onTap;

  const JudgeAssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final block = assignment.block;

    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DistanceHeaderRow(distance: assignment.distance),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ваш блок:',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      block.blockName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
