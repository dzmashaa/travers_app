import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/utils/comp_filters.dart';
import 'package:travers_app/core/widgets/app_filter_chip.dart';
import 'package:travers_app/features/competitions/providers/comp_filter_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: AppFilterChip(
              label: filter.displayName,
              isSelected: isSelected,
              onTap: () =>
                  ref.read(competitionFilterProvider.notifier).state = filter,
            ),
          );
        },
      ),
    );
  }
}
