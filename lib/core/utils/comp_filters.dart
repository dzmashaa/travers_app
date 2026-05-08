import 'package:travers_app/core/models/competition.dart';

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

extension CompetitionListFilterExt on List<CompetitionModel> {
  List<CompetitionModel> filterByStatus(CompetitionFilter filter) {
    if (filter == CompetitionFilter.all) return this;

    return where((comp) {
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
  }
}
