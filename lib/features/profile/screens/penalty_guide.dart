import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/widgets/app_search_field.dart';
import 'package:travers_app/features/judging/providers/penalties_provider.dart';
import 'package:travers_app/features/judging/widgets/penalty_filter_bar.dart';
import 'package:travers_app/features/judging/widgets/penalty_rule_card.dart';

class PenaltyGuideScreen extends ConsumerStatefulWidget {
  const PenaltyGuideScreen({super.key});

  @override
  ConsumerState<PenaltyGuideScreen> createState() => _PenaltyGuideScreenState();
}

class _PenaltyGuideScreenState extends ConsumerState<PenaltyGuideScreen> {
  String _searchQuery = '';
  int? _selectedPointsFilter;

  List<PenaltyRule> _getFilteredRules(List<PenaltyRule> rules) {
    final query = _searchQuery.toLowerCase();

    return rules.where((rule) {
      final matchesText =
          rule.reason.toLowerCase().contains(query) ||
          rule.code.toLowerCase().contains(query);

      final matchesPoints =
          _selectedPointsFilter == null || rule.points == _selectedPointsFilter;

      return matchesText && matchesPoints;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rulesAsync = ref.watch(penaltyRulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Довідник штрафів',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppSearchField(
              hintText: 'Пошук штрафу...',
              margin: EdgeInsets.zero,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),

            PenaltyPointsFilterBar(
              selectedPoints: _selectedPointsFilter,
              onSelected: (points) =>
                  setState(() => _selectedPointsFilter = points),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: rulesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Помилка: $e')),
                data: (rules) {
                  final filtered = _getFilteredRules(rules);

                  if (filtered.isEmpty) {
                    return const Center(child: Text('Штрафів не знайдено'));
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return PenaltyRuleCard(
                        rule: filtered[index],
                        onTap: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
