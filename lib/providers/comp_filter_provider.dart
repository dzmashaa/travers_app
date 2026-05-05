import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:travers_app/models/competition.dart';
import 'package:travers_app/providers/competition_provider.dart';

enum CompetitionFilter { all, active, upcoming, completed }

extension CompetitionFilterExt on CompetitionFilter {
  String get displayName {
    switch (this) {
      case CompetitionFilter.all:
        return 'Всі';
      case CompetitionFilter.active:
        return 'Активні';
      case CompetitionFilter.upcoming:
        return 'Майбутні';
      case CompetitionFilter.completed:
        return 'Завершені';
    }
  }
}

final competitionFilterProvider = StateProvider<CompetitionFilter>(
  (ref) => CompetitionFilter.all,
);

final filteredCompetitionsProvider =
    Provider<AsyncValue<List<CompetitionModel>>>((ref) {
      final filter = ref.watch(competitionFilterProvider);
      final competitionsAsync = ref.watch(allCompetitionsStreamProvider);

      return competitionsAsync.whenData((competitions) {
        if (filter == CompetitionFilter.all) return competitions;

        return competitions.where((comp) {
          switch (filter) {
            case CompetitionFilter.active:
              return comp.status == CompetitionStatus.active;
            case CompetitionFilter.upcoming:
              return comp.status == CompetitionStatus.upcoming;
            case CompetitionFilter.completed:
              return comp.status == CompetitionStatus.completed;
            default:
              return true;
          }
        }).toList();
      });
    });
