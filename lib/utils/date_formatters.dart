import 'package:intl/intl.dart';

String formatDateRange(DateTime start, DateTime end) {
  final fullDate = DateFormat('dd.MM.yyyy');
  final dayOnly = DateFormat('dd');
  final dayMonth = DateFormat('dd.MM');

  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return fullDate.format(start);
  }

  if (start.year == end.year && start.month == end.month) {
    return '${dayOnly.format(start)}-${fullDate.format(end)}';
  }

  if (start.year == end.year) {
    return '${dayMonth.format(start)} - ${fullDate.format(end)}';
  }
  return '${fullDate.format(start)} - ${fullDate.format(end)}';
}
