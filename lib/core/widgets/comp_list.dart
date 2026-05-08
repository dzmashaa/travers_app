import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/features/competitions/screens/competition_details.dart';
import 'package:travers_app/core/widgets/competition_card.dart';

class CompetitionsList extends ConsumerWidget {
  final AsyncValue<List<CompetitionModel>> competitionsAsync;
  final String emptyMessage;
  const CompetitionsList({
    super.key,
    required this.competitionsAsync,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return competitionsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: theme.primaryColor)),
      error: (error, stackTrace) =>
          _buildCenteredText('Помилка завантаження даних', theme),
      data: (filteredList) {
        if (filteredList.isEmpty) {
          return _buildCenteredText(emptyMessage, theme);
        }

        return Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              final competition = filteredList[index];
              return CompetitionCard(
                competition: competition,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CompetitionDetailsScreen(
                        competitionId: competition.id,
                        initialCompetition: competition,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCenteredText(String text, ThemeData theme) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: Colors.grey.shade600,
          height: 1.5,
        ),
      ),
    );
  }
}
