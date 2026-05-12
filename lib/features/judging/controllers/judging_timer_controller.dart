import 'dart:async';

import 'package:flutter/material.dart';

class JudgingTimerController extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  bool get isRunning => _stopwatch.isRunning;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;

  void toggle() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    } else {
      _stopwatch.start();
      _timer = Timer.periodic(
        const Duration(milliseconds: 30),
        (_) => notifyListeners(),
      );
    }
    notifyListeners();
  }

  void reset() {
    _stopwatch.reset();
    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  String getFormattedTime() {
    final ms = _stopwatch.elapsedMilliseconds;
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
