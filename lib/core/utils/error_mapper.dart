import 'package:travers_app/core/utils/exeptions.dart';

class ErrorMapper {
  static String getHumanReadableMessage(Object error) {
    final errStr = error.toString().toLowerCase();
    if (error is AppException) {
      return error.message;
    }
    if (errStr.contains('permission-denied')) {
      return 'У вас немає прав для виконання цієї дії.';
    }
    if (errStr.contains('network') || errStr.contains('unavailable')) {
      return 'Помилка мережі. Перевірте підключення до інтернету.';
    }
    if (errStr.contains('not-found')) {
      return 'Документ не знайдено.';
    }

    return 'Виникла непередбачувана помилка. Спробуйте пізніше.';
  }
}
