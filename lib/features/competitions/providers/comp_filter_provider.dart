import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/utils/comp_filters.dart';

final competitionSearchQueryProvider = StateProvider<String>((ref) => '');

final competitionFilterProvider = StateProvider<CompetitionFilter>(
  (ref) => CompetitionFilter.all,
);

final filteredCompetitionsProvider =
    Provider<AsyncValue<List<CompetitionModel>>>((ref) {
      final filter = ref.watch(competitionFilterProvider);

      final searchQuery = ref
          .watch(competitionSearchQueryProvider)
          .trim()
          .toLowerCase();

      final competitionsAsync = ref.watch(allCompetitionsStreamProvider);

      return competitionsAsync.whenData((competitions) {
        Iterable<CompetitionModel> filtered = competitions.filterByStatus(
          filter,
        );
        if (searchQuery.isNotEmpty) {
          filtered = filtered.where((comp) {
            final title = comp.title.toLowerCase();
            final location = comp.location.toString().toLowerCase();

            return title.contains(searchQuery) ||
                location.contains(searchQuery);
          });
        }

        return filtered.toList();
      });
    });

final allCompetitionsStreamProvider =
    StreamProvider.autoDispose<List<CompetitionModel>>((ref) {
      final repository = ref.watch(competitionRepositoryProvider);
      return repository.watchAllCompetitions();
    });
