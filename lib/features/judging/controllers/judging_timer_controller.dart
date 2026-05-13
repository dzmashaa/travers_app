import 'dart:async';
import 'package:flutter/material.dart';

class JudgingTimerController extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  int _accumulatedMs = 0;

  bool get isRunning => _stopwatch.isRunning;

  int get elapsedMilliseconds =>
      _accumulatedMs + _stopwatch.elapsedMilliseconds;

  void start() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(
        const Duration(milliseconds: 30),
        (_) => notifyListeners(),
      );
      notifyListeners();
    }
  }

  void pause() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _accumulatedMs += _stopwatch.elapsedMilliseconds;
      _stopwatch.reset();
      _timer?.cancel();
      notifyListeners();
    }
  }

  void toggle() {
    if (isRunning)
      pause();
    else
      start();
  }

  void reset() {
    pause();
    _accumulatedMs = 0;
    notifyListeners();
  }

  void setTime(int milliseconds) {
    pause();
    _accumulatedMs = milliseconds;
    notifyListeners();
  }

  String getFormattedTime() {
    final ms = elapsedMilliseconds;
    if (ms <= 0) return '00:00.00';

    final min = (ms ~/ 60000).toString().padLeft(2, '0');
    final sec = ((ms % 60000) ~/ 1000).toString().padLeft(2, '0');
    final hd = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '$min:$sec.$hd';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
