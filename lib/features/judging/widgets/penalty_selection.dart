import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/penalty_rule.dart';
import 'package:travers_app/core/widgets/app_search_field.dart';
import 'package:travers_app/features/judging/providers/penalties_provider.dart';
import 'package:travers_app/features/judging/widgets/penalty_filter_bar.dart';
import 'package:travers_app/features/judging/widgets/penalty_rule_card.dart';

class PenaltySelectionSheet extends ConsumerStatefulWidget {
  const PenaltySelectionSheet({super.key});

  @override
  ConsumerState<PenaltySelectionSheet> createState() =>
      _PenaltySelectionSheetState();
}

class _PenaltySelectionSheetState extends ConsumerState<PenaltySelectionSheet> {
  String _searchQuery = '';
  int? _selectedPointsFilter;

  List<dynamic> _getFilteredRules(List<PenaltyRule> rules) {
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F7F4),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              const Text(
                'Оберіть штраф',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close, color: theme.primaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppSearchField(
            hintText: 'Введіть ключове слово або код',
            margin: EdgeInsets.zero,
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
          const SizedBox(height: 16),

          PenaltyPointsFilterBar(
            selectedPoints: _selectedPointsFilter,
            onSelected: (points) {
              setState(() {
                _selectedPointsFilter = points;
              });
            },
          ),
          const SizedBox(height: 24),

          Expanded(
            child: rulesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Помилка: $e')),
              data: (rules) {
                final filtered = _getFilteredRules(rules);

                if (filtered.isEmpty) {
                  return const Center(child: Text('Штраф не знайдено'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final rule = filtered[index];

                    return PenaltyRuleCard(
                      rule: rule,
                      onTap: () => Navigator.pop(context, rule),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
