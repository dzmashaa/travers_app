import 'package:flutter/material.dart';
import 'package:travers_app/core/utils/base_bottom_sheet.dart';

class AssignJudgesBottomSheet extends StatefulWidget {
  final Map<String, String> allCompetitionJudges;
  final List<String> initialSelectedIds;

  const AssignJudgesBottomSheet({
    super.key,
    required this.allCompetitionJudges,
    required this.initialSelectedIds,
  });

  @override
  State<AssignJudgesBottomSheet> createState() =>
      _AssignJudgesBottomSheetState();
}

class _AssignJudgesBottomSheetState extends State<AssignJudgesBottomSheet> {
  late List<String> _selectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredJudges = widget.allCompetitionJudges.entries.where((entry) {
      return entry.value.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return BaseBottomSheet(
      title: 'Призначити суддів',
      bottomButton: PrimarySubmitButton(
        text: 'Зберегти',
        onPressed: () => Navigator.pop(context, _selectedIds),
      ),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Пошук за ПІБ...',
              prefixIcon: const Icon(Icons.search),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: filteredJudges.isEmpty
                ? const Center(
                    child: Text(
                      'Суддів не знайдено',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredJudges.length,
                    itemBuilder: (context, index) {
                      final judgeEntry = filteredJudges[index];
                      final isSelected = _selectedIds.contains(judgeEntry.key);

                      return CheckboxListTile(
                        title: Text(
                          judgeEntry.value,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: isSelected,
                        activeColor: theme.primaryColor,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedIds.add(judgeEntry.key);
                            } else {
                              _selectedIds.remove(judgeEntry.key);
                            }
                          });
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
