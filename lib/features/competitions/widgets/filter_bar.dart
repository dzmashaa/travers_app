import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/features/competitions/providers/comp_filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedFilter = ref.watch(competitionFilterProvider);
    return SizedBox(
      height: 35,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CompetitionFilter.values.length,
        itemBuilder: (context, index) {
          final filter = CompetitionFilter.values[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () =>
                  ref.read(competitionFilterProvider.notifier).state = filter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.primaryColor
                        : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  filter.displayName,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
