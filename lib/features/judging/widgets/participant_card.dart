import 'package:flutter/material.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';

class ParticipantCard extends StatelessWidget {
  final ParticipantModel participant;
  final VoidCallback onTap;

  final bool isSelectableMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;

  final bool isUnsynced;
  final bool isJudgingMode;
  final bool canEdit;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.onTap,
    this.isSelectableMode = false,
    this.isSelected = false,
    this.onSelectChanged,
    this.isUnsynced = false,
    this.isJudgingMode = false,
    this.canEdit = false,
  });
  String _formatRegion(String region) {
    final r = region.trim();
    if (r.isEmpty) return '';

    final lowerR = r.toLowerCase();
    if (lowerR.startsWith('м.') || lowerR == 'київ') {
      return r;
    }
    if (lowerR.endsWith('обл.') ||
        lowerR.endsWith('область') ||
        lowerR.endsWith('обл')) {
      return r;
    }

    return '$r обл.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMale = participant.gender == Gender.male;

    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 12),
      border: isSelected
          ? Border.all(color: theme.primaryColor, width: 2)
          : null,
      onTap: isSelectableMode
          ? () => onSelectChanged?.call(!isSelected)
          : onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isMale
                  ? theme.primaryColor.withValues(alpha: 0.1)
                  : theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${participant.startNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isMale
                    ? theme.primaryColor
                    : theme.colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        participant.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnsynced) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.cloud_off,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${participant.teamName} • ${participant.birthYear} р.н. • ${_formatRegion(participant.region)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          if (isSelectableMode)
            Checkbox(
              value: isSelected,
              activeColor: theme.primaryColor,
              onChanged: onSelectChanged,
            )
          else if (isJudgingMode)
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
          else if (canEdit)
            Icon(Icons.edit_outlined, size: 20, color: Colors.grey.shade400),
        ],
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final String teamName;
  final VoidCallback onTap;

  const TeamCard({super.key, required this.teamName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BaseAppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: onTap,
      child: Row(
        children: [
          const _TeamIconBadge(),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}

class _TeamIconBadge extends StatelessWidget {
  const _TeamIconBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.people_alt_outlined, color: Colors.blue.shade800),
    );
  }
}
