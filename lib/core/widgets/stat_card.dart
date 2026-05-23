import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color numberColor;
  final IconData? actionIcon;

  const StatCard({
    super.key,
    required this.number,
    required this.label,
    required this.numberColor,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  number,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: numberColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (actionIcon != null)
            Positioned(
              top: -4,
              right: 12,
              child: Icon(
                actionIcon,
                size: 16,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }
}
