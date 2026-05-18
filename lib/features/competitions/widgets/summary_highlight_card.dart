import 'package:flutter/material.dart';

class SummaryHighlightCard extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;

  const SummaryHighlightCard({
    super.key,
    required this.backgroundColor,
    required this.borderColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class MetricColumn extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final CrossAxisAlignment alignment;

  const MetricColumn({
    super.key,
    required this.title,
    required this.value,
    required this.valueColor,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: 'Courier',
          ),
        ),
      ],
    );
  }
}
