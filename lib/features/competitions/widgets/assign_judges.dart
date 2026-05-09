import 'package:flutter/material.dart';

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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final filteredJudges = widget.allCompetitionJudges.entries.where((entry) {
      return entry.value.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: bottomInset + 16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Призначити суддів',
            style: theme.textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),

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

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedIds),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Зберегти',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
