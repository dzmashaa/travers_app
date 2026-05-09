import 'package:flutter/material.dart';
import 'package:travers_app/core/models/participant.dart';
import 'package:travers_app/core/widgets/base_app_card.dart';

class ParticipantCard extends StatelessWidget {
  final ParticipantModel participant;
  final VoidCallback onTap;

  final bool isSelectableMode;
  final bool isSelected;
  final ValueChanged<bool?>? onSelectChanged;

  const ParticipantCard({
    super.key,
    required this.participant,
    required this.onTap,
    this.isSelectableMode = false,
    this.isSelected = false,
    this.onSelectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
          _StartNumberBadge(number: participant.startNumber),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  participant.teamName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (isSelectableMode)
            Checkbox(
              value: isSelected,
              activeColor: theme.primaryColor,
              onChanged: onSelectChanged,
            ),
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

class _StartNumberBadge extends StatelessWidget {
  final dynamic number;
  const _StartNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        number.toString(),
        style: TextStyle(
          color: Colors.orange.shade800,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
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
