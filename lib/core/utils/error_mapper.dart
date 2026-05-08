class ErrorMapper {
  static String getHumanReadableMessage(dynamic error) {
    final errStr = error.toString().toLowerCase();

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
