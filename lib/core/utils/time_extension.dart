extension TimeFormatExtension on int {
  ({String min, String sec, String hd}) toTimeParts() {
    final ms = this <= 0 ? 0 : this;

    final min = (ms ~/ 60000).toString().padLeft(2, '0');
    final sec = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final hd = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');

    return (min: min, sec: sec, hd: hd);
  }

  String toFormattedTime({bool includeHundredths = true}) {
    final parts = toTimeParts();

    if (includeHundredths) {
      return '${parts.min}:${parts.sec}.${parts.hd}';
    } else {
      return '${parts.min}:${parts.sec}';
    }
  }
}
