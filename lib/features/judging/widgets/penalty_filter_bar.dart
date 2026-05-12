import 'package:flutter/material.dart';
import 'package:travers_app/core/widgets/app_filter_chip.dart';
import 'package:travers_app/main.dart';

class PenaltyPointsFilterBar extends StatelessWidget {
  final int? selectedPoints;
  final ValueChanged<int?> onSelected;

  const PenaltyPointsFilterBar({
    super.key,
    required this.selectedPoints,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final pointsList = [null, 1, 3, 6, 10];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Або оберіть кількість штрафних балів',
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: pointsList.length,
            itemBuilder: (context, index) {
              final points = pointsList[index];
              final isSelected = selectedPoints == points;
              final label = points == null ? '?' : points.toString();

              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: AppFilterChip(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => onSelected(points),
                  minWidth: 56.0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
