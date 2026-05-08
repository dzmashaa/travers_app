import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:travers_app/core/models/competition.dart';
import 'package:travers_app/core/repositories/competition_repository.dart';
import 'package:travers_app/core/utils/comp_filters.dart';

final competitionFilterProvider = StateProvider<CompetitionFilter>(
  (ref) => CompetitionFilter.all,
);

final filteredCompetitionsProvider =
    Provider<AsyncValue<List<CompetitionModel>>>((ref) {
      final filter = ref.watch(competitionFilterProvider);
      final competitionsAsync = ref.watch(allCompetitionsStreamProvider);
      return competitionsAsync.whenData(
        (competitions) => competitions.filterByStatus(filter),
      );
    });
